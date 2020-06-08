

#include <iostream>
#include <chrono>
#include <ratio>

#include "matmul.h"

using namespace std;


void mmul1(const double* A, const double* B, double* C, const std::size_t n) {
    for(size_t i = 0; i < n * n; i++) {
        C[i] = 0;
    }
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            for (size_t k = 0; k < n; k++) {
                C[i*n + j] += A[i*n + k] * B[k*n + j];
            }
        }
    }
}

void mmul2(const double* A, const double* B, double* C, const std::size_t n) {
    for(size_t i = 0; i < n * n; i++) {
        C[i] = 0;
    }
    for (size_t j = 0; j < n; j++) {
        for (size_t i = 0; i < n; i++) {
            for (size_t k = 0; k < n; k++) {
                C[i*n + j] += A[i*n + k] * B[k*n + j];
            }
        }
    }
}

void mmul3(const double* A, const double* B, double* C, const std::size_t n) {
    for(size_t i = 0; i < n * n; i++) {
        C[i] = 0;
    }
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            for (size_t k = 0; k < n; k++) {
                C[i*n + j] += A[i*n + k] * B[j*n + k];
            }
        }
    }


}


void mmul4(const double* A, const double* B, double* C, const std::size_t n) {
    for(size_t i = 0; i < n * n; i++) {
        C[i] = 0;
    }
    for (size_t i = 0; i < n; i++) {
        for (size_t j = 0; j < n; j++) {
            for (size_t k = 0; k < n; k++) {
                C[i*n + j] += A[k*n + i] * B[k*n + j];
            }
        }
    }
}