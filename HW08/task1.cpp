#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>

#include "matmul.h"

using namespace std;
using std::cout;
using std::chrono::duration;
using std::chrono::high_resolution_clock;

int main(int argc, char** argv)
{
    int N = atol(argv[1]);
    int t = atoi(argv[2]);


    float* A = new float[N * N];

    float* B = new float[N * N];
    float* C = new float[N * N];

    for (int i = 0; i < N * N; i++) {

        A[i] = ((float)rand() / (RAND_MAX)) * 5;
        B[i] = ((float)rand() / (RAND_MAX)) * 5;
    }

    omp_set_num_threads(t);
    double startTime = omp_get_wtime(); // Start Clock
    mmul(A, B, C, N);
    double endTime = omp_get_wtime(); // Stop Clock

    cout << C[0] << endl;
    cout << C[N * N - 1] << endl;
    cout << (endTime - startTime) * 1000 << endl;

}
