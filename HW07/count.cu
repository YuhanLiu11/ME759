#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include "count.cuh"


void count(const thrust::device_vector<int>& d_in,
           thrust::device_vector<int>& values,
           thrust::device_vector<int>& counts) {
    thrust::device_vector<int> d_values(int(d_in.size()));
    thrust::fill(d_values.begin(), d_values.end(), 1);
    thrust::device_vector<int> keys(int(d_in.size()));
    keys = d_in;
    thrust::sort(keys.begin(), keys.end());
    auto new_end = thrust::reduce_by_key(keys.begin(), keys.end(), d_values.begin(), values.begin(), counts.begin());
    values.resize(new_end.first - values.begin());
    counts.resize(new_end.second - counts.begin());
}