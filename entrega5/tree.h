#ifndef __tree__
#define __tree__

#include "lexeme.h"
#include "table.h"
#include "iloc.h"

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
    LITERAL_TYPE literal_type;
    int children_count;
    struct node **children;
    int string_length;
    char *local;
    struct iloc_instruction_list *code;
} NODE;

#endif

NODE *create_node(TABLE_STACK *table_stack, LEXEME *lexeme, LITERAL_TYPE literal_type, int string_length);
NODE *create_node_with_type(TABLE_STACK *table_stack, NODE_TYPE type, LEXEME *lexeme, LITERAL_TYPE literal_type, int string_length);
void add_child(NODE *parent, NODE *child);
void print_node(NODE *node);
void print_all_connections(NODE *node);
void print_all_nodes(NODE *node);
void print_node_label(NODE *node);
void free_lexeme(LEXEME *lexeme);
void print_node_type(NODE *node);
