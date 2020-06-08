#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include <mpi.h>
#include "reduce.h"


using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;

int main(int argc, char** argv) {
    MPI_Init(&argc,&argv);
    int n = atol(argv[1]);
    int t = atol(argv[2]);

    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    float *arr = new float[n];
    for (int i = 0; i < n; i++) {
        arr[i] = 1;
    }
    float res = 0;
    float global_res = 0;


    duration<double, std::milli> t_avg;
    t_avg = std::chrono::duration<double, std::milli>{0};
    for (int i = 0; i < 10; i++) {
        MPI_Barrier(MPI_COMM_WORLD);
        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;
        duration<double, std::milli> t0;
        start = high_resolution_clock::now();
        if (rank == 0) {
            omp_set_num_threads(t);
            res = reduce(arr, 0, n);

        } else {
            omp_set_num_threads(t);
            res = reduce(arr, 0, n);


        }


        MPI_Reduce(&res, &global_res, 1, MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD);
        end = high_resolution_clock::now();
        t0 = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        if (i >= 5) {
            t_avg += t0;
        }
    }




    if (rank == 0) {
        std::cout << global_res << std::endl;
        std::cout << t_avg.count() / 5 << std::endl;
    }

    MPI_Finalize();
}