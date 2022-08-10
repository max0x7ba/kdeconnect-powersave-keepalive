// Copyright (c) 2022 Maxim Egorushkin. MIT License. See the full licence in file LICENSE.
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <limits.h>
#include <dlfcn.h>
#include <cstdlib>
#ifndef NDEBUG
#   include <cstdio>
#endif

static int getenv_int(char const* env_name, int default_value) noexcept {
    if(char const* value_beg = getenv(env_name)) {
        char* value_end = const_cast<char*>(value_beg);
        auto value = strtoul(value_beg, &value_end, 0);
        if(!*value_end && value > 0 && value <= INT_MAX)
            return value;
#ifndef NDEBUG
        fprintf(stderr, "FORCE_TCP_KEEPALIVE_SECONDS_MIN: invalid environment variable value \"%s\".\n", value_beg);
#endif
    }
    return default_value;
}

int const force_tcp_keepalive_seconds_min = getenv_int("FORCE_TCP_KEEPALIVE_SECONDS_MIN", 9 * 60);
auto const next_setsockopt = reinterpret_cast<decltype(&setsockopt)>(dlsym(RTLD_NEXT, "setsockopt"));

int setsockopt(int fd, int level, int optname, void const* optval, socklen_t optlen) __THROW {
    if(level == IPPROTO_TCP && (optname == TCP_KEEPIDLE || optname == TCP_KEEPINTVL) && *static_cast<int const*>(optval) < force_tcp_keepalive_seconds_min) {
#ifndef NDEBUG
        fprintf(stderr, "FORCE_TCP_KEEPALIVE_SECONDS_MIN: replace option %d value %d with value %d.\n",
                optname, *static_cast<int const*>(optval), force_tcp_keepalive_seconds_min);
#endif
        optval = &force_tcp_keepalive_seconds_min;
    }
    return next_setsockopt(fd, level, optname, optval, optlen);
}
