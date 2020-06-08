#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include "montecarlo.h"

using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;


int main(int argc, char** argv) {
    int n = atol(argv[1]);
    int t = atol(argv[2]);
    float *x = new float[n];
    float *y = new float[n];
    float r = 1;
    for (int i = 0; i < n; i++) {
        x[i] = (((float) rand()) / (float) RAND_MAX) * 2 - 1;
        y[i] = (((float) rand()) / (float) RAND_MAX) * 2 - 1;
    }

    duration<double, std::milli> total_time;
    float pi = 0;
    for (int i = 0; i < 10; i ++) {

        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;
        duration<double, std::milli> duration_sec;
        start = high_resolution_clock::now();
        omp_set_num_threads(t);
        int incircle = montecarlo(n, x, y, r);

        pi = (float)(4 * incircle) / n;
        end = high_resolution_clock::now();
        duration_sec = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        if (i >= 5) {
            total_time += duration_sec;
        }
    }


    std::cout << pi << std::endl;
    std::cout << total_time.count() / 5 << std::endl;



}