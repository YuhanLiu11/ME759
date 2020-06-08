#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "mmul.h"
#include "../include/cublas_v2.h"

int main(int argc, char *argv[]) {
    using namespace std;
    long n = atol(argv[1]);
    int n_ntests = atol(argv[2]);
    float *A;
    float *B;
    float *C;

    cudaMallocManaged(&A, (n * n) * sizeof(float));
    cudaMallocManaged(&B, (n * n) * sizeof(float));
    cudaMallocManaged(&C, (n * n) * sizeof(float));


    float total_time = 0;
    for (int i = 0; i < n * n; i++) {
        A[i] = 1;
        B[i] = 1;

    }



    for (int time = 0; time < n_ntests; time++) {

        cudaEvent_t start;
        cudaEvent_t stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        cudaEventRecord(start);

        cublasHandle_t handle ;
        cublasCreate(&handle);
        mmul(handle, A, B, C, n);
        cublasDestroy(handle);



        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        float ms;
        cudaEventElapsedTime(&ms, start, stop);
        total_time += ms;
        for (int i = 0; i < n * n; i++) {
            C[i] = 0;
        }

    }
    cout << total_time / n_ntests << endl;
    cudaFree(A);
    cudaFree(B);
    cudaFree(C);
}