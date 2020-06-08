

#include <iostream>
#include <cstdlib>
#include <chrono>
#include <ratio>

#include "convolution.h"
#include <set>
using namespace std;
using std::cout;
using std::chrono::high_resolution_clock;
using std::chrono::duration;
int main(int argc, char** argv)
{
    int N = atoi(argv[1]);
    int t = atoi(argv[2]);
//    float image[]{1, 3, 4, 8, 6, 5, 2, 4, 3, 4, 6, 8, 1, 4, 5, 2};//new float[N * N];
    float *image = new float[N * N];
    float mask[]{0, 0, 1, 0, 1, 0, 1, 0, 0};//new float[9];
    float* output = new float[N * N];

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            image[i*N + j] = ((double) rand() / (RAND_MAX)) * 5;
        }
    }
//    for (int i = 0; i < 3; i++) {
//        for (int j = 0; j < 3; j++) {
//            mask[i*3 + j] = ((double) rand() / (RAND_MAX)) * 5;
//        }
//    }

    high_resolution_clock::time_point start;
    high_resolution_clock::time_point end;
    duration<double, std::milli> duration_sec;
    start = high_resolution_clock::now();
    omp_set_num_threads(t);
    Convolve(image, output, N, mask, 3);
    end = high_resolution_clock::now();
    duration_sec = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
    cout << duration_sec.count() << endl;
    cout << output[0] << endl;
    cout << output[N*N - 1] << endl;
//    for (int i = 0; i < N* N; i++) {
//        cout << output[i] << endl;
//    }


}


