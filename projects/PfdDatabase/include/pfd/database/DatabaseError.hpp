#pragma once

#include <stdexcept>
#include <string>

namespace pfd::database
{

class DatabaseError final : public std::runtime_error
{
public:
  DatabaseError(
      std::string message,
      std::string sql_state = {},
      std::string severity = {},
      std::string detail = {},
      std::string hint = {},
      std::string context = {});

  [[nodiscard]] const std::string &sql_state() const noexcept;
  [[nodiscard]] const std::string &severity() const noexcept;
  [[nodiscard]] const std::string &detail() const noexcept;
  [[nodiscard]] const std::string &hint() const noexcept;
  [[nodiscard]] const std::string &context() const noexcept;

private:
  std::string sql_state_;
  std::string severity_;
  std::string detail_;
  std::string hint_;
  std::string context_;
};

} // namespace pfd::database
