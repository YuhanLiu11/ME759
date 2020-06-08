#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "scan.cuh"
#include "../include/driver_types.h"

__global__ void scan(float *g_odata, float *g_idata, int n) {
    using namespace std;
    extern volatile __shared__  float temp[]; // allocated on invocation

    int thid = threadIdx.x;
    int pout = 0, pin = 1;
    // load input into shared memory.
    // **exclusive** scan: shift right by one element and set first output to 0
    int global_index = blockIdx.x * blockDim.x + thid;
    if (global_index >= n) {
        temp[thid] = 0;
    } else {
        temp[thid] = g_idata[global_index];
    }

    __syncthreads();




    for( int offset = 1; offset<blockDim.x; offset *= 2 ) {
        pout = 1 - pout; // swap double buffer indices
        pin  = 1 - pout;

        if (thid >= offset)
            temp[pout * blockDim.x + thid] = temp[pin * blockDim.x + thid] + temp[pin * blockDim.x + thid - offset];
        else
            temp[pout*blockDim.x+thid] = temp[pin*blockDim.x+thid];

        __syncthreads(); // I need this here before I start next iteration
    }
    if (pout * blockDim.x + thid < blockDim.x)
        g_odata[global_index] = temp[pout * n + thid];

}

__global__ void copy(float *dOut, float *num_blocks_out, int n, int threads_per_block) {
    int index = (threadIdx.x + 1) * threads_per_block - 1;
    if (index >= n)
        index = n - 1;
//    using namespace std;
//    std::printf("in copy: %f\n", dOut[index]);
    num_blocks_out[threadIdx.x] = dOut[index];
}
__global__ void add(float *num_blocks_out, float *first_output, int n, float *dFinal) {

    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index >= n)
        return;
    if (blockIdx.x == 0)
        dFinal[index] = first_output[index];
    else
        dFinal[index] = first_output[index] + num_blocks_out[blockIdx.x - 1];

}
__host__ void scan(const float* in, float* out, unsigned int n, unsigned int threads_per_block) {
    using namespace std;

    float *dIn;
    float *dOut;
    cudaMalloc(&dIn, n * sizeof(float));
    cudaMemcpy(dIn, in, n * sizeof(float), cudaMemcpyHostToDevice);
    cudaMalloc(&dOut, n * sizeof(float));
    int num_blocks = (n + threads_per_block - 1) / threads_per_block;
    scan <<< num_blocks, threads_per_block, 2 * threads_per_block * sizeof(float) >>> (dOut, dIn, n);
    float *hOut = (float *)malloc(n * sizeof(float));
    cudaMemcpy(hOut, dOut, n * sizeof(float), cudaMemcpyDeviceToHost);

    float *temp_out;
    cudaMalloc(&temp_out, num_blocks * sizeof(float));
    copy <<<1, num_blocks>>> (dOut, temp_out, n, threads_per_block);





    float *second_output;
    cudaMalloc(&second_output, num_blocks * sizeof(float));
    scan <<< 1, threads_per_block, 2 * threads_per_block * sizeof(float) >>> (second_output, temp_out, num_blocks);


//    float *final_output_host = (float *)malloc(num_blocks * sizeof(float));
//    cudaMemcpy(final_output_host, second_output, num_blocks * sizeof(float), cudaMemcpyDeviceToHost);
//    for (int i = 0; i < num_blocks; i++) {
//        std::printf("second scan: %f\n", final_output_host[i]);
//    }
//    float *first_output_host = (float *)malloc(n * sizeof(float));
//    cudaMemcpy(first_output_host, dOut, n * sizeof(float), cudaMemcpyDeviceToHost);
//    for (int i = 0; i < n; i++) {
//        std::printf("first scan: %d %f\n", i, first_output_host[i]);
//    }


    float *dFinal;
    cudaMalloc(&dFinal, n * sizeof(float));
    add <<< num_blocks, threads_per_block >>> (second_output, dOut, n, dFinal);
    out[0] = 0;
    cudaMemcpy(out + 1, dFinal, (n - 1) * sizeof(float), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();

    cudaFree(dIn);
    cudaFree(dOut);
    free(hOut);
    cudaFree(temp_out);
    cudaFree(second_output);
    cudaFree(dFinal);

}