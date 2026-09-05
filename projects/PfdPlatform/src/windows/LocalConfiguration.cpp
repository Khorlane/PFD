#include "pfd/platform/LocalConfiguration.hpp"

#include <ShlObj.h>

#include <filesystem>
#include <fstream>
#include <iterator>
#include <memory>
#include <stdexcept>
#include <string>

namespace pfd::platform
{

std::string load_local_database_connection_string()
{
  PWSTR raw_local_app_data = nullptr;
  if (FAILED(SHGetKnownFolderPath(FOLDERID_LocalAppData, KF_FLAG_DEFAULT, nullptr, &raw_local_app_data)))
  {
    throw std::runtime_error{"Windows could not locate the local application-data directory"};
  }

  const std::unique_ptr<wchar_t, decltype(&CoTaskMemFree)> local_app_data{raw_local_app_data, &CoTaskMemFree};
  const std::filesystem::path config_path =
      std::filesystem::path{local_app_data.get()} / L"PFD" / L"config" / L"database.local.conf";

  std::ifstream input{config_path, std::ios::binary};
  if (!input)
  {
    throw std::runtime_error{"PFD local database configuration was not found"};
  }

  std::string connection_string{std::istreambuf_iterator<char>{input}, std::istreambuf_iterator<char>{}};
  if (connection_string.starts_with("\xEF\xBB\xBF"))
  {
    connection_string.erase(0, 3);
  }

  while (!connection_string.empty() &&
         (connection_string.back() == '\r' || connection_string.back() == '\n'))
  {
    connection_string.pop_back();
  }

  if (connection_string.empty())
  {
    throw std::runtime_error{"PFD local database configuration is empty"};
  }

  return connection_string;
}

} // namespace pfd::platform
