#include <iostream>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include "count.cuh"
using namespace std;
int main(int argc, char *argv[]) {
    int n = atol(argv[1]);

    thrust::host_vector<int> h_in(n);
    for (int i = 0; i < n; i++) {
        h_in[i] = ((int) rand() % 25);
//        cout << "random number: " << h_in[i] << endl;
    }

    thrust::device_vector<int> d_in = h_in;
    thrust::device_vector<int> values(n);
    thrust::device_vector<int> counts(n);

    cudaEvent_t start;
    cudaEvent_t stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    count(d_in, values, counts);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
//
//    for (int i = 0; i < int(values.size()); i++) {
//        cout << values[i] << endl;
//        cout << counts[i] << endl;
//    }
    std::cout << values.back() << std::endl;
    std::cout << counts.back() << std::endl;
    std::cout << ms << std::endl;
}