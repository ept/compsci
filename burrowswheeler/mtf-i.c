#include <stdio.h>

#define BUFSIZE 256

unsigned char inbuf[BUFSIZE], outbuf[BUFSIZE], map[256], ch;
int size;

int main() {
    int i, j;
    for (i=0; i<256; i++) map[i] = i;
    while (size = fread(inbuf, 1, BUFSIZE, stdin)) {
        for (i=0; i<size; i++) {
            j = inbuf[i];
            ch = map[j];
            outbuf[i] = ch;
            while (j > 0) {
                map[j] = map[j-1]; j--;
            }
            map[0] = ch;
        }
        fwrite(outbuf, 1, size, stdout);
    }
    return 0;
}
