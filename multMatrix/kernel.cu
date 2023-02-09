#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include<iostream>
using namespace std;

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ void multVec(int *c, int *a, int *b, int width, int rows, int cols)
{
    int row = blockIdx.y + blockDim.y + threadIdx.y;
    int col = blockIdx.x + blockDim.x + threadIdx.x;

    int count = 0;
    if (row < rows && col < cols) {
        for (int i = 0; i < width; i++) {
            count += a[row * width + i] * b[i * width + col];
        }
        c[row * width + col] = count;
    }
    
}

int main()
{
    int aRows, bRows, cRows = 64;
    int aCols, bCols, cCols = 32;

    int aBytes = aRows * aCols * sizeof(int);
    int bBytes = bRows *bCols * sizeof(int);
    int cBytes = cRows *cCols * sizeof(int);

    int blockSize = 2;

    int cSize = cRows * cCols;
    
    int* hostA, * hostB, * hostC, * gpuR;

    hostA = (int*)malloc(aBytes);
    hostB = (int*)malloc(bBytes);
    hostC = (int*)malloc(cBytes);
    gpuR = (int*)malloc(cSize);
    memset(gpuR, 0, cBytes);

    time_t t;
    srand((unsigned)time(&t));

    for (int i = 0; i < aRows; i++) {
        for (int j = 0; j < aCols; j++) {
            hostA[i * aCols + j] = rand() % 2;
            hostB[i * bCols + j] = rand() % 2;
        }
    }

    int* dA, * dB, * dC, * dOut;
    cudaMalloc((int**)&dA, aBytes);
    cudaMalloc((int**)&dB, bBytes);
    cudaMalloc((int**)&dC, cBytes);
    cudaMalloc((int**)&dOut, cBytes);

    cudaMemcpy(dA, hostA, aBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dB, hostB, bBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dC, hostC, cBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dOut, gpuR, cBytes, cudaMemcpyHostToDevice);

    dim3 block(blockSize, blockSize);
    dim3 grid(ceil(cSize / blockSize), ceil(cSize / blockSize));

    clock_t gpuStart, gpuStop;

    gpuStart = clock();
    multVec << <grid, block >> > (dA, dB, dC, aCols, cRows, cCols);
    cudaDeviceSynchronize();

}
