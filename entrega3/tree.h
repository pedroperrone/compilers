#ifndef __tree__
#define __tree__

#include "lexeme.h"

typedef struct node
{
    LEXEME *lexeme;
    int children_count;
    struct node **children;
} NODE;

#endif

NODE *create_node(LEXEME *lexeme);
void add_child(NODE *parent, NODE *child);
void print_node(NODE *node);
void free_lexeme(LEXEME *lexeme);
