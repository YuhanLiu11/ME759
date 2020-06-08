#include <algorithm>
#include <chrono>
#include <iostream>
#include <cassert>
#include <numeric>
#include <omp.h>
#include <random>

#include "msort.h"

using namespace std;
using namespace chrono;

using namespace std;
int main(int argc, char** argv) {
    long n = atoi(argv[1]);
    int t = atoi(argv[2]);
    long ts = atoi(argv[3]);

    int *arr = new int[n];
    for (int i = 0; i < n; i++) {
        arr[i] = ((int) rand() % 25);
    }




    omp_set_num_threads(t);
    omp_set_nested(1);
//    omp_set_max_active_levels(3);
    double startTime= omp_get_wtime(); // Start Clock
    msort(arr, n, ts);


    double endTime= omp_get_wtime(); // Stop Clock
    assert(std::is_sorted(arr, arr+n));
    cout << arr[0] << endl;
    cout << arr[n - 1] << endl;

    std::cout<< (endTime-startTime) * 1000 <<std::endl;

}