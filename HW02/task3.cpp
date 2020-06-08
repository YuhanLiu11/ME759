
#include <iostream>
#include <cstdlib>
#include <chrono>
#include <ratio>

#include "matmul.h"

using namespace std;
using std::cout;
using std::chrono::high_resolution_clock;
using std::chrono::duration;
typedef void (*matfunc)(const double*, const double*, double*, const std::size_t);

int main() {
    long N = 1024;

    cout << N << endl;


    double *A = new double[N * N];
    double *A2 = new double[N * N]; // col major order

    double *B = new double[N * N];
    double *B2 = new double[N * N]; // col major order


    double *a = new double[N*N];
    double *b = new double[N*N];


    for(int i = 0; i < N*N; i++) {

        a[i] = ((double) rand() / (RAND_MAX)) * 5;
        b[i] = ((double) rand() / (RAND_MAX)) * 5;
    }


    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i * N + j] = a[i * N + j];
            B[i * N + j] = b[i * N + j];
            B2[j* N + i] = b[i * N + j];
            A2[j * N + i] = a[i * N + j];
        }
    }

    matfunc mmul[4] = {mmul1, mmul2, mmul3, mmul4};
    double *A_list[4] = {A, A, A, A2};
    double *B_list[4] = {B, B, B2, B};
    for (int i = 0; i < 4; i++) {
        high_resolution_clock::time_point start;
        high_resolution_clock::time_point end;
        duration<double, std::milli> duration_sec;
        start = high_resolution_clock::now();
        double *C = new double[N*N]();
        mmul[i](A_list[i], B_list[i], C, N);
        end = high_resolution_clock::now();
        duration_sec = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
        cout << duration_sec.count() << endl;
        cout << C[N*N - 1] << endl;
    }

}