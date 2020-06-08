#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "reduce.cuh"
__global__ void reduce_kernel(const int* g_idata, int* g_odata, unsigned int n) {
    extern __shared__ int sdata[];
    using namespace std;
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= n) {
        sdata[threadIdx.x] = 0;
    } else {
        sdata[threadIdx.x] = g_idata[index];
    }

    __syncthreads();

    for(unsigned int s = blockDim.x/2; s > 0; s >>= 1) {
        if(threadIdx.x < s) {
            sdata[threadIdx.x] += sdata[threadIdx.x + s];
        }
        __syncthreads();
    }
    if(threadIdx.x == 0) g_odata[blockIdx.x] = sdata[0];

}


__host__ int reduce(const int* arr, unsigned int N, unsigned int threads_per_block) {
    int *g_idata;
    int *g_odata;
    using namespace std;
    cudaMalloc(&g_idata, N * sizeof(int));

    cudaMemcpy(g_idata, arr, N * sizeof(int), cudaMemcpyHostToDevice);


    for (int l = N; l > 1; l = (l + threads_per_block - 1) / threads_per_block) {
        int block_num = (l + threads_per_block - 1) / threads_per_block;
        cudaMalloc(&g_odata, block_num * sizeof(int));
        reduce_kernel<<<block_num, threads_per_block, threads_per_block * sizeof(int) >>>(g_idata, g_odata, l);


        cudaMemcpy(g_idata, g_odata, block_num * sizeof(int), cudaMemcpyDeviceToDevice);

    }

    cudaDeviceSynchronize();

    int res;
    cudaMemcpy(&res, g_odata, sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(g_odata);
    cudaFree(g_idata);

    return res;
}