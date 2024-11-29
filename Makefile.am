bin_PROGRAMS = HTTP_Server
HTTP_Server_SOURCES = src/server/main_Server.cpp src/server/HTTPServer.cpp src/TrigFunction.cpp
check_PROGRAMS = test_server
test_server_SOURCES = tests/test_server.cpp src/server/HTTPServer.cpp src/TrigFunction.cpp
test_server_LDFLAGS = -pthread
test_server_LDADD = -lgtest -lgtest_main
