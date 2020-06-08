#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <thrust/transform_reduce.h>
#include <thrust/functional.h>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>


int main(int argc, char** argv) {
    using namespace std;
    using namespace thrust;
    long n = atol(argv[1]);
    thrust::host_vector<float> h_vec(n);
    thrust::fill(h_vec.begin(), h_vec.end(), 1);
    thrust::host_vector<float> h_res(n);

//    cout << "start copying" << endl;
    thrust::device_vector<float> d_vec(n);

    thrust::copy(h_vec.begin(), h_vec.end(), d_vec.begin());
    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    thrust::device_vector<float> d_intermediate(n);

    thrust::exclusive_scan(d_vec.begin(), d_vec.end(), d_intermediate.begin());



    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    thrust::copy(d_intermediate.begin(), d_intermediate.end(), h_res.begin());
    cout << h_res[n - 1] << endl;
    cout << ms << endl;


}
