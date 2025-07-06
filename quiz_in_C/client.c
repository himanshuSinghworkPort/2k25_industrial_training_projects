// client.c
// Compile with: gcc client.c -o client.exe -lws2_32
//               (or MSVC: cl /EHsc client.c ws2_32.lib)

#include <winsock2.h>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#pragma comment(lib, "Ws2_32.lib")

#define SERVER_PORT 8080
#define MAXLINE     1024
#define QCOUNT      3

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <server-ip> <login-id>\n", argv[0]);
        return 1;
    }

    const char *server_ip = argv[1];
    const char *login     = argv[2];
    WSADATA wsa;
    SOCKET  sock;
    struct  sockaddr_in servAddr;
    char    buf[MAXLINE];
    int     n;

    // 1) Initialize Winsock
    if (WSAStartup(MAKEWORD(2,2), &wsa) != 0) {
        fprintf(stderr, "WSAStartup failed\n");
        return 1;
    }

    // 2) Create socket
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) {
        perror("socket");
        WSACleanup();
        return 1;
    }

    // 3) Fill server address
    servAddr.sin_family      = AF_INET;
    servAddr.sin_addr.s_addr = inet_addr(server_ip);
    servAddr.sin_port        = htons(SERVER_PORT);

    // 4) Connect
    if (connect(sock,
                (SOCKADDR*)&servAddr,
                sizeof(servAddr)) == SOCKET_ERROR)
    {
        perror("connect");
        closesocket(sock);
        WSACleanup();
        return 1;
    }

    // 5) Send login ID (no newline needed)
    send(sock, login, (int)strlen(login), 0);

    // 6) Read & print welcome
    n = recv(sock, buf, MAXLINE-1, 0);
    if (n <= 0) goto CLEANUP;
    buf[n] = '\0';
    printf("%s", buf);

    // 7) Quiz loop
    for (int i = 0; i < QCOUNT; ++i) {
        // Read question
        n = recv(sock, buf, MAXLINE-1, 0);
        if (n <= 0) break;
        buf[n] = '\0';
        printf("%s", buf);

        // Prompt and flush
        printf("Your answer: ");
        fflush(stdout);

        // Read user input
        if (!fgets(buf, sizeof(buf), stdin)) break;
        send(sock, buf, (int)strlen(buf), 0);
    }

    // 8) Read & print result
    n = recv(sock, buf, MAXLINE-1, 0);
    if (n > 0) {
        buf[n] = '\0';
        printf("%s", buf);
    }

CLEANUP:
    closesocket(sock);
    WSACleanup();
    return 0;
}
