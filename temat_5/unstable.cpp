#include <vector>
#include <algorithm>
#include <numeric>
#include <iostream>

int main(){
    std::vector<float> vec{0.1F, 0.031F, 1.0122F};
    do {
        float sum = std::accumulate(vec.begin(), vec.end(), 1.0F, [](float a, float b){return a + b;});
        printf("%2.18f\n", sum);
    } while(std::next_permutation(vec.begin(), vec.end()));
}