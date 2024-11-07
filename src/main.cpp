#include <iostream>
#include "TrigFunction.h"

int main() {
    TrigFunction trig;
    double x = 0.5; // Значення для x (в межах -1 < x < 1)
    int n = 10;     // Кількість членів для наближення

    std::cout << "Approximation of arcsin(" << x << ") with " << n << " terms: "
              << trig.FuncA(x, n) << std::endl;
    return 0;
}
