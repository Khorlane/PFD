#include "pfd/database/QueryResult.hpp"

#include <libpq-fe.h>

#include <charconv>
#include <stdexcept>
#include <string>
#include <utility>

namespace
{

[[nodiscard]] int checked_index(const std::size_t value, const int upper_bound, const char *label)
{
  if (value >= static_cast<std::size_t>(upper_bound))
  {
    throw std::out_of_range{std::string{label} + " index is outside the PostgreSQL result"};
  }

  return static_cast<int>(value);
}

[[nodiscard]] PGresult *require_result(PGresult *result)
{
  if (result == nullptr)
  {
    throw std::logic_error{"The PostgreSQL result has been moved from"};
  }

  return result;
}

} // namespace

namespace pfd::database
{

QueryResult::QueryResult(pg_result *result) noexcept
    : result_{result}
{
}

QueryResult::~QueryResult() noexcept
{
  if (result_ != nullptr)
  {
    PQclear(result_);
  }
}

QueryResult::QueryResult(QueryResult &&other) noexcept
    : result_{std::exchange(other.result_, nullptr)}
{
}

QueryResult &QueryResult::operator=(QueryResult &&other) noexcept
{
  if (this != &other)
  {
    if (result_ != nullptr)
    {
      PQclear(result_);
    }
    result_ = std::exchange(other.result_, nullptr);
  }

  return *this;
}

ResultStatus QueryResult::status() const noexcept
{
  if (result_ == nullptr)
  {
    return ResultStatus::unknown;
  }

  switch (PQresultStatus(result_))
  {
  case PGRES_EMPTY_QUERY:
    return ResultStatus::empty_query;
  case PGRES_COMMAND_OK:
    return ResultStatus::command_ok;
  case PGRES_TUPLES_OK:
    return ResultStatus::tuples_ok;
  case PGRES_COPY_OUT:
    return ResultStatus::copy_out;
  case PGRES_COPY_IN:
    return ResultStatus::copy_in;
  case PGRES_BAD_RESPONSE:
    return ResultStatus::bad_response;
  case PGRES_NONFATAL_ERROR:
    return ResultStatus::nonfatal_error;
  case PGRES_FATAL_ERROR:
    return ResultStatus::fatal_error;
  case PGRES_COPY_BOTH:
    return ResultStatus::copy_both;
  case PGRES_SINGLE_TUPLE:
    return ResultStatus::single_tuple;
  case PGRES_PIPELINE_SYNC:
    return ResultStatus::pipeline_sync;
  case PGRES_PIPELINE_ABORTED:
    return ResultStatus::pipeline_aborted;
  default:
    return ResultStatus::unknown;
  }
}

std::string_view QueryResult::status_name() const noexcept
{
  if (result_ == nullptr)
  {
    return "invalid result";
  }

  const char *name = PQresStatus(PQresultStatus(result_));
  return name == nullptr ? std::string_view{} : std::string_view{name};
}

std::string_view QueryResult::command_tag() const noexcept
{
  if (result_ == nullptr)
  {
    return {};
  }

  const char *tag = PQcmdStatus(result_);
  return tag == nullptr ? std::string_view{} : std::string_view{tag};
}

std::optional<std::uint64_t> QueryResult::affected_rows() const noexcept
{
  if (result_ == nullptr)
  {
    return std::nullopt;
  }

  const char *text = PQcmdTuples(result_);
  if (text == nullptr || *text == '\0')
  {
    return std::nullopt;
  }

  std::uint64_t count = 0;
  const std::string_view value{text};
  const auto conversion = std::from_chars(value.data(), value.data() + value.size(), count);
  if (conversion.ec != std::errc{} || conversion.ptr != value.data() + value.size())
  {
    return std::nullopt;
  }

  return count;
}

std::size_t QueryResult::row_count() const noexcept
{
  return result_ == nullptr ? 0U : static_cast<std::size_t>(PQntuples(result_));
}

std::size_t QueryResult::column_count() const noexcept
{
  return result_ == nullptr ? 0U : static_cast<std::size_t>(PQnfields(result_));
}

std::string_view QueryResult::column_name(const std::size_t column) const
{
  PGresult *result = require_result(result_);
  const int checked_column = checked_index(column, PQnfields(result), "Column");
  const char *name = PQfname(result, checked_column);
  return name == nullptr ? std::string_view{} : std::string_view{name};
}

bool QueryResult::is_null(const std::size_t row, const std::size_t column) const
{
  PGresult *result = require_result(result_);
  const int checked_row = checked_index(row, PQntuples(result), "Row");
  const int checked_column = checked_index(column, PQnfields(result), "Column");
  return PQgetisnull(result, checked_row, checked_column) != 0;
}

std::string_view QueryResult::value(const std::size_t row, const std::size_t column) const
{
  PGresult *result = require_result(result_);
  const int checked_row = checked_index(row, PQntuples(result), "Row");
  const int checked_column = checked_index(column, PQnfields(result), "Column");
  if (PQgetisnull(result, checked_row, checked_column) != 0)
  {
    throw std::logic_error{"A PostgreSQL NULL value must be checked before it is read"};
  }

  return {PQgetvalue(result, checked_row, checked_column),
          static_cast<std::size_t>(PQgetlength(result, checked_row, checked_column))};
}

} // namespace pfd::database
