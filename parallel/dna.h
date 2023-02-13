#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MAX_STRAND_LENGTH 64
#define MAX_STRAND_COUNT 134217728
//#define MAX_STRAND_COUNT 33554432
//#define MAX_STRAND_COUNT 65536
//#define MAX_STRAND_COUNT 4096
#define ithBit(strandID, i) (strandID)*MAX_STRAND_LENGTH+i

void DNA_init();
void DNA_finalize();
void showActiveStrands();
char* getStrand(int, uint8_t*);
int getStrandTubeID(int);
void separate(int, int, int, int);
void combine(int, int, int);
void amplify(int, int);
void append(int, int, char);
void set(int, int);
void clear(int, int);
int detect(int);
void discard(int);
void twoToN(int, int);
void pascalRow(int, int);
