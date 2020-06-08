#include "montecarlo.h"
using namespace std;
int montecarlo(const size_t n, const float *x, const float *y, const float radius) {
    int incircle = 0;


#pragma omp parallel
    {
        int local_incircle = 0;
#pragma omp for simd reduction(+:local_incircle)
        for (size_t i = 0; i < n; i++) {
            float x_local = x[i];
            float y_local = y[i];

                local_incircle += (x_local * x_local + y_local * y_local <= radius * radius);

        }


#pragma omp atomic
        incircle += local_incircle;


    }


    return incircle;



}