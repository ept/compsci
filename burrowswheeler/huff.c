#include <stdio.h>
#include "huff-tree.h"

#define BUFSIZE 100000


unsigned char buf[BUFSIZE], enctable[512], output;
int size;
Node *count[257];

int main() {
    int i, j, k;
    unsigned int bit;
    Node *n;
    size = fread(buf, 1, BUFSIZE, stdin);
    for (i=0; i<257; i++) {
        count[i] = make_node();
        count[i]->ch = i;
    }
    for (i=0; i<size; i++) count[buf[i]]->weight++;
    make_tree(count);
    make_codes(count);
    fwrite(enctable, 1, encode_table(count, enctable), stdout);
    j=7; output = 0;
    for (i=0; i<=size; i++) {
        n = (i == size ? count[256] : count[buf[i]]);
        for (k=n->depth-1; k>=0; k--) {
            bit = n->code & (1 << k);
            if (j > k) bit = bit << (j - k); else bit = bit >> (k - j);
            output |= bit;
            j--;
            if (j < 0) {
                fwrite(&output, 1, 1, stdout);
                j = 7; output = 0;
            }
        }
    }
    if (j < 7) fwrite(&output, 1, 1, stdout);
    return 0;
}
