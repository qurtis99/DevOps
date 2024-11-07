#include "TrigFunction.h"
#include <cmath>

double TrigFunction::FuncA(double x, int n) {
    int n = 3; //обчислення перших 3
    double result = 0.0;
    for (int i = 0; i < n; ++i) {
        double term = (std::tgamma(2 * i + 1 + 1) /
                       (std::pow(4, i) * std::pow(std::tgamma(i + 1), 2) * (2 * i + 1)))
                       * std::pow(x, 2 * i + 1);
        result += term;
    }
    return result;
}
