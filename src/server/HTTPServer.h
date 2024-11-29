#ifndef HTTP_SERVER_H
#define HTTP_SERVER_H

int CreateHTTPserver();
void handleClient(int clientSocket);
void handleCompute(int clientSocket);
void sendResponse(int clientSocket, const char* header, const char* body);

#endif
