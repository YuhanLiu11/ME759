#include <chrono>
#include <cstdlib>
#include <iostream>
#include <ratio>
#include <algorithm>
#include "optimize.h"

using namespace std;
using std::cout;
using std::sort;
using std::chrono::duration;
using std::chrono::high_resolution_clock;
typedef void (*optimize)(vec *, data_t *);
int main(int argc, char** argv) {
    int n = atol(argv[1]);
    data_t *data = new data_t[n];
    for (int i = 0; i < n; i++) {
        data[i] = 1;
    }

    vec v = vec(n);
    v.data = data;



    optimize opt[5] = { optimize1, optimize2, optimize3, optimize4, optimize5 };

    data_t dest_list[5] = {0};
    for (int i = 0; i < 5; i++) {
        duration<double, std::milli> t;
        t = std::chrono::duration<double, std::milli>{0};
        for (int k = 0; k < 15; k++) {
            data_t *dest = (data_t *) malloc(sizeof(data_t));
            high_resolution_clock::time_point start;
            high_resolution_clock::time_point end;
            duration<double, std::milli> t0;
            start = high_resolution_clock::now();


            opt[i](&v, dest);

            end = high_resolution_clock::now();
            t0 = std::chrono::duration_cast<duration<double, std::milli> >(end - start);

            dest_list[i] = *dest;
            if (k >= 5)
                t += t0;
            free(dest);
        }
        std::cout << dest_list[i]  << std::endl;
        std::cout << t.count()/10  << std::endl;
//        std::cout << dest_list[i] << " //from optimize" << (i+1) << std::endl;
//        std::cout << t.count()/10 << " //from optimize" << (i+1) << std::endl;
    }


//    for (int i = 0; i < 5; i++) {
//        std::cout << dest_list[i] << std::endl;
//        std::cout << t[i] << std::endl;
//    }







}