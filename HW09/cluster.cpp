// Author: Lijing Yang

#include <cstdlib>
#include <iostream>
#include "cluster.h"

void cluster(const size_t n, const size_t t, const int *arr, const int *centers, int *dists) {
    #pragma omp parallel num_threads(t)
    {
        unsigned int tid = omp_get_thread_num();
//        unsigned int local_sum = 0;
//        unsigned int local_center = ;
        #pragma omp for reduction(+ : dists[tid])
        for (size_t i = 0; i < n; i++) {
            dists[tid] += abs(arr[i] - centers[tid]);
        }
//        dists[tid] = local_sum;
    }
}
