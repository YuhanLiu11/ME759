#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include "stencil.cuh"

__global__ void stencil_kernel(const float* image, const float* mask, float* output, unsigned int n, unsigned int R) {
    using namespace std;
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    extern __shared__ float s[];
    float *shared_mask = s;
    float *shared_image = (float *)&shared_mask[(2*R+1)];
    float *shared_results = (float *)&shared_image[blockDim.x + (2*R)];
    if (threadIdx.x == 0) {
        for (int i = 0; i < (2 * R + 1); i++) {
            shared_mask[i] = mask[i];
        }
        for (int i = 0; i < blockDim.x; i++) {
            shared_results[i] = 0;
        }


    }


    if (threadIdx.x == 0) {
        for (int i = 0; i < R+1; i ++) {
            int image_index = index - R + i;
            if (image_index < 0 || image_index >= n) {
                shared_image[i] = 0;
            } else {
                shared_image[i] = image[index - R + i ];
            }
        }

    } else if (threadIdx.x == blockDim.x - 1) {

        for (int i = 0; i < R+1; i ++) {
            int image_index = index + i;

            if (image_index < 0 || image_index >= n) {
                shared_image[i + R + blockDim.x - 1] = 0;

            } else {
                shared_image[i + R + blockDim.x - 1] = image[image_index];
            }
        }

    } else {

        shared_image[threadIdx.x + R] = image[index];
    }

    __syncthreads();


    for (int j = 0; j <= 2*R; j++) {
        int shared_index = threadIdx.x + j;
        shared_results[threadIdx.x] += shared_image[shared_index] * shared_mask[j];

    }
    output[index] = shared_results[threadIdx.x];


}


__host__ void stencil(const float* image,
                      const float* mask,
                      float* output,
                      unsigned int n,
                      unsigned int R,
                      unsigned int threads_per_block) {

                        int blockNum = (n + threads_per_block - 1) / threads_per_block;
                        stencil_kernel <<< blockNum, threads_per_block, (2*R+1) * sizeof(float) + (threads_per_block + 2*R) * sizeof(float) + threads_per_block * sizeof(float) >>> (image, mask, output, n, R);
                        cudaDeviceSynchronize();
                      }