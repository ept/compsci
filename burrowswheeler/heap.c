/*void swap(void *c1, void *c2, int t_size) {
    void *tmp = malloc(t_size);
    memcpy(tmp, c1,  t_size);
    memcpy(c1,  c2,  t_size);
    memcpy(c2,  tmp, t_size);
    free(tmp);
}*/

void swap(unsigned char *c1, unsigned char *c2) {
    unsigned char tmp;
    tmp = *c1; *c1 = *c2; *c2 = tmp;
}

void upheap(unsigned char *buf, int i) {
    int p = (i + 1) / 2;
    int c1 = 2*p, c2 = 2*p + 1;
    p--; c1--; c2--;
    if ((p >= 0) && (buf[p] < buf[i])) {
        if (buf[c1] > buf[c2]) swap(buf+c1, buf+p); else swap(buf+c2, buf+p);
        upheap(buf, p);
    }
}

void downheap(unsigned char *buf, int p, int size) {
    int c1 = 2*(p+1)-1, c2 = 2*(p+1), max;
    if (c1 >= size) return;
    if (c2 == size) max = c1; else max = (buf[c1] > buf[c2] ? c1 : c2);
    if (buf[max] > buf[p]) {
        swap(buf+max, buf+p);
        downheap(buf, max, size);
    }
}

void sort(unsigned char *buf) {
    int i;
    for (i=0; i<BLOCKSIZE; i++) {
        upheap(buf, i);
        printf("(heapify %2d) ", i);
        fwrite(buf, 1, BLOCKSIZE, stdout);
        printf("\n");
    }
    for (i=BLOCKSIZE-1; i>=0; i--) {
        swap(buf, buf+i);
        downheap(buf, 0, i);
        printf("(sort %2d) ", i);
        fwrite(buf, 1, BLOCKSIZE, stdout);
        printf("\n");
    }
}

