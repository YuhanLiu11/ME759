#include "vadd.cuh"

__global__ void vadd(const float *a, float *b, unsigned int n) {

    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < n) {
        b[index] = b[index] + a[index];
    }


}