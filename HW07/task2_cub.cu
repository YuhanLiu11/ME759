#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <cub/cub.cuh>

#include <cub/util_allocator.cuh>
#include <cub/device/device_reduce.cuh>
#include <cub/device/device_scan.cuh>
using namespace cub;
CachingDeviceAllocator  g_allocator(true);  // Caching allocator for device memory

int main(int argc, char** argv) {
    long n = atol(argv[1]);
    float *h_in = new float[n];
    std::fill(h_in, h_in + n, 1);
    float* d_in = NULL;
    CubDebugExit(g_allocator.DeviceAllocate((void**)& d_in, sizeof(float) * n));
    // Initialize device input
    CubDebugExit(cudaMemcpy(d_in, h_in, sizeof(float) * n, cudaMemcpyHostToDevice));
    float* d_scan = NULL;
    CubDebugExit(g_allocator.DeviceAllocate((void**)& d_scan, sizeof(float) * n));
    void* d_temp_storage = NULL;
    size_t temp_storage_bytes = 0;
    CubDebugExit(DeviceScan::ExclusiveSum(d_temp_storage, temp_storage_bytes, d_in, d_scan, n));
    CubDebugExit(g_allocator.DeviceAllocate(&d_temp_storage, temp_storage_bytes));

    // Do the actual reduce operation
    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);
    CubDebugExit(DeviceScan::ExclusiveSum(d_temp_storage, temp_storage_bytes, d_in, d_scan, n));
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);

    float* gpu_scan = new float[n];
    CubDebugExit(cudaMemcpy(gpu_scan, d_scan, sizeof(float) * n, cudaMemcpyDeviceToHost));

    std::cout << gpu_scan[n - 1] << endl;
    std::cout << ms << endl;

    if (d_in) CubDebugExit(g_allocator.DeviceFree(d_in));
    if (d_scan) CubDebugExit(g_allocator.DeviceFree(d_scan));
    if (d_temp_storage) CubDebugExit(g_allocator.DeviceFree(d_temp_storage));
    free(gpu_scan);
}