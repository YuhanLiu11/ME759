
#include <iostream>
#include <chrono>
#include <ratio>

#include "scan.h"

using namespace std;


void Scan(const float *arr, float *output, std::size_t n) {
    output[0] = 0;

    for (size_t i = 1; i < n; i++) {
        output[i] = output[i - 1] + arr[i - 1];

    }


    return;
}
