#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

using namespace std;

__global__ void bubbleSortGPU(int* list, int size) {
    int tid = threadIdx.x;

    for (int i = 0; i < size; i++) {
        int offset = i % 2;
        if (2 * tid + offset + 1 < size) {
            if (list[2 * tid + offset] > list[2 * tid + offset + 1]) {
                int aux = list[2 * tid + offset];
                list[2 * tid + offset] = list[2 * tid + offset + 1];
                list[2 * tid + offset + 1] = aux;
            }
        }
        __syncthreads();
    }
}

int main() {
    int size = 32;
    int* host_a, * ans, * dev_a;
    host_a = (int*)malloc(size * sizeof(int));
    ans = (int*)malloc(size * sizeof(int));
    cudaMalloc(&dev_a, size * sizeof(size));

    for (int i = 0; i < size; i++) {
        host_a[i] = (rand() % (32));
        printf("%d ", host_a[i]);
    }
    printf("\n");

    cudaMemcpy(dev_a, host_a, size * sizeof(int), cudaMemcpyHostToDevice);

    dim3 grid(1);
    dim3 block(size);
    bubbleSortGPU << <grid, block >> > (dev_a, size);
    cudaMemcpy(ans, dev_a, size * sizeof(int), cudaMemcpyDeviceToHost);


    printf("Answer: ");
    for (int i = 0; i < size; i++) {
        printf("%d ", ans[i]);
    }
    printf("\n");
    return 0;
}
