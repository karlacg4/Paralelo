#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>

using namespace std;

struct aos {
    int x;
    int y;
};

struct soa {
    int x[16];
    int y[16];
};

__global__ void AOS(aos* p, aos* r, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < size) {
        aos aux = p[tid];
        aux.x += 1;
        aux.y += 2;
        r[tid] = aux;
    }
}

__global__ void SOA(soa* p, soa* r, int size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < size) {
        r->x[tid] = p->x[tid] + 1;
        r->y[tid] = p->y[tid] + 2;
    }
}

int main() {
    
    // AOS
    /*
    int size = 16;
    int blockSize = 32;

    aos* h_points, * h_res;

    h_points = (aos*)malloc(sizeof(aos) * size);
    h_res = (aos*)malloc(sizeof(aos) * size);

    for (int i = 0; i < size; i++) {
        h_points[i].x = i + 1;
        h_points[i].y = i + 2;
    }

    aos* d_points, * d_results;
    cudaMalloc(&d_points, sizeof(aos) * size);
    cudaMalloc(&d_results, sizeof(aos) * size);

    cudaMemcpy(d_points, h_points, sizeof(aos) * size, cudaMemcpyHostToDevice);
    dim3 block(blockSize);
    dim3 grid((size +blockSize-1) / (block.x));
    AOS <<<grid, block>>> (d_points, d_results, size);

    cudaMemcpy(h_res, d_results, sizeof(aos) * size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < size; i++) {
        printf("x: %d y: %d\n", h_res[i].x, h_res[i].y);
    }
    */
    

    
    //SOA
    int size = 16;
    int blockSize = 32;

    soa* h_points, * h_res;

    h_points = (soa*)malloc(sizeof(soa));
    h_res = (soa*)malloc(sizeof(soa));

    for (int i = 0; i < size; i++) {
        h_points->x[i] = i + 1;
        h_points->y[i] = i + 2;
    }

    soa* d_points, * d_results;
    cudaMalloc(&d_points, sizeof(soa));
    cudaMalloc(&d_results, sizeof(soa));

    cudaMemcpy(d_points, h_points, sizeof(soa), cudaMemcpyHostToDevice);
    dim3 block(blockSize);
    dim3 grid((size + blockSize - 1) / (block.x));
    SOA << <grid, block >> > (d_points, d_results, size);

    cudaMemcpy(h_res, d_results, sizeof(soa), cudaMemcpyDeviceToHost);

    for (int i = 0; i < size; i++) {
        printf("x: %d y: %d\n", h_res->x[i], h_res->y[i]);
    }
    
}
