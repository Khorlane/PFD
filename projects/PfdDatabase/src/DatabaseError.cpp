#include "pfd/database/DatabaseError.hpp"

#include <utility>

namespace pfd::database
{

DatabaseError::DatabaseError(
    std::string message,
    std::string sql_state,
    std::string severity,
    std::string detail,
    std::string hint,
    std::string context)
    : std::runtime_error{std::move(message)},
      sql_state_{std::move(sql_state)},
      severity_{std::move(severity)},
      detail_{std::move(detail)},
      hint_{std::move(hint)},
      context_{std::move(context)}
{
}

const std::string &DatabaseError::sql_state() const noexcept
{
  return sql_state_;
}

const std::string &DatabaseError::severity() const noexcept
{
  return severity_;
}

const std::string &DatabaseError::detail() const noexcept
{
  return detail_;
}

const std::string &DatabaseError::hint() const noexcept
{
  return hint_;
}

const std::string &DatabaseError::context() const noexcept
{
  return context_;
}

} // namespace pfd::database
