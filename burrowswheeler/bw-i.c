#include <stdio.h>
#include <string.h>
#include "globals.h"

unsigned char L[BLOCKSIZE], F[BLOCKSIZE], S[BLOCKSIZE];
int T[BLOCKSIZE];
char buf[2];
int I;


int cmp_char(const void *p1, const void *p2) {
    unsigned char c1 = *((unsigned char*) p1);
    unsigned char c2 = *((unsigned char*) p2);
    if (c1 < c2) return -1; else if (c1 > c2) return 1; else return 0;
}


void calcT() {
    int ch, i, j;
    for (ch=0; ch<256; ch++) {
        i = j = 0;
        while (1) {
            while ((i < BLOCKSIZE) && (L[i] != ch)) i++;
            while ((j < BLOCKSIZE) && (F[j] != ch)) j++;
            if ((i == BLOCKSIZE) && (j == BLOCKSIZE)) break;
            if ((i >= BLOCKSIZE) || (j >= BLOCKSIZE)) fprintf(stderr, "Aargh\n");
            T[i] = j;
            i++; j++;
        }
    }
}

int main() {
    int n, block=1;
    while (1) {
        if (fread(buf, 1, 2, stdin) < 2) break;
        I = buf[0] | (buf[1] << 8);
        if (fread(L, 1, BLOCKSIZE, stdin) < BLOCKSIZE) break;
        fprintf(stderr, "Block %d\n", block);
        memcpy(F, L, BLOCKSIZE);
        qsort(F, BLOCKSIZE, 1, cmp_char);
        calcT();
        for (n=BLOCKSIZE-1; n>=0; n--) {
            S[n] = L[I];
            I = T[I];
        }
        fwrite(S, 1, BLOCKSIZE, stdout);
        block++;
    }
    return 0;
}
