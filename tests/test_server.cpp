#include <gtest/gtest.h>
#include <cstdlib>
#include <cstdio>

TEST(HTTPServerTest, ServerResponse) {
    // Запустити сервер
    system("./HTTP_Server &");
    sleep(1); // Додайте затримку для запуску сервера

    // Зробити запит до сервера
    FILE* pipe = popen("curl -s -X GET http://localhost:8081/compute", "r");
    ASSERT_TRUE(pipe != nullptr);

    char buffer[128];
    std::string result;
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    pclose(pipe);

    // Перевірити відповідь сервера
    EXPECT_NE(result.find("Elapsed time:"), std::string::npos);
}
