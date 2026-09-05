#include "pfd/database/Transaction.hpp"

#include "pfd/database/Connection.hpp"

#include <stdexcept>
#include <utility>

namespace pfd::database
{

Transaction::Transaction(Connection &connection)
    : connection_{&connection}
{
  static_cast<void>(connection_->execute("BEGIN"));
  active_ = true;
}

Transaction::~Transaction() noexcept
{
  if (active_ && connection_ != nullptr)
  {
    try
    {
      static_cast<void>(connection_->execute("ROLLBACK"));
    }
    catch (...)
    {
    }
  }
}

Transaction::Transaction(Transaction &&other) noexcept
    : connection_{std::exchange(other.connection_, nullptr)},
      active_{std::exchange(other.active_, false)}
{
}

bool Transaction::is_active() const noexcept
{
  return active_;
}

void Transaction::commit()
{
  if (!active_ || connection_ == nullptr)
  {
    throw std::logic_error{"Cannot commit an inactive PostgreSQL transaction"};
  }

  static_cast<void>(connection_->execute("COMMIT"));
  active_ = false;
}

void Transaction::rollback()
{
  if (!active_ || connection_ == nullptr)
  {
    throw std::logic_error{"Cannot roll back an inactive PostgreSQL transaction"};
  }

  static_cast<void>(connection_->execute("ROLLBACK"));
  active_ = false;
}

} // namespace pfd::database
