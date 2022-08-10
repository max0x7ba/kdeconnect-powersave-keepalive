// Copyright (c) 2022 Maxim Egorushkin. MIT License. See the full licence in file LICENSE.
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <cstdio>

int main() {
    int fd = socket(AF_INET, SOCK_STREAM, 0);

    int optval;
    socklen_t optlen = sizeof optval;
    getsockopt(fd, IPPROTO_TCP, TCP_KEEPIDLE, &optval, &optlen);
    printf("default TCP_KEEPIDLE %d\n", optval);

    optval = 1;
    setsockopt(fd, IPPROTO_TCP, TCP_KEEPIDLE, &optval, sizeof optval);

    optlen = sizeof optval;
    getsockopt(fd, IPPROTO_TCP, TCP_KEEPIDLE, &optval, &optlen);
    printf("new TCP_KEEPIDLE %d\n", optval);
}
