#include <iostream>
#include <cuda.h>

using namespace std;
const int N=64;
__global__
void square(unsigned matrix[][N], unsigned result[][N], unsigned N){
	//result = matrix;
	unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned idy = blockIdx.y * blockDim.y + threadIdx.y;
	//unsigned ii = id / N;
	//unsigned jj = id % N;
	for(unsigned kk = 0; kk < N; ++kk) {
		result[idx][idy] += matrix[idx][kk] * matrix[kk][idy];
	}
	
}
__global__
void initArray(unsigned matrix[][N], unsigned N)
{
	unsigned idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned idy = blockIdx.y * blockDim.y + threadIdx.y;

	matrix[idx][idy] = (idx * N + idy);
}

int main() {
//int N = 64;
//int m = 64, n = 64;
unsigned matrix[N][N];
unsigned (*gMatrix)[N];
unsigned (*result)[N];
cudaMallocManaged(&gMatrix, (N*N)*sizeof(int));
cudaMallocManaged(&result, (N*N)*sizeof(int));
int threadCount = 32;


dim3 threadsPerBlock(threadCount, threadCount);
dim3 numBlocks(N / threadsPerBlock.x, N / threadsPerBlock.y);


initArray<<<numBlocks,threadsPerBlock>>>(gMatrix,N);
square<<<numBlocks,threadsPerBlock>>>(gMatrix, result,N);

cout << "Hello world"; //test
cudaMemcpy(matrix, result, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);;
cout << "Squared matrix = ";
for(int i = 0; i < N; i++){
	cout << endl;
	for(int j = 1; j < N; ++j)
	{
		cout <<matrix[i][j]<< " ";
	}
}
cudaFree(result);
cudaFree(gMatrix);
}
