#pragma once

#include "pfd/database/QueryResult.hpp"

#include <cstddef>
#include <optional>
#include <span>
#include <string_view>

struct pg_conn;

namespace pfd::database
{

using Parameter = std::optional<std::string_view>;

class Connection final
{
public:
  explicit Connection(std::string_view connection_info);
  ~Connection() noexcept;

  Connection(const Connection &) = delete;
  Connection &operator=(const Connection &) = delete;

  Connection(Connection &&other) noexcept;
  Connection &operator=(Connection &&other) noexcept;

  [[nodiscard]] bool is_open() const noexcept;
  [[nodiscard]] QueryResult execute(std::string_view sql);
  [[nodiscard]] QueryResult execute_parameters(
      std::string_view sql,
      std::span<const Parameter> parameters);
  void prepare(
      std::string_view statement_name,
      std::string_view sql,
      std::size_t parameter_count);
  [[nodiscard]] QueryResult execute_prepared(
      std::string_view statement_name,
      std::span<const Parameter> parameters);
  void verify_health();

private:
  pg_conn *connection_{nullptr};
};

} // namespace pfd::database
