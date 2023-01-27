#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>

using namespace std;

__global__ void addVectors(int* v1, int* v2, int* v3) {
    v3[threadIdx.x + blockIdx.x * blockDim.x] = v1[threadIdx.x + blockIdx.x * blockDim.x] + v2[threadIdx.x + blockIdx.x * blockDim.x];
}

int main()
{
    const int N = 3;

    int a[N] = { 1, -3, 4 };
    int b[N] = { -1, 7, -1 };
    int c[N] = { 0 };

    int size = N * sizeof(int);

    int* d_a = 0;
    int* d_b = 0;
    int* d_c = 0;

    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, size, cudaMemcpyHostToDevice);

    addVectors << <1, N >> > (d_a, d_b, d_c);

    cudaDeviceSynchronize();

    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    printf("{ 1, -3, 4 } + { -1, 7, -1 } = %d %d %d", c[0], c[1], c[2]);

    cudaDeviceReset();

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}
