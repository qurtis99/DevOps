#include "./src/TrigFunction.h"
#include <cassert>

int main() {
    TrigFunction trigFunc;  // Create an instance of TrigFunction
    double test_values[] = {0.5, 1.0, 1.5};
    int n = 10;

    // Add test cases and expected results
    assert(trigFunc.FuncA(test_values[0], n) == 1);  // Replac
    assert(trigFunc.FuncA(test_values[1], n) == 2);  // Replace with actual expected value
    assert(trigFunc.FuncA(test_values[2], n) == 3);  // Replace with actual expected value

    return 0;
}
