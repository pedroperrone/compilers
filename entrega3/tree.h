#ifndef __tree__
#define __tree__

#include "lexeme.h"

typedef enum node_type
{
    ANY,
    TERNARY_EXPRESSION,
    FUNCTION_CALL,
    VECTOR_ACCESS
} NODE_TYPE;

typedef struct node
{
    LEXEME *lexeme;
    NODE_TYPE type;
    int children_count;
    struct node **children;
} NODE;

#endif

NODE *create_node(LEXEME *lexeme);
NODE *create_node_with_type(NODE_TYPE type, LEXEME *lexeme);
void add_child(NODE *parent, NODE *child);
void print_node(NODE *node);
void print_all_connections(NODE *node);
void print_all_nodes(NODE *node);
void print_node_label(NODE *node);
void free_lexeme(LEXEME *lexeme);
