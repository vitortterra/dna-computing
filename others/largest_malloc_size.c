#include <stdio.h>
#include <stdlib.h>

static void *malloc_wrap(size_t size)
{
    void *p = malloc(size);
    if (p) {
        printf("Allocated %lu bytes from %p to %p\n", size, p, p + size);
    }
    else {
        printf("Failed to allocated %lu bytes\n", size);
    }
    return p;
}

int main()
{
    size_t step = 0x1000000;
    size_t size = step;
    size_t best = 0;
    while (step > 0)
    {
        void *p = malloc_wrap(size);
        if (p) {
            free(p);
            best = size;
        }
        else {
            step /= 0x10;
        }
        size += step;
    }
    void *p = malloc_wrap(best);
    if (p) {
        return 0;
    }
    else {
        return 1;
    }
}