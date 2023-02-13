#include "dna.h"

uint8_t *length;
int *tubeID; 
char *strands;
long strandCount;

void DNA_init() {
    length = (uint8_t *)calloc((size_t) MAX_STRAND_COUNT, sizeof(uint8_t));
    tubeID = (int *)malloc((size_t) MAX_STRAND_COUNT * sizeof(int));
    memset(tubeID, -1, (size_t) MAX_STRAND_COUNT * sizeof(int));    
    strands = (char *)calloc((size_t) MAX_STRAND_COUNT * (size_t) MAX_STRAND_LENGTH, sizeof(char));
    strandCount = 0;
}

void DNA_finalize() {
    free(length);
    free(tubeID);
    free(strands);
}

void showActiveStrands() {
    int strandID, i;

    printf("Active strands: \n");
    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] >= 0) {
            printf("%d, tube %d: \n", strandID, tubeID[strandID]);
            for (i = 0; i < length[strandID]; i++)
                printf("%d ", strands[ithBit(strandID, i)]);
            printf("\n\n");
        }
    }
    printf("------------------\n");
}

char* getStrand(int strandID, uint8_t * len) {
    char* strand;

    *len = length[strandID];
    strand = (char*)malloc(*len * sizeof(char));  
    memcpy(strand, &strands[ithBit(strandID, 0)], *len * sizeof(char));  

    return strand;
}

int getStrandTubeID(int strandID) {
    return tubeID[strandID];
}

void separate(int T0, int T1, int T2, int i) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++){
        if (tubeID[strandID] == T0) {
            if (strands[ithBit(strandID, i)]) 
                tubeID[strandID] = T1;
            else  
                tubeID[strandID] = T2;
        }
    }
}

void combine(int T, int T1, int T2) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] == T1 || tubeID[strandID] == T2) {
            tubeID[strandID] = T;
        }
    }
}

void amplify(int T0, int T1) {
    int strandID, nextStrandID = strandCount;
    uint8_t len;

    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] == T0) {
            if (strandCount >= (long) MAX_STRAND_COUNT) {
                printf("Maximum number of strands exceeded");
                exit(EXIT_FAILURE);
            }
            len = length[strandID];
            tubeID[nextStrandID] = T1;
            length[nextStrandID] = len;
            memcpy(&strands[ithBit(nextStrandID, 0)], &strands[ithBit(strandID, 0)], len * sizeof(char));
            nextStrandID++;
            strandCount++;
        }
    }
}

void append(int T, int n, char bit) {
    int strandID;
    uint8_t len; 

    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] == T) {
            len = length[strandID];
            if (len + n > MAX_STRAND_LENGTH) {
                printf("Max strand length exceeded");
                exit(EXIT_FAILURE);
            }
            memset(&strands[ithBit(strandID, len)], bit, n * sizeof(char));
            length[strandID] = len + n;
        }
    }
}

void set(int T, int i) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++){
        if (tubeID[strandID] == T) {
            strands[ithBit(strandID, i)] = 1;
        }
    }
}

void clear(int T, int i) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++){
        if (tubeID[strandID] == T) {
            strands[ithBit(strandID, i)] = 0;
        }
    }
}

int detect(int T) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] == T)
            return strandID;
    }
    return -1;
}

void discard(int T) {
    int strandID;

    for (strandID = 0; strandID < strandCount; strandID++) {
        if (tubeID[strandID] == T) {
            tubeID[strandID] = -1;
        }
    }
}

void twoToN(int T, int N) {
    int i;

    tubeID[strandCount] = T;
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

    tubeID[strandCount] = T;
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
