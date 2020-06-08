
#include <iostream>
#include <cstdlib>
#include <chrono>
#include <ratio>

#include "scan.h"

using namespace std;
using std::cout;
using std::chrono::high_resolution_clock;
using std::chrono::duration;
int main(int argc, char** argv)
{
    int N = atoi(argv[1]);
    float* input = new float[N];
    float* res = new float[N];
    for (int i = 0; i < N; i++) {
        input[i] = ((float) rand() / (RAND_MAX)) * 2 - 1;
    }

    high_resolution_clock::time_point start;
    high_resolution_clock::time_point end;
    duration<double, std::milli> duration_sec;
    start = high_resolution_clock::now();
    Scan(input, res, N);
    end = high_resolution_clock::now();
    duration_sec = std::chrono::duration_cast<duration<double, std::milli> >(end - start);
    cout << duration_sec.count() << endl;
    cout << res[0] << endl;
    cout << res[N - 1] << endl;
}

