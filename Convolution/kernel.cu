#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <random>
#include <stdio.h>
#include <cstdlib>
#include <iostream>

using namespace std;


__global__ void convolution(int* a, int* k, int* c, int n, int m, int s) {
    int row = threadIdx.y;
    int col = threadIdx.x;

    int sum = 0;
    if (row > 0 && row < m - 1 && col  >0 && col < n - 1) {
        for (int i = 0; i < s; i++) {
            for (int j = 0; j < s; j++) {
                sum += (a[(row-1) * m + i + (col - 1) + j] * k[i * s + j]);
            }
        }
        c[row * m + col] = sum;
    }
}

int main() {
    const int n = 8;
    const int m = 8;
    const int length = 3;
  
    int* host_a, * host_c, *host_kernel;
    
    host_a = (int*)malloc(n * m * sizeof(int));
    host_c = (int*)malloc(n * m * sizeof(int));
    host_kernel = (int*)malloc(length * length * sizeof(int));
  
    for (int i = 0; i < (n * m); i++) {
        int r = (rand() % (3));
        host_a[i] = r;
        host_c[i] = r;
    }

    host_kernel[0] = 0;
    host_kernel[1] = 1;
    host_kernel[2] = 0;
    host_kernel[3] = 0;
    host_kernel[4] = 0;
    host_kernel[5] = 0;
    host_kernel[6] = 0;
    host_kernel[7] = 0;
    host_kernel[8] = 0;

    int* dev_a, * dev_c, * dev_kernel;
   
    cudaMalloc(&dev_a, n * m * sizeof(int));
    cudaMalloc(&dev_c, n * m * sizeof(int));
    cudaMalloc(&dev_kernel, length * length * sizeof(int));
  
    cudaMemcpy(dev_a, host_a, n * m * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, host_c, n * m * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_kernel, host_kernel, kernelLength * kernelLength * sizeof(int), cudaMemcpyHostToDevice);

    dim3 block(8, 8);
    convolution << <1, block >> > (dev_a, dev_kernel, dev_c, n, m, length);
    cudaMemcpy(host_c, dev_c, n * m * sizeof(int), cudaMemcpyDeviceToHost);

    cudaDeviceSynchronize();
    cudaDeviceReset();

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            cout << host_c[i * n + j] << " ";
        }
        cout << "\n";
    }
  
    free(host_a);
    free(host_c);
    free(host_kernel);
    cudaFree(dev_a);
    cudaFree(dev_c);
    cudaFree(dev_kernel);
    return 0;
}
