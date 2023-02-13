#include "dna.h"

#define THREADS_PER_BLOCK 1024

#define checkCudaErrors(err)  __checkCudaErrors (err, __FILE__, __LINE__)
inline void __checkCudaErrors(cudaError_t err, const char *file, const int line) {
  if(cudaSuccess != err) {
    fprintf(stderr, "checkCudaErrors() Driver API error = %04d \"%s\" from file <%s>, line %i.\n",
            err, cudaGetErrorString(err), file, line );
    exit(EXIT_FAILURE);
  }
}

uint8_t *length_h, *length_d;
char *strands_h, *strands_d;
int *tubeID_h, *tubeID_d; 
long strandCount;
size_t lengthSize = (size_t) MAX_STRAND_COUNT * sizeof(uint8_t);
size_t tubeIDSize = (size_t) MAX_STRAND_COUNT * sizeof(int);
size_t strandsSize = (size_t) MAX_STRAND_COUNT * (size_t) MAX_STRAND_LENGTH * sizeof(char);


void DNA_init() {
    length_h = (uint8_t *)calloc((size_t) MAX_STRAND_COUNT, sizeof(uint8_t));
    tubeID_h = (int *)malloc((size_t) MAX_STRAND_COUNT * sizeof(int));
    memset(tubeID_h, -1, (size_t) MAX_STRAND_COUNT * sizeof(int));    
    strands_h = (char *)calloc((size_t) MAX_STRAND_COUNT * (size_t) MAX_STRAND_LENGTH, sizeof(char));

    strandCount = 0;

    checkCudaErrors(cudaMalloc((void **) &length_d, lengthSize));
    checkCudaErrors(cudaMemset(length_d, 0, lengthSize));

    checkCudaErrors(cudaMalloc((void **) &tubeID_d, tubeIDSize));
    checkCudaErrors(cudaMemset(tubeID_d, -1, tubeIDSize));

    checkCudaErrors(cudaMalloc((void **) &strands_d, strandsSize));
    checkCudaErrors(cudaMemset(strands_d, 0, strandsSize));
}

void DNA_finalize() {
    checkCudaErrors(cudaFree(length_d));
    checkCudaErrors(cudaFree(tubeID_d));
    checkCudaErrors(cudaFree(strands_d));
    checkCudaErrors(cudaDeviceReset());
    free(length_h);
    free(tubeID_h);
    free(strands_h);
}

void showActiveStrands() {
    int strandID, i;

    checkCudaErrors(cudaMemcpy(length_h, length_d, lengthSize, cudaMemcpyDeviceToHost));
    checkCudaErrors(cudaMemcpy(tubeID_h, tubeID_d, tubeIDSize, cudaMemcpyDeviceToHost));
    checkCudaErrors(cudaMemcpy(strands_h, strands_d, strandsSize, cudaMemcpyDeviceToHost));

    printf("Active strands: \n");
    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID_h[strandID] >= 0) {
            printf("%d, tube %d: \n", strandID, tubeID_h[strandID]);
            for (i = 0; i < length_h[strandID]; i++)
                printf("%d ", strands_h[ithBit(strandID, i)]);
            printf("\n\n");
        }
    }
    printf("------------------\n");
}

char* getStrand(int strandID, uint8_t * len) {
    char* strand;

    checkCudaErrors(cudaMemcpy(len, &length_d[strandID], sizeof(uint8_t), cudaMemcpyDeviceToHost));
    strand = (char*)malloc(*len * sizeof(char));    
    checkCudaErrors(cudaMemcpy(strand, &strands_d[ithBit(strandID, 0)], *len * sizeof(char), cudaMemcpyDeviceToHost));

    return strand;
}

int getStrandTubeID(int strandID) {
    int solutionTubeID;

    checkCudaErrors(cudaMemcpy(&solutionTubeID, &tubeID_d[strandID], sizeof(int), cudaMemcpyDeviceToHost));
    return solutionTubeID;
}

__device__ int nextStrandID_d;

__global__ void amplifyKernel(int T0, int T1, int strandCount, 
    uint8_t * length_d, int * tubeID_d, char * strands_d) {
    
    int strandID = blockIdx.x * blockDim.x + threadIdx.x;
    int localNextStrandID;
    uint8_t len;

    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T0) {
            localNextStrandID = atomicAdd(&nextStrandID_d, 1);
            len = length_d[strandID];
            tubeID_d[localNextStrandID] = T1;
            length_d[localNextStrandID] = len;
            memcpy(&strands_d[ithBit(localNextStrandID, 0)], &strands_d[ithBit(strandID, 0)], len * sizeof(char));
        }
    }
}

