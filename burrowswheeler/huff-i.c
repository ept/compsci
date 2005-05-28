#include <stdio.h>
#include "huff-tree.h"

#define BUFSIZE 100000


unsigned char buf[BUFSIZE], enctable[512], output;
int size;
Node *count[257], *root;

int main() {
    int i, j;
    unsigned char ch;
    Node *current;
    size = fread(buf, 1, BUFSIZE, stdin);
    for (i=0; i<257; i++) {
        count[i] = make_node();
        count[i]->ch = i;
        count[i]->weight = (i == 256 ? 1 : 256*buf[2*i+1] + buf[2*i]);
    }
    current = root = make_tree(count);
    for (i=512; i<size; i++) {
        for (j=0; j<8; j++) {
            if (buf[i] & (1 << j)) current = (Node*) current->r; else
                current = (Node*) current->l;
            if (!current->l || !current->r) {
                if (current->ch == 256) return 0;
                ch = current->ch;
                fwrite(&ch, 1, 1, stdout);
                current = root;
            }
        }
    }
    return 0;
}
