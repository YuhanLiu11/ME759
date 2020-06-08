#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "vadd.cuh"

#define BLOCK_SIZE 512


int main(int argc, char** argv) {
    using namespace std;
    int N = atoi(argv[1]);
    float *a = (float *)malloc(N * sizeof(float));
    float *b = (float *)malloc(N * sizeof(float));
    for(int i = 0; i < N; i++) {
        a[i] = 1;
        b[i] = 1;
    }
    int block = N / BLOCK_SIZE + 1;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float *dA;
    float *dB;
    cudaMalloc(&dA, N * sizeof(float));
    cudaMalloc(&dB, N * sizeof(float));
    cudaMemcpy(dA, a, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dB, b, N*sizeof(float), cudaMemcpyHostToDevice);

    cudaEventRecord(start);
    vadd <<< block, BLOCK_SIZE >>>(dA, dB, N);

    cudaDeviceSynchronize();


    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);


    float *result = (float *)malloc( N * sizeof(float));
    cudaMemcpy(result, dB, N*sizeof(float), cudaMemcpyDeviceToHost);

    cout << milliseconds / 1000 << endl;
    cout << result[0] << endl;
    cout << result[N-1] << endl;
    free(result);
    free(b);

    free(a);
    cudaFree(&dB);
    cudaFree(&dA);

    return 0;
}