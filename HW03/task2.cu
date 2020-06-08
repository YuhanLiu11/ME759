#include <cuda.h>

#include <stdio.h>
#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>


__global__ void calc(int *dA){
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    dA[index] = blockIdx.x + threadIdx.x;

}
int main(void) {
    using namespace std;
    int *dA;
    int size = sizeof(int);
    cudaMalloc(&dA, 16 * size);
    calc <<< 2 , 8 >>>(dA);
    cudaDeviceSynchronize();
    int *hA = (int *)malloc(16 * size);

    cudaMemcpy(hA, dA, 16*sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < 16; i++) {
        if (i < 15)
            cout << hA[i] << " ";
        else {
            cout << hA[i] << endl;
        }
    }

    free(hA);
    cudaFree(&dA);
    return 0;
}