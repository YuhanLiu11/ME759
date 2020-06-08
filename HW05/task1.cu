#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "reduce.cuh"
int main(int argc, char *argv[]) {
    using namespace std;
    long n = atol(argv[1]);
    long threads_per_block = atol(argv[2]);

    auto arr = new int[n];

    for (int i = 0; i < n; i++) {
        arr[i] = 1;
    }

    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    int res = reduce(arr, n, threads_per_block);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);

    cout << res << endl;
    cout << ms << endl;
}