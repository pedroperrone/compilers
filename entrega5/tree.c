#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// export
void exporta(void *root)
{
    NODE *node = (NODE *)root;

    print_all_nodes(node);
    print_all_connections(node);
}

void print_all_nodes(NODE *node)
{
    if (node == NULL)
        return;

    /* Export format used for automated tests
    printf("[NODE] ");
    print_node_label(node);
    printf("\n");
    */

    printf("%p [label=\"", node);
    print_node_label(node);
    print_node_type(node);
    printf("\"];\n");

    if (node->children == NULL)
        return;
    for (int i = 0; i < node->children_count; i++)
    {
        print_all_nodes(node->children[i]);
    }
}

void print_all_connections(NODE *node)
{
    if (node == NULL)
        return;

    if (node->children == NULL)
        return;
    for (int i = 0; i < node->children_count; i++)
    {
        /* Export format used for automated tests
        printf("[CONNECTION] ");
        print_node_label(node);
        printf(" => ");
        print_node_label(node->children[i]);
        printf("\n");
        */

        printf("%p, %p\n", node, node->children[i]);

        print_all_connections(node->children[i]);
    }
}

// free
void libera(void *root)
{
    if (root == NULL)
        return;

    NODE *node = (NODE *)root;
    for (int i = 0; i < node->children_count; i++)
    {
        libera(node->children[i]);
    }
    free(node->children);
    free_lexeme(node->lexeme);
    free(node);
}

void free_lexeme(LEXEME *lexeme)
{
    if (lexeme == NULL)
        return;

    char *string_value = lexeme->literal_value.string;
    LEXEME_TYPE lexeme_type = lexeme->type;
    LITERAL_TYPE literal_type = lexeme->literal_type;
    free(lexeme->raw_value);
    free(lexeme);
    if (lexeme_type == LITERAL)
        if (literal_type != STRING)
            return;

    if (lexeme_type == SPECIAL_CHAR)
        return;

    free(string_value);
}

NODE *create_node(TABLE_STACK *table_stack, LEXEME *lexeme, LITERAL_TYPE literal_type, int string_length)
{
    return create_node_with_type(table_stack, ANY, lexeme, literal_type, string_length);
}

NODE *create_node_with_type(TABLE_STACK *table_stack, NODE_TYPE type, LEXEME *lexeme, LITERAL_TYPE literal_type, int string_length)
{
    if (lexeme == NULL)
        return NULL;
    NODE *node = malloc(sizeof(NODE));
    node->children_count = 0;
    node->children = NULL;
    node->lexeme = lexeme;
    node->type = type;
    node->literal_type = literal_type;
    node->local = NULL;
    node->code = NULL;

    if (lexeme->type == LITERAL) {
        node->string_length = strlen(lexeme->raw_value) - 2;
    } else if (lexeme->type == IDENTIFIER) {
        node->string_length = symbol_lookup(table_stack, lexeme->raw_value)->size;
    } else {
        node->string_length = string_length;
    }

    return node;
}

void add_child(NODE *parent, NODE *child)
{
    if (child == NULL)
        return;
    int new_children_count = parent->children_count + 1;
    int new_children_size = sizeof(NODE *) * new_children_count;
    NODE **new_children_array = malloc(new_children_size);
    if (parent->children != NULL)
    {
        memcpy(new_children_array, parent->children, sizeof(NODE *) * parent->children_count);
        free(parent->children);
    }

    parent->children_count = new_children_count;
    parent->children = new_children_array;
    parent->children[new_children_count - 1] = child;
}

void print_node_label(NODE *node)
{
    LEXEME *lexeme = node->lexeme;

    switch (node->type)
    {
    case TERNARY_EXPRESSION:
        printf("?:");
        return;
    case FUNCTION_CALL:
        printf("call %s", lexeme->literal_value.string);
        return;
    case VECTOR_ACCESS:
        printf("[]");
        return;
    default:
        break;
    }

    switch (lexeme->type)
    {
    case LITERAL:
        switch (lexeme->literal_type)
        {
        case INT:
            printf("%d", lexeme->literal_value.int_v);
            break;
        case FLOAT:
            printf("%f", lexeme->literal_value.float_v);
            break;
        case CHAR:
            printf("%c", lexeme->literal_value.char_v);
            break;
        case STRING:
            printf("%s", lexeme->literal_value.string);
            break;
        case BOOL:
            if (lexeme->literal_value.bool_v == 0)
                printf("false");
            else
                printf("true");
            break;
        default:
            break;
        }
        break;
    case SPECIAL_CHAR:
        printf("%c", lexeme->literal_value.char_v);
        break;
    case OPERATOR:
        printf("%s", lexeme->literal_value.string);
        break;
    case KEYWORD:
    case IDENTIFIER:
        printf("%s", lexeme->literal_value.string);
        break;
    default:
        printf("ERROR");
        break;
    }
}

void print_node_type(NODE *node)
{
    if (node == NULL)
        return;
    printf("\t");
    switch (node->literal_type)
    {
    case INT:
        printf("INT");
        break;
    case FLOAT:
        printf("FLOAT");
        break;
    case STRING:
        printf("STRING");
        break;
    case CHAR:
        printf("CHAR");
        break;
    case BOOL:
        printf("BOOL");
        break;
    case NONE:
        printf("NONE");
        break;
    }
}
