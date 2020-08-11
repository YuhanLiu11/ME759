#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "matmul.cuh"

int main(int argc, char** argv) {
    using namespace std;

    long int n = atol(argv[1]);
    int threads_per_block = atoi(argv[2]);
    float *A;
    float *B;
    float *C;
    cudaMallocManaged(&A, (n * n) * sizeof(float));
    cudaMallocManaged(&B, (n * n) * sizeof(float));
    cudaMallocManaged(&C, (n * n) * sizeof(float));
    for (int i = 0; i < n * n; i++) {
        A[i] = 1;
        B[i] = 1;
        // initialize C
        C[i] = 0;
    }
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    matmul(A, B, C, n, threads_per_block);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cout << C[n * n - 1] << endl;
    cout << milliseconds << endl;
    cudaFree(A);
    cudaFree(B);
    cudaFree(C);

}