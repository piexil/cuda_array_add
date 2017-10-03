#include <stdlib.h> 
#include <string.h> 
#include <time.h>
#include <stdio.h>
__global__ void sumArray(float *A, float *B, float *C) { 
	int i = blockIdx.x;
	C[i] = A[i] + B[i];
}

void initialData(float *ip, int size){
	time_t t;
	srand((unsigned int)time(&t));
	for(int i = 0; i < size; i++){
		ip[i] = (float)( rand() & 0xFF )/10.0f;
	}
}
int main(void){
	int nElem = 16;
	size_t nBytes = nElem * sizeof(float);
	float *h_A, *h_B, *h_C;
	float *d_A, *d_B, *d_C;
	h_A = (float *)malloc(nBytes); h_B = (float *)malloc(nBytes); h_C = (float *)malloc(nBytes);
	cudaMalloc((float**)&d_A, nBytes);
	cudaMalloc((float**)&d_B, nBytes);
	cudaMalloc((float**)&d_C, nBytes);
	initialData(h_A, nElem); initialData(h_B, nElem);
	cudaMemcpy(d_A, h_A, nBytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, nBytes, cudaMemcpyHostToDevice);
	dim3 block (nElem);
	dim3 grid (nElem/block.x);
	sumArray<<<block,grid>>>(d_A,d_B,d_C);
	printf("\nExecution configuration <<<%d, %d>>>\n",grid.x,block.x);
	cudaMemcpy(h_C, d_C, nBytes, cudaMemcpyDeviceToHost);
	for(int i = 0; i < nElem; i ++){
		printf("|%f",h_A[i]);
	}
	printf("\n");
	for(int i = 0; i < nElem; i++){
		printf("|%f",h_B[i]);
	}
	printf("\n");
	for(int i = 0; i < nElem; i++){
		printf("|%f",h_C[i]);	
	}
	printf("\n");
	free(h_A); free(h_B); free(h_C);
	cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
	return(0);
}
