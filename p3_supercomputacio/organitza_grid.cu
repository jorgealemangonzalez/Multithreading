#include <stdio.h>
#include <stdlib.h>
#define DEBUGG 1

//static const int N = 16;  //Siempre matrices cuadradas
static const int N = 36;    //Siempre matrices cuadradas
//...


//Kernel que distribueix la l'execució a la grid
__global__ void organitza_grid(int *array) {



    //Distribueix la grid(blocks i threads) com a un array unidimensional i calcula l'index d'aquesta distribució. 
    //On cada index correspon a un thread de la grid

    int idx = threadIdx.x;
    int idy = threadIdx.y;
    int idblocy = blockIdx.y;
    int idblocx = blockIdx.x;
    int width = gridDim.x * blockDim.x;
    int id_array = (idy*width + idx) + (idblocx * blockDim.x) + (idblocy * width * blockDim.y); 
    array[id_array]=(2*idblocy)+idblocx;
    
    //....
     //Recupera l'index del block a la grid
    //...

    //Guarda resultad al array

    //...

}


__host__ void printa(int *array,int sizex,int sizey)
{

//Els vostre codi...
    for(int i = 0 ; i < sizey ; ++i){      //impresion de la grid dependiendo del tamaño en el eje x e y
        for(int j = 0 ; j < sizex; ++j){
            printf("%d ",array[i*sizex+j]);
        }
        printf("\n");
    }
}   



int main(void) {

    int *dev_a  , gridsizex,gridsizey;
    int *array;
    int size = N*sizeof(int);

    // Reserva memoria al host i al device
    array = (int *)malloc(size); 

    cudaMalloc((void **)&dev_a, size); 

    memset(array,0,N); //inicializamos en 0 el array

    cudaMemcpy(dev_a,array,size,cudaMemcpyHostToDevice); //copiamos el array del host al device

    //Crea blocks de dos dimensions amb diferent nombre de threads. Ex: Comença amb 4x4
    dim3 block_dim(sqrt(N)/2,sqrt(N)/2); //4 threads x bloque, dimension 2*2
    //...

    dim3 grid_dim(sqrt(N)/block_dim.x,sqrt(N)/block_dim.y); //numero de bloques que tendremos

    // Crea i inicialitza una grid en 2 dimensions
    //dim3 grid_dim(grid_dim,block_dim);  //la grid siempre tendra dos bloques en el eje x

    gridsizex = grid_dim.x*block_dim.x;
    gridsizey = grid_dim.y*block_dim.y;
    //...
#if DEBUGG
    printf("Dim block (x,y) %d-%d",block_dim.x,block_dim.y);
    printf("\nDim Grid (blocks)(x,y) %d-%d",grid_dim.x,grid_dim.y);
    printf("\ngrid size (threads)(x,y) %d-%d\n",gridsizex,gridsizey);
#endif

    organitza_grid<<<grid_dim, block_dim>>>(dev_a);
    cudaMemcpy(array,dev_a,size,cudaMemcpyDeviceToHost);


    // Printa els resultats de l'organització de la grid
    printa(array,gridsizex,gridsizey);
   



    return 0;
}
