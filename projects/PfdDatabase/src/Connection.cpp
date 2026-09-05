#include "pfd/database/Connection.hpp"

#include <libpq-fe.h>

#include <memory>
#include <stdexcept>
#include <string>
#include <utility>

namespace {

[[nodiscard]] std::string connection_error(PGconn* connection)
{
    if (connection == nullptr) {
        return "libpq could not allocate a database connection";
    }

    const char* message = PQerrorMessage(connection);
    return message == nullptr || *message == '\0' ? "PostgreSQL returned no error details" : message;
}

}

namespace pfd::database {

Connection::Connection(const std::string_view connection_info)
{
    const std::string null_terminated_connection_info{connection_info};
    connection_ = PQconnectdb(null_terminated_connection_info.c_str());

    if (connection_ == nullptr || PQstatus(connection_) != CONNECTION_OK) {
        const std::string message = connection_error(connection_);
        if (connection_ != nullptr) {
            PQfinish(connection_);
        }
        connection_ = nullptr;
        throw std::runtime_error{"PostgreSQL connection failed: " + message};
    }
}

Connection::~Connection() noexcept
{
    if (connection_ != nullptr) {
        PQfinish(connection_);
    }
}

Connection::Connection(Connection&& other) noexcept
    : connection_{std::exchange(other.connection_, nullptr)}
{
}

Connection& Connection::operator=(Connection&& other) noexcept
{
    if (this != &other) {
        if (connection_ != nullptr) {
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

void Connection::verify_health() const
{
    if (!is_open()) {
        throw std::runtime_error{"PostgreSQL connection is not open"};
    }

    using Result = std::unique_ptr<PGresult, decltype(&PQclear)>;
    const Result result{PQexec(connection_, "SELECT 1"), &PQclear};

    if (result == nullptr || PQresultStatus(result.get()) != PGRES_TUPLES_OK) {
        throw std::runtime_error{"PostgreSQL health query failed: " + connection_error(connection_)};
    }

    if (PQntuples(result.get()) != 1 || PQnfields(result.get()) != 1 ||
        std::string_view{PQgetvalue(result.get(), 0, 0)} != "1") {
        throw std::runtime_error{"PostgreSQL health query returned an unexpected result"};
    }
}

}
