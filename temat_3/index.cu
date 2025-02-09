#include <cuda_runtime.h>
#include <cstdio>

__global__ void myIndex(){
    auto const tidx = threadIdx.x;
    auto const tidy = threadIdx.y;
    auto const bidxx = blockIdx.x;
    auto const bidyy = blockIdx.y;
    auto const idxx = blockIdx.x * blockDim.x + threadIdx.x;
    auto const idxy = blockIdx.y * blockDim.y + threadIdx.y;

    auto const row = blockIdx.y * blockDim.y + threadIdx.y;
    auto const col = blockIdx.x * blockDim.x + threadIdx.x;

    auto const fidx = row * blockDim.x * gridDim.x + col;
    printf("bidxx: %d, bidxy: %d, tidx: %d, tidy: %d, idxx: %d, idxy: %d, row: %d, col: %d, fidx: %d\n",
     bidxx, bidyy, tidx, tidy, idxx, idxy, row, col, fidx);
}

int main(){
    dim3 threads_in_block = {2, 2};
    dim3 blocks = {2, 2};

    myIndex<<<blocks, threads_in_block>>>();
    cudaDeviceSynchronize();
}