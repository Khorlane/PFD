#include "pfd/database/Component.hpp"
#include "pfd/domain/Component.hpp"
#include "pfd/platform/Component.hpp"
#include "pfd/reporting/Component.hpp"
#include "pfd/simulation/Component.hpp"

#include <array>
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

    for (const auto component : components) {
        if (component.empty()) {
            std::cerr << "A PFD component did not identify itself.\n";
            return 1;
        }
    }

    std::cout << "PFD project scaffold tests passed.\n";
    return 0;
}
