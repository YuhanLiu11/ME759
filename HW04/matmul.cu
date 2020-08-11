#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "matmul.cuh"

__global__ void matmul_kernel(const float* A, const float* B, float* C, size_t n) {

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= n*n) return;
    int i = index / n;
    int j = index % n;
    float Pvalue = 0;
    for (size_t k = 0; k < n; k++) {
        Pvalue += A[i * n + k] * B[k * n + j];
    }
    C[i * n + j] = Pvalue;
}


void matmul(const float* A, const float* B, float* C, size_t n, unsigned int threads_per_block) {
    memset(C, 0, (n * n) * sizeof(float));

    int blockNum = (n * n + threads_per_block - 1) / threads_per_block;

    matmul_kernel <<<blockNum, threads_per_block>>> (A, B, C, n);
    cudaDeviceSynchronize();
}