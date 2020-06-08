#include "matmul.h"

void mmul(const float* A, const float* B, float* C, const std::size_t n)
{
    for (size_t i = 0; i < n * n; i++) {
        C[i] = 0;
    }
#pragma omp parallel for collapse(2)
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            for (size_t k = 0; k < n; k++) {
                C[i * n + j] += A[i * n + k] * B[j * n + k];
            }
        }
    }
}
