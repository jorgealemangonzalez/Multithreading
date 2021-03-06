#include "stdio.h"
#define N 514    //Para correr con mas threads de los posibles en un bloque
//#define N  65537
__global__ void add(int *a, int *b, int *c)
{
	int tid = threadIdx.x + blockIdx.x * blockDim.x; //El id del thread es el id que tiene ese thread dentro de un bloque
	c[tid]=a[tid]+b[tid];							 //El id del bloque es el id que tiene ese bloque dentro del grid			
}													 //La dimension del bloque es el numero de threads que tiene cada bloque

int main()
{
	int a[N], b[N], c[N];//host 
	int *dev_a, *dev_b, *dev_c;//device

	cudaMalloc((void**)&dev_a, N*sizeof(int) );  
	cudaMalloc((void**)&dev_b, N*sizeof(int) );
	cudaMalloc((void**)&dev_c, N*sizeof(int) );


	for (int i = 0; i < N; i++){
		a[i] = i,
		b[i] = 1;
	}

	cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice); //host to device
	cudaMemcpy(dev_b, b, N*sizeof(int), cudaMemcpyHostToDevice);

	//add<<<1,N>>>(dev_a,dev_b,dev_c); //Ejecuta 1 bloque con N threads
	add<<<N,1>>>(dev_a,dev_b,dev_c); //Ejecuta N bloques de 1 solo thread cada uno
	
	//Call CUDA kernel
	cudaMemcpy(c, dev_c, N*sizeof(int), cudaMemcpyDeviceToHost);//Copy memory from device to host
	//copy array to host
	for (int i = 0; i < N; i++)
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	
	cudaFree(dev_a);//free device mem
	cudaFree(dev_b);
	cudaFree(dev_c);

	return 0;

}
