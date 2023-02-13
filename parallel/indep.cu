#include "dna.h"

double wall_time();

int main(int argc, char *argv[]) {
    
    int i, j, k, strandID, m, n;
    int **edges;
    char *strand;
    double t1, t2, t3, t4;
    uint8_t len;

    scanf("%d", &n);
    scanf("%d", &m);

    edges = (int **)malloc(m * sizeof(int *));
    for (i = 0; i < m; i++) {
        edges[i] = (int *)malloc(2 * sizeof(int));
        scanf("%d %d", &edges[i][0], &edges[i][1]);
    }

    printf("%d vertices, %d edges\n", n, m);
    printf("Edges:\n");
    for (i = 0; i < m; i++) {
        printf("%d %d\n", edges[i][0], edges[i][1]);
    }

    t1 = wall_time();

    DNA_init();
    twoToN(0, n);

    t2 = wall_time();
    
    for (k = 0; k < m; k++){
        separate(0, 1, 2, edges[k][0]);
        separate(1, 3, 4, edges[k][1]);
        discard(3);
        combine(0, 2, 4);
    }

    t3 = wall_time();

    for (i = 0; i < n; i++) {
        for (j = i; j >= 0; j--) {
            separate(j, j+1+n, j, i);
            combine(j+1, j+1, j+1+n);
        }
    }
    
    t4 = wall_time();

    strandID = -1;    	
    for (i = n-1; i >= 0; i--) {
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
        printf("\nMaximum independent set: \n");
        for (i = 0; i < len; i++) {
            if (strand[i]) {
                printf("%d ", i);                
            }
        }
    } else {
        printf("No solution found\n");
    }
    printf("\nElapsed times: init=%f s, comp=%f s, total=%f s, t2=%f s, t3=%f s\n",
     t2-t1, t4-t2, t4-t1, t3-t2, t4-t3);

    DNA_finalize();
    for (i = 0; i < m; i++) {
        free(edges[i]);
    }
    free(edges);
    exit(EXIT_SUCCESS);
}
