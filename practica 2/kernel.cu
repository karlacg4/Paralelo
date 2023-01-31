#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

//act 1, 2
__global__ void idx_calc_tid(int *input)
{
    int tid = threadIdx.x;
    printf("[DEVICE] threadIdx.x: %d, data: %d\n\r", tid, input[tid]);

}

//act 3
//__global__ void idx_calc_gid(int *input)
//{
//    int tid = threadIdx.x;
//    int offset = blockIdx.x * blockDim.x;
//    int gid = tid + offset;
//
//    printf("[DEVICE] blockIdx.x: %d, threadIdx.x: %d, gid: %d, data: %d\n\r", blockIdx.x, tid, gid, input[gid]);
//}

//act 4
//__global__ void idx_calc_gid(int* input)
//{
//    int tid = threadIdx.x;
//    int offsetBlock = blockIdx.x * blockDim.x;
//    int offsetRow = blockIdx.y * blockDim.x * gridDim.x;
//    int gid = tid + offsetBlock + offsetRow;
//
//    printf("[DEVICE] gridDim.x: %d, blockIdx.x: %d, blockIdx.y: %d,  threadIdx.x: %d, gid: %d, data: %d\n\r", gridDim.x, blockIdx.x, blockIdx.y, tid, gid, input[gid]);
//}

//ACT 5
__global__ void idx_calc_gid(int* input)
{
    int tid = threadIdx.x + threadIdx.y * blockDim.x;
    int offsetBlock = blockIdx.x * blockDim.x * blockDim.y;
    int offsetRow = blockIdx.y * blockDim.x * blockDim.y * gridDim.x ;
    int gid = tid + offsetBlock + offsetRow;

    printf("[DEVICE] gridDim.x: %d, blockIdx.x: %d, blockIdx.y: %d,  threadIdx.x: %d, gid: %d, data: %d\n\r", gridDim.x, blockIdx.x, blockIdx.y, tid, gid, input[gid]);
}


int main()
{
    const int n = 16;
    int size = n * sizeof(int);
    const int a[n] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
    int* aData = 0;
    cudaMalloc((void**)&aData, size);
    cudaMemcpy(aData, a, size, cudaMemcpyHostToDevice);

    //act1
    //idx_calc_tid << <1, n >> > (aData);

    //act 2
    //idx_calc_tid << <2, 8 >> > (aData);

    //act 3
    //idx_calc_gid << <4, 4 >> > (aData);

    //act 4
    /*dim3 grid(2, 2);
    dim3 block(4);
    idx_calc_gid << < grid, block >> > (aData);*/

    //act 5
    dim3 grid(2, 2);
    dim3 block(2, 2);
    idx_calc_gid << < grid, block >> > (aData);


    cudaDeviceSynchronize();
    cudaDeviceReset();
    cudaFree(aData);
    return 0;

    
   
}
