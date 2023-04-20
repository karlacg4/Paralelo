#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

__global__ void unrollingTranspose(int* l, int* r, int size) {
    int gid = (threadIdx.x + threadIdx.y * blockDim.x) + (blockIdx.x + blockIdx.y * gridDim.x) * (blockDim.x * blockDim.y);
    int offset = blockDim.x / 2;

    for (int i = 0; i < (size * size + blockDim.x * blockDim.y - 1) / (blockDim.x * blockDim.y); i += 2)
    {
        if (gid + blockDim.x * blockDim.y * i < size * size) {
            r[(gid % size * size + gid / size) + offset * i] = l[gid + blockDim.x * blockDim.y * i];
        }
        if (gid + blockDim.x * blockDim.y * i + blockDim.x * blockDim.y < size * size) {
            r[(gid % size * size + gid / size) + offset * i + offset] = l[gid + blockDim.x * blockDim.y * i + blockDim.x * blockDim.y];
        }
    }

}

int main() {
    int size = 64;
    int* host_a, * host_result;
    int* dev_a, * dev_result;

    host_a = (int*)malloc(size * size * sizeof(int));
    host_result = (int*)malloc(size * size * sizeof(int));

    cudaMalloc(&dev_a, size * size * sizeof(int));
    cudaMalloc(&dev_result, size * size * sizeof(int));

    for (int i = 0; i < size * size; i++) {
        int r = (rand() % (256));
        host_a[i] = r;
        host_result[i] = 0;
    }

    printf("A:\n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("%d ", host_a[i * size + j]);
        }
        printf("\n");
    }

    cudaMemcpy(dev_a, host_a, size * size * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_result, host_result, size * size * sizeof(int), cudaMemcpyHostToDevice);

    dim3 block(32, 32);
    dim3 grid(1);
    unrollingTranspose << <1, block >> > (dev_a, dev_result, size);
    cudaMemcpy(host_result, dev_result, size * size * sizeof(int), cudaMemcpyDeviceToHost);

    cudaDeviceSynchronize();
    cudaDeviceReset();

    printf("Result:\n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("%d ", host_result[i * size + j]);
        }
        printf("\n");
    }

    return 0;
}
