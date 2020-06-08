#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <cub/cub.cuh>
#include <cub/util_allocator.cuh>
#include <cub/device/device_reduce.cuh>

using namespace cub;

CachingDeviceAllocator  g_allocator(true);  // Caching allocator for device memory

int main(int argc, char** argv) {
    unsigned int n = atol(argv[1]);
    int *h_in = new int[n];
    for (unsigned int i = 0; i < n; i++) {
        h_in[i] = 1;
    }

    int* d_in = NULL;
    CubDebugExit(g_allocator.DeviceAllocate((void**)& d_in, sizeof(int) * n));
    // Initialize device input
    CubDebugExit(cudaMemcpy(d_in, h_in, sizeof(int) * n, cudaMemcpyHostToDevice));
    int* d_sum = NULL;
    CubDebugExit(g_allocator.DeviceAllocate((void**)& d_sum, sizeof(int) * 1));
    void* d_temp_storage = NULL;
    size_t temp_storage_bytes = 0;
    CubDebugExit(DeviceReduce::Sum(d_temp_storage, temp_storage_bytes, d_in, d_sum, n));
    CubDebugExit(g_allocator.DeviceAllocate(&d_temp_storage, temp_storage_bytes));

    // Do the actual reduce operation
    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    CubDebugExit(DeviceReduce::Sum(d_temp_storage, temp_storage_bytes, d_in, d_sum, n));
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    int gpu_sum;
    CubDebugExit(cudaMemcpy(&gpu_sum, d_sum, sizeof(int) * 1, cudaMemcpyDeviceToHost));

    std::cout << gpu_sum << std::endl;
    std::cout << ms << std::endl;

    if (d_in) CubDebugExit(g_allocator.DeviceFree(d_in));
    if (d_sum) CubDebugExit(g_allocator.DeviceFree(d_sum));
    if (d_temp_storage) CubDebugExit(g_allocator.DeviceFree(d_temp_storage));
}