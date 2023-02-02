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
//act3
__global__ void sumGPU3D(int* a, int* b, int* c, int*res, int size)
{
    int totalT = blockDim.x * blockDim.y * blockDim.z;

    int tid = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * blockDim.x * blockDim.y;

    int bid = blockIdx.x + blockIdx.y * gridDim.x + blockIdx.z * gridDim.x * gridDim.y;
   
    int gid = tid + bid * totalT;

    if (gid < size) {
        res[gid] = a[gid] + b[gid] + c[gid];
    }

}

//act 2
void sum(int* a, int* b, int* c, int size) {
    for (int i = 0; i < size; i++) {
        c[i] = a[i] + b[i];
    }
}

//act 3
void sum3D(int* a, int* b, int* c, int* res, int size) {
    for (int i = 0; i < size; i++) {
        res[i] = a[i] + b[i] + c[i];
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
    int c[n] = {};

    int outCPU[n] = {};
    int outGPU[n] = {};

    for (int i = 0; i < n; i++) {
        a[i] = rand() % 256;
        b[i] = rand() % 256;
        c[i] = rand() % 256;
    }

    int* aData = 0;
    int* bData = 0;
    int* cData = 0;

    int* dataGPU = 0;
    
    bool isEqual = true;

    cudaMalloc((void**)&aData, size);
    cudaMalloc((void**)&bData, size);
    cudaMalloc((void**)&cData, size);

    cudaMalloc((void**)&dataGPU, size);



    cudaMemcpy(aData, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(bData, b, size, cudaMemcpyHostToDevice);
    cudaMemcpy(cData, c, size, cudaMemcpyHostToDevice);
    

    //act 1
    /*dim3 grid(2, 2, 2);
    dim3 block(2, 2, 2);
    idx_calc_gid << < grid, block >> > (aData);*/

    //act 2
    
   /* sumGPU << < 79, 128 >> > (aData, bData, dataGPU, n);
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
    }*/

    //act 3

    dim3 TPB(8, 4, 4);
    dim3 BIG(size / TPB.x + 1);
    clock_t gpu_start, gpu_stop;
    gpu_start = clock();


    sumGPU3D << < BIG, TPB >> > (aData, bData,cData, dataGPU, n);
    cudaDeviceSynchronize();

    gpu_stop = clock();
    double cps_gpu = (double)((double)(gpu_stop - gpu_start) / CLOCKS_PER_SEC);
    printf("Exectution time [ET-GPU]: %4.6f \n\r", cps_gpu);

    sum3D(a, b, c, outCPU, n);
    cudaMemcpy(outGPU, dataGPU, size, cudaMemcpyDeviceToHost);

    
    

    cudaDeviceReset();
    cudaFree(aData);
    return 0;

}
