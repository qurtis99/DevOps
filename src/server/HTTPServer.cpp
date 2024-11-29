#include "HTTPServer.h"
#include "../TrigFunction.h"
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <vector>
#include <chrono>
#include <algorithm>

#define PORT 8081

// HTTP headers
const char* HTTP_200HEADER = "HTTP/1.1 200 OK\r\n";
const char* HTTP_400HEADER = "HTTP/1.1 400 Bad Request\r\n";

int CreateHTTPserver() {
    int serverSocket, clientSocket;
    struct sockaddr_in address;
    int addrlen = sizeof(address);

    // Create the server socket
    if ((serverSocket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Configure the server address
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    // Bind the socket to the address and port
    if (bind(serverSocket, (struct sockaddr*)&address, sizeof(address)) < 0 ||
        listen(serverSocket, 10) < 0) {
        perror("Binding or listening failed");
        close(serverSocket);
        exit(EXIT_FAILURE);
    }

    // Wait for incoming connections
    while (true) {
        printf("Waiting for connection...\n");

        // Accept incoming connections
        if ((clientSocket = accept(serverSocket, (struct sockaddr*)&address, (socklen_t*)&addrlen)) < 0) {
            perror("Accept failed");
            continue;
        }

        printf("Connection accepted.\n");

        // Fork a child process to handle the client
        if (fork() == 0) {
            close(serverSocket);
            handleClient(clientSocket);
            close(clientSocket);
            exit(0);
        }

        close(clientSocket);
    }

    close(serverSocket);
    return 0;
}

void handleClient(int clientSocket) {
    char buffer[30000] = {0};
    
    // Read the incoming request
    ssize_t bytesRead = read(clientSocket, buffer, sizeof(buffer));

    if (bytesRead <= 0) {
        printf("Failed to read client data. Bytes read: %zd\n", bytesRead);
        return;
    }

    printf("Received request: \n%s\n", buffer);

    // Parse the HTTP request
    char method[10] = {0}, path[200] = {0};
    sscanf(buffer, "%s %s", method, path);

    printf("Method: %s, Path: %s\n", method, path);

    // Handle only GET requests
    if (strcmp(method, "GET") == 0) {
        if (strcmp(path, "/compute") == 0) {
            printf("Handling /compute route...\n");
            handleCompute(clientSocket);
        } else {
            printf("Invalid path: %s\n", path);
            sendResponse(clientSocket, HTTP_400HEADER, "Invalid path");
        }
    } else {
        printf("Invalid method: %s\n", method);
        sendResponse(clientSocket, HTTP_400HEADER, "Invalid method");
    }

    // Ensure the socket is closed after handling the request
    close(clientSocket);
}

void handleCompute(int clientSocket) {
    // Start timing
    auto start = std::chrono::high_resolution_clock::now();

    // Simplify the computation for debugging
    std::vector<double> values(100000);
    TrigFunction trig;

    for (size_t i = 0; i < values.size(); ++i)
        values[i] = trig.FuncA(0.5, i % 20 + 0.1); // Just a simple calculation

    for (int i = 0; i < 11111; ++i)  // Reduce the number of sorts for testing
        std::sort(values.begin(), values.end()); // Sort less for testing

    auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(
                       std::chrono::high_resolution_clock::now() - start)
                       .count(); // Calculate elapsed time

    // Formulate the response body
    char body[50];
    sprintf(body, "Elapsed time: %ld ms", elapsed);

    // Send the response back to the client
    sendResponse(clientSocket, HTTP_200HEADER, body);
}

void sendResponse(int clientSocket, const char* header, const char* body) {
    char response[500];
// Calculate content length (length of body)
    int contentLength = strlen(body);
    
    // Ensure the response header is properly formatted
    sprintf(response, "%sContent-Length: %d\r\n\r\n%s", header, contentLength, body);
    
    // Log the entire response before sending
    printf("Sending response:\n%s\n", response);
    
    // Send the response to the client using send()
    ssize_t bytesSent = send(clientSocket, response, strlen(response), 0);

    if (bytesSent == -1) {
        perror("Failed to send response");
    } else {
        printf("Response sent successfully, %ld bytes\n", bytesSent);
    }
}
