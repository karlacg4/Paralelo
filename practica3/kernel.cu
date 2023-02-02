
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include<cstdlib>
#include<iostream>

using namespace std;

//ACT 1
//__global__ void idx_calc_gid(int* input)
//{
//    int totalT = blockDim.x * blockDim.y * blockDim.z;
//
//    int tid = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * blockDim.x * blockDim.y;
//
//    int bid = blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y;
//   
//    int gid = tid + bid * totalT;
//
//    //act 1
//    //printf("[DEVICE] gid: %d, data: %d\n\r", gid, input[gid]);
//}

//act 2
__global__ void sumGPU(int* a, int* b, int* c, int size)
{
    int totalT = blockDim.x * blockDim.y * blockDim.z;

    int tid = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * blockDim.x * blockDim.y;

    int bid = blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y;
   
    int gid = tid + bid * totalT;

    if (gid < size) {
        c[gid] = a[gid] + b[gid];
    }

}

void sum(int* a, int* b, int* c, int size) {
    for (int i = 0; i < size; i++) {
        c[i] = a[i] + b[i];
    }
}


int main()
{
    //act1 
    /*const int n = 16;
    int size = n * sizeof(int);
    const int a[n] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
    int* aData = 0;
    cudaMalloc((void**)&aData, size);
    cudaMemcpy(aData, a, size, cudaMemcpyHostToDevice); 
    
    
    */
    
    
    //act 2
    const int n = 10000;
    int size = n * sizeof(int);
    int a[n] = {};
    int b[n] = {};

    int outCPU[n] = {};
    int outGPU[n] = {};

    for (int i = 0; i < n; i++) {
        a[i] = rand() % 256;
        b[i] = rand() % 256;
    }

    int* aData = 0;
    int* bData = 0;

    int* dataGPU = 0;

    cudaMalloc((void**)&aData, size);
    cudaMalloc((void**)&bData, size);

    cudaMalloc((void**)&dataGPU, size);

    cudaMemcpy(aData, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(bData, b, size, cudaMemcpyHostToDevice);
   
    //act 2
    
    bool isEqual = true;
    sumGPU << < 79, 128 >> > (aData, bData, dataGPU, n);
    sum(a, b, outCPU, n);
    cudaDeviceSynchronize();
    cudaMemcpy(outGPU, dataGPU, size, cudaMemcpyDeviceToHost);
    for (int i = 0; i < n; i++) {
        if (outCPU[i] != outGPU[i]) {
            isEqual = false;
        }

    }

    if (isEqual == true) {
        cout << "Equal arrays"<<endl;
    }
    else {
        cout << "Different array results"<< endl;
    }

    //act 1
    /*dim3 grid(2, 2, 2);
    dim3 block(2, 2, 2);
    idx_calc_gid << < grid, block >> > (aData);*/

    cudaDeviceReset();
    cudaFree(aData);
    return 0;

}
