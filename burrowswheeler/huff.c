#include <stdio.h>
#include "huff-tree.h"

#define BUFSIZE 100000


unsigned char buf[BUFSIZE], enctable[512], output;
int size;
Node *count[257], *nodes[257];

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
    count[256]->weight = 1;
    memcpy(nodes, count, 257*sizeof(Node*));
    make_tree(nodes);
    for (i=0; i<256; i++) {
        enctable[2*i] = count[i]->weight % 256;
        enctable[2*i+1] = count[i]->weight / 256;
    }
    fwrite(enctable, 1, 512, stdout);
    j=0; output = 0;
    for (i=0; i<=size; i++) {
        n = (i == size ? count[256] : count[buf[i]]);
        for (k=0; k < n->depth; k++) {
            bit = (k > 31 ? n->code2 : n->code1) & (1 << (k % 32));
            if (j > k) bit = bit << (j - k); else bit = bit >> (k - j);
            output |= bit;
            j++;
            if (j == 8) {
                fwrite(&output, 1, 1, stdout);
                j = 0; output = 0;
            }
        }
    }
    if (j > 0) fwrite(&output, 1, 1, stdout);
    return 0;
}
