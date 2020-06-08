#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "mmul.h"

void mmul(cublasHandle_t handle, const float* A, const float* B, float* C, int n) {
    int lda = n;
    int ldb = n;
    int ldc = n;
    const float bet = 1;
    const float alf = 1;

    const float *alpha = &alf;
    const float *beta = &bet;
//    cublasSetMathMode(handle, CUBLAS_TENSOR_OP_MATH);
    cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, n, n, n, alpha, A, lda, B, ldb, beta, C, ldc);
    cudaDeviceSynchronize();

}