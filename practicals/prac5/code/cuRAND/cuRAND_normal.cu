#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <cuda.h>
#include <curand.h>

int main( void ) {

  // Allocate pointers for host and device memory
  float *h_input, *h_output;
  float *d_input, *d_output;


  // Declare variables
  int length of array;



  size_t mem_size;

  // malloc() host memory - our RAM
  h_input  = (float *)malloc( mem_size );
  h_output = (float *)malloc( mem_size );

  // allocate device memory input and output arrays
  cudaMalloc((void**)&d_input,  mem_size);
  cudaMalloc((void**)&d_output, mem_size);
 
  //
  // Do something here!
  //

    // Copy host memory to device input array
    cudaMemcpy(d_input,  h_input,  mem_size, cudaMemcpyHostToDevice);

    //
    // Do something on GPU!
    //

      // Declare variables
      curandGenerator_t gen;
      
      // Create random number generator
      curandCreateGenerator( &gen, CURAND_RNG_PSEUDO_DEFAULT) );

      // Set the generator options
      curandSetPseudoRandomGeneratorSeed( gen, 1234ULL) );

      // Generate the randoms!!
      curandGenerateNormal( gen, d_input, NUM_ELS, 0.0f, 1.0f) );

      // Send randoms to output array
      d_output = d_input;

    // Copy result from device to host
    cudaMemcpy(h_output, d_output, mem_size, cudaMemcpyDeviceToHost);

  prinf("[%lf

  // cleanup memory
  free(h_input);
  free(h_output);
  cudaFree(d_input);
  cudaFree(d_output);

}
