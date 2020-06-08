#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include "scan.cuh"

int main(int argc, char *argv[]) {
    using namespace std;
    long n = atol(argv[1]);
    float *hA;
    float *out;
    hA = (float *)malloc(n * sizeof(float));
    out = (float *)malloc(n * sizeof(float));
    for (int i = 0; i < n; i++) {
        hA[i] = ((float)rand() / (RAND_MAX)) * 2 - 1;
        out[i] = 0;
    }
    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    scan(hA, out, n, 1024);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);

    cout << out[n-1] << endl;
    cout << ms << endl;
}