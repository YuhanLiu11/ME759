#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "matmul.cuh"

__global__ void matmul_kernel(const float* A, const float* B, float* C, unsigned int n) {
    using namespace std;

    extern __shared__ float s[];


    float *shared_A = s;
    float *shared_B = (float *)&shared_A[(blockDim.x * blockDim.y)];
    int bx = blockIdx.x;
    int by = blockIdx.y; // the row index of the block
    int index = n * blockDim.y * by + blockDim.x * bx + n* threadIdx.y + threadIdx.x;
//    std::printf("index: %f\n", A[n*n-1]);

    if (index >= n*n)
        return;

    int aBegin = n * blockDim.x * by; // (by * blockDim.x, 0) index in A
    int bBegin = blockDim.y * bx;  //
    int aEnd = n + aBegin - 1;
    int aStep = blockDim.x;
    int bStep = blockDim.y * n;

    float Csub = 0; // The output that the thread calculates
    for (size_t i = aBegin, j = bBegin; i <= aEnd; i += aStep, j += bStep) {
        std::printf("added %d\n",  threadIdx.y * n + threadIdx.x + i);
        shared_A[threadIdx.y * n + threadIdx.x] = A[threadIdx.y * n + threadIdx.x + i];
        shared_B[threadIdx.y * n + threadIdx.x] = B[threadIdx.y * n + threadIdx.x + j];

        __syncthreads();

        // all threads in this block have done copying data


    }
    std::printf("added \n");
    for (size_t k = 0; k < blockDim.x; k++) {
        Csub += shared_A[threadIdx.y * n + k] * shared_B[k * n + threadIdx.x];
        std::printf("added \n");

    }
    __syncthreads();
    C[index] = Csub;


}


__host__ void matmul(const float* A, const float* B, float* C, unsigned int n, unsigned int block_dim) {
    using namespace std;
    int blockNum = (n + block_dim - 1) / block_dim;

    dim3 dimBlock (block_dim, block_dim);
    dim3 dimGrid (blockNum, blockNum);


    matmul_kernel<<< dimGrid, dimBlock, (block_dim * block_dim) * sizeof(float) + (block_dim * block_dim) * sizeof(float) >>>(A, B, C, n);
    cudaDeviceSynchronize();
}