void amplify(int T0, int T1) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    checkCudaErrors(cudaMemcpyToSymbol(nextStrandID_d, &strandCount, sizeof(int), 0, cudaMemcpyHostToDevice));
    amplifyKernel<<<numBlocks, THREADS_PER_BLOCK>>>(
        T0,
        T1,
        strandCount,
        length_d, 
        tubeID_d,
        strands_d);
    checkCudaErrors(cudaMemcpyFromSymbol(&strandCount, nextStrandID_d, sizeof(int), 0, cudaMemcpyDeviceToHost));
}

__global__ void appendKernel(int T, int n, char bit, int strandCount, 
    uint8_t * length_d, int * tubeID_d, char * strands_d) {

    int strandID = blockIdx.x * blockDim.x + threadIdx.x;
    uint8_t len;

    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T) {
            len = length_d[strandID];
            if (len + n > MAX_STRAND_LENGTH) {
                printf("Max strand length exceeded");
                return;
            }
            memset(&strands_d[ithBit(strandID, len)], bit, n * sizeof(char));
            length_d[strandID] = len + n;
        }
    }
}

void append(int T, int n, char bit) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    appendKernel<<<numBlocks, THREADS_PER_BLOCK>>>(
        T,
        n, 
        bit,
        strandCount,
        length_d, 
        tubeID_d,
        strands_d);
}

__global__ void separateKernel(int T0, int T1, int T2, int i, int strandCount, 
    int * tubeID_d, char * strands_d) {

    int strandID = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T0) {
            if (strands_d[ithBit(strandID, i)])
                tubeID_d[strandID] = T1;
            else
                tubeID_d[strandID] = T2;
        }
    }
}

void separate(int T0, int T1, int T2, int i) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    separateKernel<<<numBlocks, THREADS_PER_BLOCK>>>(
        T0,
        T1,
        T2,
        i,
        strandCount,
        tubeID_d,
        strands_d);
}

__global__ void combineKernel(int T, int T1, int T2, int strandCount, int * tubeID_d) {
    int strandID = blockIdx.x * blockDim.x + threadIdx.x;

    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T1 || tubeID_d[strandID] == T2) {
            tubeID_d[strandID] = T;
        }
    }
}

void combine(int T, int T1, int T2) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    combineKernel<<<numBlocks, THREADS_PER_BLOCK>>>(
        T, 
        T1, 
        T2,
        strandCount,
        tubeID_d);

}


__global__ void setKernel(int T, int i, int strandCount,
    int * tubeID_d, char * strands_d) {

    int strandID = blockIdx.x * blockDim.x + threadIdx.x;

    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T)
            strands_d[ithBit(strandID, i)] = 1;
    }
}

void set(int T, int i) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    setKernel<<<numBlocks, THREADS_PER_BLOCK>>> (
        T,
        i,
        strandCount,
        tubeID_d,
        strands_d);
}

__global__ void clearKernel(int T, int i, int strandCount,
    int * tubeID_d, char * strands_d) {
        
    int strandID = blockIdx.x * blockDim.x + threadIdx.x;

    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T)
            strands_d[ithBit(strandID, i)] = 0;
    }
}

void clear(int T, int i) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    clearKernel<<<numBlocks, THREADS_PER_BLOCK>>> (
        T,
        i,
        strandCount,
        tubeID_d,
        strands_d);
}

int detect(int T) {
    int strandID;

    checkCudaErrors(cudaMemcpy(tubeID_h, tubeID_d, tubeIDSize, cudaMemcpyDeviceToHost));
    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID_h[strandID] == T)
            return strandID;
    }
    return -1;
}

__global__ void discardKernel(int T, int strandCount, int * tubeID_d) {
    int strandID = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (strandID < strandCount) {
        if (tubeID_d[strandID] == T)
            tubeID_d[strandID] = -1;
    }
}

void discard(int T) {
    int numBlocks = strandCount/THREADS_PER_BLOCK + 1;

    discardKernel<<<numBlocks, THREADS_PER_BLOCK>>>(
        T,
        strandCount,
        tubeID_d);
}

void twoToN(int T, int N) {
    int i;

    checkCudaErrors(cudaMemcpy(&tubeID_d[strandCount], &T, sizeof(int), cudaMemcpyHostToDevice));
    strandCount++;
    for (i = 0; i < N; i++) {
        amplify(T, T+1);
        append(T, 1, 0);
        append(T+1, 1, 1);
        combine(T, T, T+1);
    }
}

void pascalRow(int T, int N) {
    int i, j;

    checkCudaErrors(cudaMemcpy(&tubeID_d[strandCount], &T, sizeof(int), cudaMemcpyHostToDevice));
    strandCount++;
    for (i = 1; i <= N; i++) {
        for (j = 0; j <= i; j++) {
            amplify(T+j, T+j+N);
            append(T+j, 1, 0);
            append(T+j+N, 1, 1);
        }
        for (j = 1; j <= i+1; j++) 
            combine(T+j, T+j, T+j-1+N);
    }   
    discard(N+1);
}
