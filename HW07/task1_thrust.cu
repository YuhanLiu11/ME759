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
    unsigned int n = atol(argv[1]);
    thrust::host_vector<int> h_vec(n);
    thrust::fill(h_vec.begin(), h_vec.end(), 1);


//    cout << "start copying" << endl;
    thrust::device_vector<int> d_vec(n);

    thrust::copy(h_vec.begin(), h_vec.end(), d_vec.begin());
    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    int tot = thrust::reduce(d_vec.begin(), d_vec.end());
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);


    cout << tot << endl;
    cout << ms << endl;


}
