#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include <mpi.h>
#include <cassert>

using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;


int main(int argc, char** argv) {
    MPI_Init(&argc,&argv);


    int n = atol(argv[1]);
    float *a = new float[n];
    float *b = new float[n];
    for (int i = 0; i < n; i++) {
        a[i] = 1;
        b[i] = 1;
    }
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    duration<double, std::milli> t0;
    duration<double, std::milli> t1;
    MPI_Status Status;


    if (rank == 0) {
        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;

        start = high_resolution_clock::now();
        MPI_Send(a, n, MPI_FLOAT, 1, 0, MPI_COMM_WORLD);
        MPI_Recv(b, n, MPI_FLOAT, 1, 1, MPI_COMM_WORLD,
                 &Status);
        end = high_resolution_clock::now();
        t0 = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        MPI_Send(&t0, 1, MPI_DOUBLE, 1, 2, MPI_COMM_WORLD);
    } else if(rank == 1) {
        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;

        start = high_resolution_clock::now();
        MPI_Recv(a, n, MPI_FLOAT, 0, 0, MPI_COMM_WORLD,
                 &Status);
        MPI_Send(b, n, MPI_FLOAT, 0, 1, MPI_COMM_WORLD);
        end = high_resolution_clock::now();
        t1 = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        for (int i = 0; i < n; i++) {
            assert(a[i] == 1);
            assert(b[i] == 1);
        }
        MPI_Recv(&t0, 1, MPI_DOUBLE, 0, 2, MPI_COMM_WORLD,
                 &Status);
        std::cout << (t0.count() + t1.count()) << std::endl;

    }
    MPI_Finalize();


}