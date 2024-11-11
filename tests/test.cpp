#include "../src/TrigFunction.h"
#include <iostream>
#include <cassert>

int main() {
    double test_values[] = {0.0, 0.5, 1.0}; // Example values to test
    int n = 10; // Example series term count

    // Perform tests
    assert(TrigFunction::FuncA(test_values[0], n) == /* expected result */);
    assert(TrigFunction::FuncA(test_values[1], n) == /* expected result */);
    assert(TrigFunction::FuncA(test_values[2], n) == /* expected result */);

    std::cout << "All tests passed successfully!" << std::endl;
    return 0;
}
