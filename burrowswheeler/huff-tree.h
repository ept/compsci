typedef struct {
    unsigned int weight, depth, code1, code2, ch;
    void *l, *r;
} Node;

Node *make_node();
Node *make_tree(Node *nodes[]);

