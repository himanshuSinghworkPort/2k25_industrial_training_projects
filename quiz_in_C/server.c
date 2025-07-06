// server.c
// Compile with: gcc server.c -o server.exe -lws2_32
//               (or MSVC: cl /EHsc server.c ws2_32.lib)

#include <winsock2.h>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#pragma comment(lib, "Ws2_32.lib")

#define SERVER_PORT 8080
#define MAXLINE     1024
#define QCOUNT      3

// Quiz questions and correct answers
const char *questions[QCOUNT] = {
    "1) What is the capital of France?\n(a) Paris   (b) London   (c) Berlin\n",
    "2) 2 + 2 x 2 = ?\n(a) 6        (b) 8       (c) 4\n",
    "3) Which language is this server written in?\n(a) Python  (b) C       (c) Java\n"
};
const char answers[QCOUNT] = { 'a', 'a', 'b' };

// Per-client data struct
typedef struct {
    SOCKET sock;
    char   ip[16];
} CLIENT_INFO;

// Thread function: runs one quiz session
DWORD WINAPI clientHandler(LPVOID param) {
    CLIENT_INFO *ci = (CLIENT_INFO*)param;
    SOCKET s        = ci->sock;
    char buf[MAXLINE];
    int  n, score = 0;

    // 1) Read login ID
    n = recv(s, buf, MAXLINE-1, 0);
    if (n <= 0) goto CLEANUP;
    buf[n] = '\0';
    char login[64];
    strncpy(login, buf, sizeof(login));

    // 2) Send welcome message
    snprintf(buf, sizeof(buf),
        "Welcome, %s!  Your IP is %s.\n"
        "You will be asked %d questions.\n\n",
        login, ci->ip, QCOUNT);
    send(s, buf, (int)strlen(buf), 0);

    // 3) Quiz loop
    for (int i = 0; i < QCOUNT; ++i) {
        send(s, questions[i], (int)strlen(questions[i]), 0);
        n = recv(s, buf, MAXLINE-1, 0);
        if (n <= 0) break;
        if (tolower(buf[0]) == answers[i]) score++;
    }

    // 4) Send result
    snprintf(buf, sizeof(buf),
        "\nQuiz over! You scored %d out of %d.\n",
        score, QCOUNT);
    send(s, buf, (int)strlen(buf), 0);

    // 5) Log on server console
    printf("Client %-10s (%s) scored %d/%d\n",
           login, ci->ip, score, QCOUNT);

CLEANUP:
    closesocket(s);
    free(ci);
    return 0;
}

int main(void) {
    WSADATA wsa;
    SOCKET   listenSock;
    struct   sockaddr_in servAddr, cliAddr;
    int      cliLen = sizeof(cliAddr);

    // 1) Start Winsock
    if (WSAStartup(MAKEWORD(2,2), &wsa) != 0) {
        fprintf(stderr, "WSAStartup failed\n");
        return 1;
    }

    // 2) Create listening socket
    listenSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenSock == INVALID_SOCKET) {
        perror("socket");
        WSACleanup();
        return 1;
    }

    // 3) Bind to all interfaces on SERVER_PORT
    servAddr.sin_family      = AF_INET;
    servAddr.sin_addr.s_addr = INADDR_ANY;
    servAddr.sin_port        = htons(SERVER_PORT);
    if (bind(listenSock, (SOCKADDR*)&servAddr, sizeof(servAddr)) == SOCKET_ERROR) {
        perror("bind");
        closesocket(listenSock);
        WSACleanup();
        return 1;
    }

    // 4) Listen
    if (listen(listenSock, 5) == SOCKET_ERROR) {
        perror("listen");
        closesocket(listenSock);
        WSACleanup();
        return 1;
    }
    printf("Server listening on port %d\n", SERVER_PORT);

    // 5) Accept loop
    while (1) {
        SOCKET clientSock = accept(
            listenSock,
            (SOCKADDR*)&cliAddr,
            &cliLen
        );
        if (clientSock == INVALID_SOCKET) {
            perror("accept");
            continue;
        }

        // Prepare client info for thread
        CLIENT_INFO *ci = malloc(sizeof(CLIENT_INFO));
        ci->sock = clientSock;
        strncpy(ci->ip,
                inet_ntoa(cliAddr.sin_addr),
                sizeof(ci->ip));

        // Spawn a thread to handle this client
        HANDLE h = CreateThread(
            NULL, 0,
            clientHandler,
            ci, 0, NULL
        );
        if (!h) {
            perror("CreateThread");
            closesocket(clientSock);
            free(ci);
        } else {
            CloseHandle(h);
        }
    }

    // Cleanup (never reached)
    closesocket(listenSock);
    WSACleanup();
    return 0;
}
