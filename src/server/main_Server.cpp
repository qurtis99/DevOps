#include "HTTPServer.h"
#include <stdio.h>

int main() {
    if (CreateHTTPserver() != 0) {
        fprintf(stderr, "Failed to start the server.\n");
        return 1;
    }
    return 0;
}
