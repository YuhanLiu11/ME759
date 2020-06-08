#include "cuda_runtime.h"
#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>

#include "vadd.cuh"

__global__ void cuda_hello(){
    using namespace std;
    int v = threadIdx.x;
    std::printf("Hello World! I am thread %d.\n", v);
}
int main(int argc, char** argv) {

    cuda_hello <<< 1 , 4 >>>();
    cudaDeviceSynchronize();
    return 0;
}