
#include <iostream>
#include <chrono>
#include <ratio>

#include "convolution.h"

using namespace std;


void Convolve(const float *image, float *output, std::size_t n, const float *mask, std::size_t m) {
    for(size_t i = 0; i < n * n; i++) {
        output[i] = 0;
    }
    std::size_t M = (m-1)/2; // m is always odd
#pragma omp parallel for collapse(2)
    for(size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {

            for (size_t a = 0; a <= m - 1; a++) {
                for (size_t b = 0; b <= m - 1; b++) {
                    int image_i = i + a - M;
                    int image_j = j + b - M;
                    float f = 0;
                    if(image_i <0 || image_i >= int(n) ||
                       image_j < 0 || image_j >= int(n))
                        f = 0;
                    else {
                        f = image[image_i * n + image_j];
                    }
                    output[i * n + j] += f * mask[a * m + b];
                }
            }
        }
    }



}
