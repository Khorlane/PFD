#include "pfd/database/Component.hpp"
#include "pfd/database/Connection.hpp"
#include "pfd/database/Transaction.hpp"
#include "pfd/domain/Component.hpp"
#include "pfd/platform/Component.hpp"
#include "pfd/platform/LocalConfiguration.hpp"
#include "pfd/reporting/Component.hpp"
#include "pfd/simulation/Component.hpp"

#include <array>
#include <exception>
#include <iostream>
#include <string_view>

int main()
{
  constexpr std::size_t expected_component_count = 5;
  const std::array<std::string_view, expected_component_count> components{
      pfd::domain::component_name(),
      pfd::database::component_name(),
      pfd::simulation::component_name(),
      pfd::reporting::component_name(),
      pfd::platform::component_name(),
  };

  for (const auto component : components)
  {
    if (component.empty())
    {
      std::cerr << "A PFD component did not identify itself.\n";
      return 1;
    }
  }

  try
  {
    const std::string connection_string = pfd::platform::load_local_database_connection_string();
    pfd::database::Connection connection{connection_string};
    connection.verify_health();

    const std::array<pfd::database::Parameter, 2> calculation_parameters{
        std::string_view{"19"},
        std::string_view{"23"},
    };
    const auto calculation = connection.execute_parameters(
        "SELECT $1::integer + $2::integer AS answer",
        calculation_parameters);
    if (calculation.row_count() != 1 || calculation.column_name(0) != "answer" ||
        calculation.is_null(0, 0) || calculation.value(0, 0) != "42")
    {
      std::cerr << "Parameterized query returned an unexpected result.\n";
      return 1;
    }

    connection.prepare("pfd_smoke_text", "SELECT $1::text, $2::text", 2);
    const std::array<pfd::database::Parameter, 2> prepared_parameters{
        std::string_view{"prepared"},
        std::nullopt,
    };
    const auto prepared = connection.execute_prepared("pfd_smoke_text", prepared_parameters);
    if (prepared.value(0, 0) != "prepared" || !prepared.is_null(0, 1))
    {
      std::cerr << "Prepared query returned an unexpected result.\n";
      return 1;
    }

    {
      pfd::database::Transaction transaction{connection};
      static_cast<void>(connection.execute("SELECT 1"));
      transaction.commit();
    }
    {
      pfd::database::Transaction transaction{connection};
      transaction.rollback();
    }
    {
      pfd::database::Transaction automatic_rollback{connection};
      if (!automatic_rollback.is_active())
      {
        std::cerr << "Transaction did not become active.\n";
        return 1;
      }
    }

    std::cout << "PFD PostgreSQL access-layer smoke check passed.\n";
    return 0;
  }
  catch (const std::exception &error)
  {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
