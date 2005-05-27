#include <stdio.h>
#include <string.h>
#include "globals.h"

unsigned char  S[BLOCKSIZE], L[BLOCKSIZE];
unsigned char *M[BLOCKSIZE];
char buf[2];
int I;


int cmp_block(const void *p1, const void *p2) {
    unsigned char *s1 = *((unsigned char**) p1);
    unsigned char *s2 = *((unsigned char**) p2);
    int i;
    for (i=0; i<BLOCKSIZE; i++) {
        if (s1[i] < s2[i]) return -1;
        if (s1[i] > s2[i]) return  1;
    }
    return 0;
}


int main() {
    int n, block=1;
    for (n=0; n<BLOCKSIZE; n++) M[n] = (unsigned char*) malloc(BLOCKSIZE);
    while (1) {
        if (fread(S, 1, BLOCKSIZE, stdin) < BLOCKSIZE) break;
        fprintf(stderr, "Block %d\n", block);
        for (n=0; n<BLOCKSIZE; n++) {
            memcpy(M[n], S+n, BLOCKSIZE-n);
            memcpy(M[n]+BLOCKSIZE-n, S, n);
        }
        qsort(M, BLOCKSIZE, sizeof(void*), cmp_block);
        for (n=0; n<BLOCKSIZE; n++) L[n] = M[n][BLOCKSIZE-1];
        I = 0;
        unsigned char *sp = S;
        while (cmp_block(&sp, M+I) != 0) I++;
        buf[0] = I % 256;
        buf[1] = (I >> 8) % 256;
        fwrite(buf, 1, 2, stdout);
        fwrite(L, 1, BLOCKSIZE, stdout);
        block++;
    }
    for (n=0; n<BLOCKSIZE; n++) free(M[n]);
    return 0;
}
