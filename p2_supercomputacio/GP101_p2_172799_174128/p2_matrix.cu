#include <stdio.h> 
#include <stdlib.h> 

__global__ void fill_matrix_device(int *m, int width) 
{ 
    int tx=blockIdx.x; 
    int ty=blockIdx.y; 
    
    int value=(tx+1)*(ty+1); 
    m[tx*width+ty] = value; 
}
__global__ void matrix_mult_device(int *Ma, int *Mb, int *Mc, int width)
{   
    
	int tx = blockIdx.x;
	int ty = blockIdx.y;
	int posfil = ty*width ,poscol = tx;

	for(int i = 0 ; i < width ; ++i)
		Mc[poscol+posfil] += Ma[posfil+i]*Mb[poscol+i*width];


	
}
void fill_matrix_host(int *m, int width) 
{ 
    for(int x=0;x<width;++x) { 
        for(int y=0;y<width;++y) { 
            int value=(x+1)*(y+1); 
            m[x*width+y] = value; 
        } 
    } 
} 

int main(void) 
{ 
    int width=2; 
    int size=width*width*sizeof(int); 

    int *m , *m1 ,*m2,*mhost; 
    m = (int *)malloc(size); 
 	m1 = (int *)malloc(size);
    m2 = (int *)malloc(size);
 	mhost = (int *)malloc(size);
 	memset(mhost, 0, size);
 	
 	
    fill_matrix_host(m, width);
    fill_matrix_host(m1, width);
    fill_matrix_host(m2, width);
   
    //hacemos la multiplicación de matrices
    for(int i = 0 ; i < width; ++i)
    	for(int j = 0 ; j < width; ++j)
    		for(int k =0 ; k < width ; ++k)
    			mhost[width*i+j] += m1[i*width + k] * m2[j + width*k];
    
    
    int *dev_m,*dev_m1,*dev_m2,*dev_mresult; 
    cudaMalloc((void **)&dev_m, size); 
    cudaMalloc((void **)&dev_m1, size);
    cudaMalloc((void **)&dev_m2, size);
    cudaMalloc((void **)&dev_mresult, size);
    dim3 dimGrid(width, width); 
    dim3 dimBlock(1, 1); 
    cudaMemcpy(dev_m1, m1, size, cudaMemcpyHostToDevice); 
    cudaMemcpy(dev_m2, m2, size, cudaMemcpyHostToDevice); 
    cudaMemset(dev_mresult,0,size);
    
    fill_matrix_device<<<dimGrid, dimBlock>>>(dev_m, width); 
    matrix_mult_device<<<dimGrid, dimBlock>>>(dev_m1,dev_m2,dev_mresult, width);
    int *mok; 
    mok = (int *)malloc(size); 
    
    cudaMemcpy(mok, dev_m, size, cudaMemcpyDeviceToHost); //Ejercicio 5
    cudaMemcpy(m2, dev_mresult, size, cudaMemcpyDeviceToHost); //ahora m2 tiene el resultado del device

    int ok=1; 
    for(int i=0;i<(width*width);++i) { 
        if(m[i]!=mok[i]) ok=0; 
    } 
    
    fprintf(stdout, "%s\n", ok?"ok":"error"); //printf sobre el ejercicio 5
    
    
    //comprobar si la multiplicación a sido correcta
    ok = 1;
    for(int i = 0 ; i < (width*width);++i){
    	if(m2[i] != mhost[i]){
    		ok = 0;
			break;
    	}
    }
    fprintf(stdout, "%s\n", ok?"ok multiplicacion":"error la multiplicacion ha fallado"); 
    
    free(m); 
    free(m1);
    free(mok);
    free(m2);
    free(mhost); 
    cudaFree(dev_m); 
    cudaFree(dev_m1);
    cudaFree(dev_m2);
    
    return 0; 
}


