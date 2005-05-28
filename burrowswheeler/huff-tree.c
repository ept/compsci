#include <stdio.h>
#include "huff-tree.h"

int cmp_nodes(void *p1, void *p2) {
    Node *n1 = *((Node**) p1);
    Node *n2 = *((Node**) p2);
    if (n1->weight > n2->weight) return +1; else
    if (n1->weight < n2->weight) return -1; else return 0;
}

Node *make_node() {
    Node *n = (Node*) malloc(sizeof(Node));
    n->weight = 0;
    n->code1  = 0;
    n->code2  = 0;
    n->depth  = 0;
    n->ch     = 0;
    n->l      = 0;
    n->r      = 0;
    return n;
}

void add_parent(Node *n, int bit) {
    n->code2 = (n->code2 << 1) | ((n->code1 & 0x80000000) >> 31);
    n->code1 = (n->code1 << 1) | bit;
    n->depth++;
    if (n->l) add_parent((Node*) n->l, bit);
    if (n->r) add_parent((Node*) n->r, bit);
}


Node *make_tree(Node *nodes[]) {
    int i;
    Node *n;
    for (i=257; i>1; i--) {
        qsort(nodes, i, sizeof(Node*), cmp_nodes);
        if (nodes[0]->weight + nodes[1]->weight == 0) {
            nodes[0] = nodes[i-1];
            continue;
        }
        n = make_node();
        n->l = nodes[0]; add_parent(nodes[0], 0);
        n->r = nodes[1]; add_parent(nodes[1], 1);
        n->weight = nodes[0]->weight + nodes[1]->weight;
        nodes[0] = n;
        nodes[1] = nodes[i-1];
    }
    fprintf(stderr, "Huffman table built\n");
    return nodes[0];
}
