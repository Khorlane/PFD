#include "pfd/database/Connection.hpp"
#include "pfd/database/DatabaseError.hpp"

#include <libpq-fe.h>

#include <limits>
#include <optional>
#include <span>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

namespace
{

[[nodiscard]] std::string connection_error(PGconn *connection)
{
  if (connection == nullptr)
  {
    return "libpq could not allocate a database connection";
  }

  const char *message = PQerrorMessage(connection);
  return message == nullptr || *message == '\0' ? "PostgreSQL returned no error details" : message;
}

[[nodiscard]] std::string result_field(PGresult *result, const int field_code)
{
  const char *value = result == nullptr ? nullptr : PQresultErrorField(result, field_code);
  return value == nullptr ? std::string{} : std::string{value};
}

[[noreturn]] void throw_result_error(PGconn *connection, PGresult *result)
{
  std::string message = result_field(result, PG_DIAG_MESSAGE_PRIMARY);
  if (message.empty())
  {
    message = connection_error(connection);
  }

  throw pfd::database::DatabaseError{
      std::move(message),
      result_field(result, PG_DIAG_SQLSTATE),
      result_field(result, PG_DIAG_SEVERITY_NONLOCALIZED),
      result_field(result, PG_DIAG_MESSAGE_DETAIL),
      result_field(result, PG_DIAG_MESSAGE_HINT),
      result_field(result, PG_DIAG_CONTEXT)};
}

void require_open(PGconn *connection)
{
  if (connection == nullptr || PQstatus(connection) != CONNECTION_OK)
  {
    throw pfd::database::DatabaseError{"PostgreSQL connection is not open"};
  }
}

[[nodiscard]] int checked_parameter_count(const std::size_t count)
{
  if (count > static_cast<std::size_t>(std::numeric_limits<int>::max()))
  {
    throw std::length_error{"PostgreSQL parameter count exceeds the libpq limit"};
  }

  return static_cast<int>(count);
}

struct ParameterArrays
{
  explicit ParameterArrays(const std::span<const pfd::database::Parameter> parameters)
  {
    storage.reserve(parameters.size());
    values.reserve(parameters.size());
    for (const auto &parameter : parameters)
    {
      if (parameter.has_value() && parameter->find('\0') != std::string_view::npos)
      {
        throw std::invalid_argument{"Text parameters cannot contain embedded null characters"};
      }
      storage.emplace_back(parameter.has_value() ? std::optional<std::string>{std::string{*parameter}} : std::nullopt);
    }
    for (const auto &parameter : storage)
    {
      values.push_back(parameter.has_value() ? parameter->c_str() : nullptr);
    }
  }

  std::vector<std::optional<std::string>> storage;
  std::vector<const char *> values;
};

[[nodiscard]] PGresult *checked_result(PGconn *connection, PGresult *result)
{
  if (result == nullptr)
  {
    throw pfd::database::DatabaseError{connection_error(connection)};
  }

  const ExecStatusType status = PQresultStatus(result);
  if (status != PGRES_COMMAND_OK && status != PGRES_TUPLES_OK)
  {
    try
    {
      throw_result_error(connection, result);
    }
    catch (...)
    {
      PQclear(result);
      throw;
    }
  }

  return result;
}

} // namespace

namespace pfd::database
{

Connection::Connection(const std::string_view connection_info)
{
  const std::string null_terminated_connection_info{connection_info};
  connection_ = PQconnectdb(null_terminated_connection_info.c_str());

  if (connection_ == nullptr || PQstatus(connection_) != CONNECTION_OK)
  {
    const std::string message = connection_error(connection_);
    if (connection_ != nullptr)
    {
      PQfinish(connection_);
    }
    connection_ = nullptr;
    throw DatabaseError{"PostgreSQL connection failed: " + message};
  }
}

Connection::~Connection() noexcept
{
  if (connection_ != nullptr)
  {
    PQfinish(connection_);
  }
}

Connection::Connection(Connection &&other) noexcept
    : connection_{std::exchange(other.connection_, nullptr)}
{
}

Connection &Connection::operator=(Connection &&other) noexcept
{
  if (this != &other)
  {
    if (connection_ != nullptr)
    {
      PQfinish(connection_);
    }
    connection_ = std::exchange(other.connection_, nullptr);
  }

  return *this;
}

bool Connection::is_open() const noexcept
{
  return connection_ != nullptr && PQstatus(connection_) == CONNECTION_OK;
}

QueryResult Connection::execute(const std::string_view sql)
{
  require_open(connection_);
  const std::string null_terminated_sql{sql};
  return QueryResult{checked_result(connection_, PQexec(connection_, null_terminated_sql.c_str()))};
}

QueryResult Connection::execute_parameters(
    const std::string_view sql,
    const std::span<const Parameter> parameters)
{
  require_open(connection_);
  const std::string null_terminated_sql{sql};
  const ParameterArrays arrays{parameters};
  PGresult *result = PQexecParams(
      connection_,
      null_terminated_sql.c_str(),
      checked_parameter_count(parameters.size()),
      nullptr,
      arrays.values.data(),
      nullptr,
      nullptr,
      0);
  return QueryResult{checked_result(connection_, result)};
}

void Connection::prepare(
    const std::string_view statement_name,
    const std::string_view sql,
    const std::size_t parameter_count)
{
  require_open(connection_);
  const std::string null_terminated_name{statement_name};
  const std::string null_terminated_sql{sql};
  QueryResult result{checked_result(
      connection_,
      PQprepare(
          connection_,
          null_terminated_name.c_str(),
          null_terminated_sql.c_str(),
          checked_parameter_count(parameter_count),
          nullptr))};

  if (result.status() != ResultStatus::command_ok)
  {
    throw DatabaseError{"PostgreSQL did not accept the prepared statement"};
  }
}

QueryResult Connection::execute_prepared(
    const std::string_view statement_name,
    const std::span<const Parameter> parameters)
{
  require_open(connection_);
  const std::string null_terminated_name{statement_name};
  const ParameterArrays arrays{parameters};
  PGresult *result = PQexecPrepared(
      connection_,
      null_terminated_name.c_str(),
      checked_parameter_count(parameters.size()),
      arrays.values.data(),
      nullptr,
      nullptr,
      0);
  return QueryResult{checked_result(connection_, result)};
}

void Connection::verify_health()
{
  const Parameter expected{std::string_view{"1"}};
  const QueryResult result = execute_parameters("SELECT $1::integer", std::span{&expected, 1U});
  if (result.row_count() != 1 || result.column_count() != 1 || result.is_null(0, 0) || result.value(0, 0) != "1")
  {
    throw DatabaseError{"PostgreSQL health query returned an unexpected result"};
  }
}

} // namespace pfd::database
