#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include "cluster.h"

using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;

int main(int argc, char** argv) {
    int n = atol(argv[1]);
    int t = atol(argv[2]);
    int *arr = new int[n];
    for (int i = 0; i < n; i ++) {
        arr[i] = (int) (rand() % n);

    }

    std::sort(arr, arr+n);

    int *centers = new int[t];
    for (int i = 0; i < t; i++) {
        centers[i] = ((i+1) * 2 - 1) * n / (2*t);

    }
    int *dists = new int[t];
    for (int i = 0; i < t; i++) {
        dists[i] = 0;
    }

    duration<double, std::milli> total_time;
    for (int i = 0; i < 20; i ++) {
        for (int i = 0; i < t; i++) {
            dists[i] = 0;
        }
        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;
        duration<double, std::milli> duration_sec;
        start = high_resolution_clock::now();

        cluster(n, t, arr, centers, dists);
        end = high_resolution_clock::now();
        duration_sec = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        if (i >= 10) {
            total_time += duration_sec;
        }
    }



    int max_ele = -1;
    int partition = 0;
    for (int i = 0; i < t; i++) {
        if (dists[i] > max_ele) {
            max_ele = dists[i];
            partition = i;
        }
    }
    std::cout << max_ele << std::endl;
    std::cout << partition << std::endl;
    std::cout << total_time.count() / 10 << std::endl;


}