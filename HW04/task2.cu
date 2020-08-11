#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "stencil.cuh"

int main(int argc, char** argv) {
    using namespace std;

    long n = stol(argv[1]);
    int R = atoi(argv[2]);
    int threads_per_block = atoi(argv[3]);
    float *image;
    float *mask;
    float *output;
    cudaMallocManaged(&image, n * sizeof(float));
    cudaMallocManaged(&mask, (2 * R + 1) * sizeof(float));
    cudaMallocManaged(&output, n * sizeof(float));

    for (int i= 0; i < n; i++){
        image[i] = 1;
        output[i] = 0;
    }
    for (int i= 0; i < (2*R + 1); i++){
            mask[i] = 1;
    }
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    stencil(image, mask, output, n, R, threads_per_block);

    cout << output[n - 1] << endl;
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cout << milliseconds << endl;
    cudaFree(image);
    cudaFree(mask);
    cudaFree(output);
}