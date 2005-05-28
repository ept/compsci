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
    i = 0;
    while (i<257) {
        count[i] = make_node();
        count[i]->ch = i;
        i++;
    }
    i = decode_table(count, buf);
    make_codes(count);
    current = root = make_root(count);
    while (i<size) {
        for (j=7; j>=0; j--) {
            if (buf[i] & (1 << j)) current = (Node*) current->l; else
                current = (Node*) current->r;
            if (!current->l || !current->r) {
                if (current->ch == 256) return 0;
                ch = current->ch;
                fwrite(&ch, 1, 1, stdout);
                current = root;
            }
        }
        i++;
    }
    return 0;
}
