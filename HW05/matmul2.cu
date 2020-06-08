#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "matmul.cuh"

__global__ void
matmul_kernel(const float *A, const float *B, float *C, unsigned int n) {

    int BLOCK_SIZE = blockDim.x;
    int wA = n, wB = n;


    // Shared memory for the sub-matrices (tiles) of  A and B
    extern __shared__ float shared_memory[];
    float *As = shared_memory;
    float *Bs = As + BLOCK_SIZE * BLOCK_SIZE;

    // Block index
    int bx = blockIdx.x; //the B (and C) matrix sub-block column index
    int by = blockIdx.y; //the A (and C) matrix sub-block row index

    // Thread index
    int tx = threadIdx.x; //the column index in the sub-block
    int ty = threadIdx.y; //the row index in the sub-block
    int index =  wB * BLOCK_SIZE * by + BLOCK_SIZE * bx + wB * ty + tx;
    // Index of the first sub-matrix of A processed by the block
    int aBegin = wA * BLOCK_SIZE * by; // 0

    // Index of the last sub-matrix of A processed by the block
    int aEnd = aBegin + wA - 1; // 4

    // Step size used to iterate through the sub-matrices of A
    int aStep = BLOCK_SIZE; // 10

    // Index of the first sub-matrix of B processed by the block
    int bBegin = BLOCK_SIZE * bx;

    // Step size used to iterate through the sub-matrices of B
    int bStep = BLOCK_SIZE * wB;

    // The element of the block sub-matrix that is computed
    // by the thread
    float Csub = 0;



    // Loop over all the sub-matrices (tiles) of A and B required to
    // compute the block sub-matrix; moving in A left to right in
    // a row, and in B from top to bottom in a column
    for (int a = aBegin, b = bBegin;
         a <= aEnd;
         a += aStep, b += bStep) {

        // Load tiles from global memory into shared memory; each
        // thread loads one element of the two tiles from A & B
        int a_row_index = a / n;
        int a_col_index = a % n;
        int A_index = a + wA * ty + tx;
        int B_index = b + wB * ty + tx;
        int b_row_index = b / n;
        int b_col_index = b % n;
        if (A_index / n >= n || (a_row_index + ty >= wA) || A_index % n < a_col_index
        || (a_col_index + tx >= wA)
        ) {

            As[ty * BLOCK_SIZE + tx] = 0;
        }

        else
          As[ty * BLOCK_SIZE + tx] = A[A_index];
        if (B_index / n >= n || (b_row_index + ty >= wB) || B_index % n < b_col_index
            || (b_col_index + tx >= wB)
                )
            Bs[ty * BLOCK_SIZE + tx] = 0;
        else
            Bs[ty * BLOCK_SIZE + tx] = B[B_index];

        // Synchronize to make sure the matrices are loaded
        __syncthreads();


        // Each thread in this block computes one element
        // of the block sub-matrix (tile).  Thread with indexes
        // ty and tx computes in this tile the entry [ty][tx].

        for (int k = 0; k < BLOCK_SIZE; ++k) {

            Csub += As[ty * BLOCK_SIZE + k] * Bs[k * BLOCK_SIZE + tx];

        }


        // Synchronize to make sure that the preceding
        // computation is done before loading two new
        // sub-matrices of A and B in the next iteration
        __syncthreads();


    }
    // Write the block sub-matrix to global memory;
    // each thread writes one element

    if (index < n * n && (aBegin % n + threadIdx.x < n) && (aBegin / n + ty < n)
    && (bBegin % n + threadIdx.x < n) && (bBegin / n + threadIdx.y < n)) {
        C[index] = Csub;
    }


}


__host__ void matmul(const float *A, const float *B, float *C, unsigned int n,
                     unsigned int block_dim) {
    using namespace std;
    int blockNum = (n + block_dim - 1) / block_dim;

    dim3 dimBlock(block_dim, block_dim);
    dim3 dimGrid(blockNum, blockNum);


    matmul_kernel << < dimGrid, dimBlock,
            (block_dim * block_dim) * sizeof(float) +
            (block_dim * block_dim) * sizeof(float) >> > (A, B, C, n);
    cudaDeviceSynchronize();
}