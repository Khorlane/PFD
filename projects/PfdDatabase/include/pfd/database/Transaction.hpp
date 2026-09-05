#pragma once

namespace pfd::database
{

class Connection;

class Transaction final
{
public:
  explicit Transaction(Connection &connection);
  ~Transaction() noexcept;

  Transaction(const Transaction &) = delete;
  Transaction &operator=(const Transaction &) = delete;

  Transaction(Transaction &&other) noexcept;
  Transaction &operator=(Transaction &&other) = delete;

  [[nodiscard]] bool is_active() const noexcept;
  void commit();
  void rollback();

private:
  Connection *connection_{nullptr};
  bool active_{false};
};

} // namespace pfd::database
