#include "dna.h"

double wall_time();

int main(int argc, char *argv[]) {
    int i, j, strandID = -1, n, k;
    int **adjacent;
    char *strand;
    double t1, t2, t3;
    uint8_t len;

    scanf("%d", &n);
    adjacent = (int **)malloc(n * sizeof(int *));
    for (i = 0; i < n; i++) {
        adjacent[i] = (int *)malloc(n * sizeof(int));
        for (j = 0; j < n; j++) {
            scanf("%d", &adjacent[i][j]);
        }
    }

    printf("%d vertices\n", n);
    printf("Adjacency matrix:\n   ");
    for (j = 0; j < n; j++)
        printf("%d  ", j);
    printf("\n");
    for (i = 0; i < n; i++) {
        printf("%d  ", i);
        for (j = 0; j < n; j++) {
            printf("%d  ", adjacent[i][j]);
        }
        printf("\n");
    }

    t1 = wall_time();

    DNA_init();
    pascalRow(0, n);

    t2 = wall_time();

    for (k = n; k > 0; k--) {
        for (i = 0; i < n-1; i++) {
            for (j = i+1; j < n; j++) {
                separate(k, n+1, n+2, i);
                separate(n+1, n+3, n+4, j);
                combine(k, n+2, n+4);
                if (adjacent[i][j])
                    combine(k, n+3, n+3);
                discard(n+3);
            }
        }
        strandID = detect(k);
        if (strandID >= 0)
            break;
    }

    t3 = wall_time();

    if (strandID >= 0) {
        strand = getStrand(strandID, &len);
        printf("\nSolution strand #%d at tube %d: \n", strandID, getStrandTubeID(strandID));
        for (i = 0; i < len; i++) {
            printf("%d ", strand[i]);
        }
        printf("\n");
        printf("\nMaximum clique has size %d: \n", k);
        for (i = 0; i < len; i++) {
            if (strand[i]) {
                printf("%d ", i);                
            }
        }
    } else {
        printf("No solution found\n");
    }
    printf("\nElapsed times: init=%f s, comp=%f s, total=%f s\n",
     t2-t1, t3-t2, t3-t1);

    for (i = 0; i < n; i++)
        free(adjacent[i]);
    free(adjacent);
    DNA_finalize();
    exit(EXIT_SUCCESS);
}