#include "../src/TrigFunction.h"
#include <iostream>
#include <cassert>

int main() {
    double test_values[] = {0.0, 0.5, 1.0}; // Example values to test
    int n = 10; // Example series term count

    // Create an instance of TrigFunction to call the non-static method
    TrigFunction trig_func;

    // Perform tests on FuncA
    // Replace these expected values with actual values based on the logic of FuncA
    double expected_result_1 = 1.0;  // Expected result for test_values[0]
    double expected_result_2 = 1.0;  // Expected result for test_values[1]
    double expected_result_3 = 0.5403;  // Expected result for test_values[2]

    assert(trig_func.FuncA(test_values[0], n) == expected_result_1);
    assert(trig_func.FuncA(test_values[1], n) == expected_result_2);
    assert(trig_func.FuncA(test_values[2], n) == expected_result_3);

    std::cout << "All tests passed successfully!" << std::endl;
    return 0;
}

