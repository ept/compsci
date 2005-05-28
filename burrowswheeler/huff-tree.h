typedef struct {
    unsigned int weight, depth, code, ch;
    void *l, *r;
} Node;

Node *make_node();
void make_tree(Node *nodes[]);
void make_codes(Node *nodes[]);
Node *make_root(Node *nodes[]);
int encode_table(Node *nodes[], unsigned char *buf);
