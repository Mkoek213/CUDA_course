#include <cuda_runtime.h>
#include <cstdio>
#include <cassert>
#include <algorithm>
#include <numeric>

template<typename T, typename Func>
__global__ void belloch_scan(T* const result,const T* const source, const T ident, Func func){
    assert(gridDim.x == 1);
    auto const tid = threadIdx.x;
    result[tid] = source[tid];
    __syncthreads();

    for (auto stride = 1U; stride <= blockDim.x; stride <<= 1){
        auto isMyTid = ((tid + 1) & ((stride << 1) - 1)) == 0;
        if (isMyTid){
            result[tid] = func(result[tid], result[tid - stride]);
        }
        __syncthreads();
    }
    result[blockDim.x - 1] = ident;
    for (auto stride = blockDim.x / 2; stride > 0; stride >>= 1){
        auto isMyTid = ((tid + 1) & ((stride << 1) - 1)) == 0;
        if (isMyTid){
            const auto leftVal = result[tid - stride];
            const auto rightVal = result[tid];
            result[tid] = func(result[tid], leftVal);
            result[tid - stride] = rightVal;
        }
    }
}

template<typename T>
void showData(const T* const data, const size_t size){
    std::for_each(data, data + size, [](T a){printf("%3d ", a);});
    putchar('\n');
}

int main(){
    using DataType_t = int;

    constexpr static size_t Elements = 8;
    constexpr static size_t MemElements = Elements * sizeof(DataType_t);
    constexpr static size_t ThreadsInBlock = 8;
    constexpr static size_t Block = (Elements + ThreadsInBlock - 1) / ThreadsInBlock;

    DataType_t* hSource = static_cast<DataType_t *>(malloc(MemElements));
    DataType_t* hDestination = static_cast<DataType_t *>(malloc(MemElements));

    DataType_t* dSource = nullptr;
    DataType_t* dDestination = nullptr;

    cudaMalloc(&dSource, MemElements);
    cudaMalloc(&dDestination, MemElements);

    std::iota(hSource, hSource + Elements, 1);

    showData(hSource, Elements);

    cudaMemcpy(dSource, hSource, MemElements, cudaMemcpyHostToDevice);

    belloch_scan<<<Block, ThreadsInBlock>>>(dDestination, dSource, 0, [] __device__ (auto a, auto b) { return a + b;});

    cudaMemcpy(hDestination, dDestination, MemElements, cudaMemcpyDeviceToHost);

    showData(hDestination, Elements);

    cudaFree(dDestination);
    cudaFree(dSource);

    free(hDestination);
    free(hSource);


    cudaDeviceSynchronize();
}