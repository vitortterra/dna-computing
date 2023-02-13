#include "dna.h"

double wall_time();

int main(int argc, char *argv[]) {
    
    int i, j, strandID, A, B, C0;
    int **C;
    char *strand;
    double t1, t2, t3, t4, t5;
    uint8_t len;

    scanf("%d", &A);
    scanf("%d", &B);
    C = (int **)malloc(B * sizeof(int *));
    for (i = 0; i < B; i++) {
        scanf("%d", &C0);
        C[i] = (int *)malloc((C0 + 1) * sizeof(int));
        C[i][0] = C0;
        for (j = 1; j <= C0; j++)
            scanf("%d", &C[i][j]);
    }
    printf("%d sets, %d types of elements\n", B, A);
    printf("Sets:\n");
    for (i = 0; i < B; i++) {
        printf("%d {", i);
        for (j = 1; j < C[i][0]; j++)
            printf("%d, ", C[i][j]);
        printf("%d}\n", C[i][j]);
    }

    t1 = wall_time();

    DNA_init();
    twoToN(0, B);   
    append(0, A, 0);
    
    t2 = wall_time();

    for (i = 0; i < B; i++) {
        separate(0, 1, 2, i);   
        for (j = 1; j <= C[i][0]; j++) {   
            set(1, B + C[i][j]);
        }
        combine(0, 1, 2);
    }

    t3 = wall_time();
    
    for (i = B; i < B + A; i++) {
        separate(0, 0, 1, i);
        discard(1);
    }
    
    t4 = wall_time();

    for (i = 0; i < B; i++) {
        for (j = i; j >= 0; j--) {
            separate(j, j+1+B, j, i);
            combine(j+1, j+1, j+1+B);
        }
    }

    t5 = wall_time();
    
    strandID = -1;
    for (i = 0; i < B; i++) {
        strandID = detect(i);
        if (strandID >= 0)
            break;
    }

    if (strandID >= 0) {
        strand = getStrand(strandID, &len);
        printf("\nSolution strand #%d at tube %d: \n", strandID, getStrandTubeID(strandID));
        for (i = 0; i < len; i++) {
            printf("%d ", strand[i]);
        }
        printf("\n");
        printf("\nMinimum set cover: \n");
        for (i = 0; i < B; i++) {
            if (strand[i]) {
                printf("%d {", i);
                for (j = 1; j < C[i][0]; j++)
                    printf("%d, ", C[i][j]);
                printf("%d}\n", C[i][j]);
            }
        }
    }
    else {
        printf("No solution found\n");
    }
    printf("\nElapsed times: init=%f s, comp=%f s, total=%f s, t2=%f s, t3=%f s, t4=%f s\n",
     t2-t1, t5-t2, t5-t1, t3-t2, t4-t3, t5-t4);

    DNA_finalize();
    for (i = 0; i < B; i++)
        free(C[i]);
    free(C);
    exit(EXIT_SUCCESS);
}
