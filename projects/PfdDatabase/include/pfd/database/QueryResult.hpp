#pragma once

#include <cstddef>
#include <cstdint>
#include <optional>
#include <string_view>

struct pg_result;

namespace pfd::database
{

enum class ResultStatus
{
  empty_query,
  command_ok,
  tuples_ok,
  copy_out,
  copy_in,
  bad_response,
  nonfatal_error,
  fatal_error,
  copy_both,
  single_tuple,
  pipeline_sync,
  pipeline_aborted,
  unknown,
};

class QueryResult final
{
public:
  ~QueryResult() noexcept;

  QueryResult(const QueryResult &) = delete;
  QueryResult &operator=(const QueryResult &) = delete;

  QueryResult(QueryResult &&other) noexcept;
  QueryResult &operator=(QueryResult &&other) noexcept;

  [[nodiscard]] ResultStatus status() const noexcept;
  [[nodiscard]] std::string_view status_name() const noexcept;
  [[nodiscard]] std::string_view command_tag() const noexcept;
  [[nodiscard]] std::optional<std::uint64_t> affected_rows() const noexcept;
  [[nodiscard]] std::size_t row_count() const noexcept;
  [[nodiscard]] std::size_t column_count() const noexcept;
  [[nodiscard]] std::string_view column_name(std::size_t column) const;
  [[nodiscard]] bool is_null(std::size_t row, std::size_t column) const;
  [[nodiscard]] std::string_view value(std::size_t row, std::size_t column) const;

private:
  friend class Connection;
  explicit QueryResult(pg_result *result) noexcept;

  pg_result *result_{nullptr};
};

} // namespace pfd::database
