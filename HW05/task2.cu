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

    long n = atol(argv[1]);
    int block_dim = atoi(argv[2]);
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
    unsigned int N = (unsigned int) n;
    matmul(A, B, C, N, block_dim);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cout << C[0] << endl;
    cout << C[n * n - 1] << endl;
    cout << milliseconds << endl;





    cudaFree(A);
    cudaFree(B);
    cudaFree(C);

}