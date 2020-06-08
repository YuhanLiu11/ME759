#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include "reduce.h"


using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;

int main(int argc, char** argv) {
    int n = atol(argv[1]);
    int t = atol(argv[2]);


    float *arr = new float[n];
    for (int i = 0; i < n; i++) {
        arr[i] = 1;
    }
    float res = 0;


    duration<double, std::milli> t_avg;
    t_avg = std::chrono::duration<double, std::milli>{0};
    for (int i = 0; i < 10; i++) {

        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;
        duration<double, std::milli> t0;
        start = high_resolution_clock::now();
        omp_set_num_threads(t);
        res = reduce(arr, 0, n);

        end = high_resolution_clock::now();
        t0 = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        if (i >= 5) {
            t_avg += t0;
        }
    }




    std::cout << res << std::endl;
    std::cout << t_avg.count() / 5 << std::endl;


}