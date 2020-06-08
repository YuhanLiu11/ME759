#include "msort.h"
#include <iostream>     // std::cout
#include <algorithm>    // std::merge, std::sort
#include <functional>

void msort_helper(int *arr, const std::size_t n, const std::size_t threshold, int threads) {
    if (n < 2)
        return;

    if (n < threshold) {
        for (auto it = arr; it != arr + n; it++)
        {
            // Searching the upper bound, i.e., first
            // element greater than *it from beginning
            auto const insertion_point =
                    std::upper_bound(arr, it, *it);

            // Shifting the unsorted part
            std::rotate(insertion_point, it, it+1);
        }
        return;
    }
//    int thread_id = omp_get_thread_num();
//    printf("threadID= %d \n", thread_id);
if (threads == 1) { // NO NEED TO PUT IN THE PARALLEL REGION
        msort_helper(arr, n/2, threshold, 1);
        msort_helper(arr+n/2, n - n/2, threshold, 1);
    }
else { // if more than one thread

    int half_threads = threads / 2;
    int half_threads2 = threads - threads / 2;
#pragma omp task
    msort_helper(arr, n/2, threshold, half_threads);
#pragma omp task
    msort_helper(arr+n/2, n - n/2, threshold, half_threads2);

#pragma omp taskwait


}


//    merge the resulting two subarrays
    std::inplace_merge(arr, arr + n/2, arr + n);

}

void msort(int* arr, const std::size_t n, const std::size_t threshold) {
#pragma omp parallel
{
#pragma omp single
    {
        msort_helper(arr, n, threshold, omp_get_num_threads());

    }
}

}