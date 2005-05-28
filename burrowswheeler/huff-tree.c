#include <stdio.h>
#include "huff-tree.h"

int cmp_nodes(void *p1, void *p2) {
    Node *n1 = *((Node**) p1);
    Node *n2 = *((Node**) p2);
    if (n1->weight > n2->weight) return +1; else
    if (n1->weight < n2->weight) return -1; else
    if (n1->ch     > n2->ch)     return +1; else
    if (n1->ch     < n2->ch)     return -1; else return 0;
}

Node *make_node() {
    Node *n = (Node*) malloc(sizeof(Node));
    n->weight = 0;
    n->code  = 0;
    n->depth  = 0;
    n->ch     = 0;
    n->l      = 0;
    n->r      = 0;
    return n;
}

void add_parent(Node *n, int bit) {
    n->depth++;
    if (n->l) add_parent((Node*) n->l, bit);
    if (n->r) add_parent((Node*) n->r, bit);
}

Node *tmp[257];

void make_tree(Node *nodes[]) {
    int i, offs;
    Node *n, **tmp_nodes = tmp;
    memcpy(tmp_nodes, nodes, 257*sizeof(Node*));
    qsort(tmp_nodes, 257, sizeof(Node*), cmp_nodes);
    offs = 0;
    while ((tmp_nodes[offs]->weight == 0) && (offs <= 256)) offs++;
    tmp_nodes += offs;
    for (i=257-offs; i>1; i--) {
        qsort(tmp_nodes, i, sizeof(Node*), cmp_nodes);
        n = make_node();
        n->l = tmp_nodes[0]; add_parent(tmp_nodes[0], 0);
        n->r = tmp_nodes[1]; add_parent(tmp_nodes[1], 1);
        n->weight = tmp_nodes[0]->weight + tmp_nodes[1]->weight;
        tmp_nodes[0] = n;
        tmp_nodes[1] = tmp_nodes[i-1];
    }
}


void make_codes(Node *nodes[]) {
    int i, j, maxlen = 0, code = 0;
    for (i=0; i<=256; i++) if (nodes[i]->depth > maxlen) maxlen = nodes[i]->depth;
    if (maxlen > 21) {
        fprintf(stderr, "Error: Maximum code length too large (%d).\n", maxlen);
        return;
    }
    for (i=maxlen; i>0; i--) {
        code = code >> 1;
        for (j=256; j>=0; j--)
            if (nodes[j]->depth == i) {
                nodes[j]->code = code;
                code++;
            }
    }
}


Node *do_make_root(Node *nodes[], int prefix, int depth) {
    int i;
    if (depth > 0)
        for (i=0; i<=256; i++)
            if ((nodes[i]->depth == depth) && (nodes[i]->code == prefix))
                return nodes[i];
    Node *n = make_node();
    n->l = do_make_root(nodes, (prefix << 1) + 1, depth + 1);
    n->r = do_make_root(nodes,  prefix << 1     , depth + 1);
    return n;
}


Node *make_root(Node *nodes[]) {
    return do_make_root(nodes, 0, 0);
}


int encode_repeat(int n, unsigned char *buf, int j, int zero) {
    int nibble;
    while (n > 0) {
        nibble = (n & 3) - 1;
        if (nibble < 0) {
            nibble = 3;
            n -= 4;
        }
        nibble |= 8 | (zero << 2);
        buf[j/2] |= nibble << (4*(j%2));
        n >>= 2;
        j++;
    }
    return j;
}


int encode_table(Node *nodes[], unsigned char *buf) {
    int i, j = 0, prev = 0, equal = 0, zero = 0;
    for (i=0; i<256; i++) buf[i] = 0;
    for (i=0; i<256; i++) {
        if (nodes[i]->depth == 0) {
            j = encode_repeat(equal, buf, j, 0); equal = 0;
            zero++; continue;
        }
        j = encode_repeat(zero, buf, j, 1); zero = 0;
        if (nodes[i]->depth == prev) {
            equal++; continue;
        }
        j = encode_repeat(equal, buf, j, 0); equal = 0;
        switch ((nodes[i]->depth - prev + 23) % 23) {
            case  1: buf[j/2] |= 5 << (4*(j%2)); break;
            case  2: buf[j/2] |= 6 << (4*(j%2)); break;
            case  3: buf[j/2] |= 7 << (4*(j%2)); break;
            case 19:                             break;
            case 20: buf[j/2] |= 1 << (4*(j%2)); break;
            case 21: buf[j/2] |= 2 << (4*(j%2)); break;
            case 22: buf[j/2] |= 3 << (4*(j%2)); break;
            default: buf[j/2] |= 4 << (4*(j%2)); j++;
                     buf[j/2] |= ((nodes[i]->depth - prev + 19) % 23) << (4*(j%2));
        }
        j++;
        prev = nodes[i]->depth;
    }
    j = encode_repeat(equal, buf, j, 0);
    j = encode_repeat(zero, buf, j, 1);
    return (j + 1) / 2;
}

int decode_table(Node *nodes[], unsigned char *buf) {
    int i = 0, j = 0, nibble, state = 0, equal = 0, equal_fac = 1,
        zero = 0, zero_fac = 1;
    while (i < 256) {
        nibble = (buf[j/2] >> (4*(j%2))) & 15;
        if (((nibble & 12) != 8) && (equal > 0) || (i + equal >= 256)) {
            equal_fac = 1;
            while (equal > 0) {
                nodes[i]->depth = state;
                i++; equal--;
            }
        }
        if (((nibble & 12) != 12) && (zero > 0) || (i + zero >= 256)) {
            zero_fac = 1;
            while (zero > 0) {
                nodes[i]->depth = 0;
                i++; zero--;
            }
        }
        if (i >= 256) break;
        switch (nibble) {
            case  0: state -= 4; break;
            case  1: state -= 3; break;
            case  2: state -= 2; break;
            case  3: state -= 1; break;
            case  4: j++; state += 4 + ((buf[j/2] >> (4*(j%2))) & 15); break;
            case  5: state += 1; break;
            case  6: state += 2; break;
            case  7: state += 3; break;
            case  8: equal +=   equal_fac; equal_fac *= 4; break;
            case  9: equal += 2*equal_fac; equal_fac *= 4; break;
            case 10: equal += 3*equal_fac; equal_fac *= 4; break;
            case 11: equal += 4*equal_fac; equal_fac *= 4; break;
            case 12: zero  +=    zero_fac;  zero_fac *= 4; break;
            case 13: zero  += 2* zero_fac;  zero_fac *= 4; break;
            case 14: zero  += 3* zero_fac;  zero_fac *= 4; break;
            case 15: zero  += 4* zero_fac;  zero_fac *= 4; break;
        }
        if (state < 1) state += 23;
        if (state > 23) state -= 23;
        if (nibble < 8) {
            nodes[i]->depth = state;
            i++;
        }
        j++;
    }
    return (j + 1) / 2;
}
