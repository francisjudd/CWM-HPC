//
// Include the usual libraries
//
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>


//
// Include cuda libraries
//
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>

// Define constants for the program (number of elements)
#define NUM_ELS 1024

__global__ void reduction(float *d_input, float *d_output)
{
  // Allocate shared memory
  __shared__ float smem_array[NUM_ELS];


  // Get thread and global thread ID
  int tid  = threadIdx.x;
  int bid  = blockIdx.x;
  int gtid = threadIdx.x + blockIdx.x * blockDim.x;

  // Loads data into shared memory
  smem_array[tid] = d_input[gtid];
  __syncthreads();


  // Binary Tree Reduction Per Block
  for (int d = (blockDim.x)/2; d > 0; d /= 2) {
    __syncthreads();  // ensure previous step completed 
    if (tid<d)  {
      smem_array[tid] += smem_array[tid + d];
    }
  }

  // First thread puts result into global memory
  if (tid==0) {
     d_output[bid] = smem_array[0];
  }
}



////////////////////////////////////////////////////////////////////////////////
// Program main
////////////////////////////////////////////////////////////////////////////////

int main( int argc, const char** argv) 
{
    int num_els, i;
    int num_threads, num_blocks, mem_size;

    // Define  Host Memory Pointers
    float *h_data;
    float *d_input, *d_output;


    // Initialise card
    printf("Enter number of randoms required: ");
    scanf("%d", &num_els);


    // Calculate remainder of num_els and assign extra blocks as required
    div_t result  = div( num_els, NUM_ELS );

    if( result.rem != 0 ) {
      num_blocks  = result.quot + 1;
    } else {
      num_blocks  = result.quot;
    }

    num_threads   = NUM_ELS;
    mem_size      = sizeof(float) * num_els;


    // Allocate host memory to store the input data
    h_data  = (float*) malloc(mem_size);

    // Initialize to integer values between 0 and 1000
    /*for(int i = 0; i < num_els; i++) {
        h_data[i] = 1.0f;
    }*/


    // Allocate device memory input and output arrays
    cudaMalloc((void**)&d_input, mem_size);
    cudaMalloc((void**)&d_output, num_blocks*sizeof(float));

    
    // Declare variables
    curandGenerator_t gen;

    // Create random number generator
    curandCreateGenerator( &gen, CURAND_RNG_PSEUDO_DEFAULT );

    // Set the generator options
    curandSetPseudoRandomGeneratorSeed( gen, 1234ULL );

    // Generate the randoms!!
    curandGenerateUniform( gen, d_input, num_els );
    
    // Copy host memory to device input array
    cudaMemcpy(h_data, d_input, mem_size, cudaMemcpyDeviceToHost);

    for(i = 0; i < num_els;i++) {
      printf("h_data[%d] = %f\n",i,h_data[i]);
    }

    // Execute the kernel
    reduction<<< num_blocks, num_threads>>>(d_input,d_output);


    // Copy result from device to host
    cudaMemcpy(h_data, d_output, num_blocks*sizeof(float), cudaMemcpyDeviceToHost);

    
    // Sum reductions from each block
    for( i = 1; i < num_blocks; i++ ) {
      h_data[0] += h_data[i];
    }

    // Check results
    printf("Reduction error = %f\n",h_data[0]/num_els);


    // Cleanup memory
    curandDestroyGenerator(gen);
    free(h_data);
    cudaFree(d_input);
    cudaFree(d_output);


    // CUDA exit -- needed to flush printf write buffer
    cudaDeviceReset();
}

