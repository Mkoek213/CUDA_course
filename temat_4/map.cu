#include <cuda_runtime.h>
#include <cstdio>
#include <algorithm>
#include <numeric>

// __host__ - dane są dostępne w rapach CPU
// __device__ - dane są dostępne w ramach GPU

template<typename T, typename Func>
__global__ void map(T* const destination, const T* const source, const size_t size,Func func){
    auto const idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size){
        destination[idx] = func(source[idx]);
    }
}

template<typename T>
void showData(const T* const data, const size_t size){
    std::for_each(data, data + size, [](int a){printf("%3d ", a);});
    putchar('\n');
}

int main(){
    using DataType_t = int;
    constexpr static size_t Elements = 128;
    constexpr static size_t MemElements = Elements * sizeof(DataType_t);
    constexpr static size_t ThreadsInBlock = 4;
    constexpr static size_t Block = (Elements + ThreadsInBlock - 1) / ThreadsInBlock;

    DataType_t* hSource = static_cast<DataType_t *>(malloc(MemElements));
    DataType_t* hDestination = static_cast<DataType_t *>(malloc(MemElements));

    DataType_t* dSource = nullptr;
    DataType_t* dDestination = nullptr;

    cudaMalloc(&dSource, MemElements);
    cudaMalloc(&dDestination, MemElements);

    std::iota(hSource, hSource + Elements, 0);

    showData(hSource, Elements);

    cudaMemcpy(dSource, hSource, MemElements, cudaMemcpyHostToDevice);

    map<<<Block, ThreadsInBlock>>>(dDestination, dSource, Elements, [] __device__ (auto a) { return 8 * a;});

    cudaMemcpy(hDestination, dDestination, MemElements, cudaMemcpyDeviceToHost);

    showData(hDestination, Elements);

    cudaFree(dDestination);
    cudaFree(dSource);

    free(hDestination);
    free(hSource);


    cudaDeviceSynchronize();
}