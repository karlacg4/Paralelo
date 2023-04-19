#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

__global__ void busqueda(int* list, int* item, int* id, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < size) {
        if (list[tid] == item[0]) {
            *id = tid;
        }
    }
}

int main() {
    int size = 32;
    int* host_a, * host_item, * host_id;
    int* dev_a, * dev_item, * dev_id;

    host_a = (int*)malloc(size * sizeof(int));
    host_item = (int*)malloc(size * sizeof(int));
    host_id = (int*)malloc(size * sizeof(int));

    host_item[0] = 8;
    host_id[0] = -1;

    cudaMalloc(&dev_a, size * sizeof(int));
    cudaMalloc(&dev_item, sizeof(int));
    cudaMalloc(&dev_id, sizeof(int));

    for (int i = 0; i < size; i++) {
        host_a[i] = (rand() % (32));
        printf("%d ", host_a[i]);
    }
    printf("\n");

    cudaMemcpy(dev_a, host_a, size * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_item, host_item, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_id, host_id, sizeof(int), cudaMemcpyHostToDevice);

    dim3 grid(size >= 1024 ? size / 1024 : 1);
    dim3 block(1024);
    busqueda << <grid, block >> > (dev_a, dev_item, dev_id, size);
    cudaDeviceSynchronize();

    cudaMemcpy(host_id, dev_id, sizeof(int), cudaMemcpyDeviceToHost);

    if (host_id[0] == -1) {
        printf("Numero no encontrado\n");
    }
    else {
        printf("Numero en posicion: %d \n", host_id[0]);
    }
    return 0;
}
