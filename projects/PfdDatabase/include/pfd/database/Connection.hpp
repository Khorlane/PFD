#pragma once

#include <string_view>

struct pg_conn;

namespace pfd::database {

class Connection final {
public:
    explicit Connection(std::string_view connection_info);
    ~Connection() noexcept;

    Connection(const Connection&) = delete;
    Connection& operator=(const Connection&) = delete;

    Connection(Connection&& other) noexcept;
    Connection& operator=(Connection&& other) noexcept;

    [[nodiscard]] bool is_open() const noexcept;
    void verify_health() const;

private:
    pg_conn* connection_{nullptr};
};

}
