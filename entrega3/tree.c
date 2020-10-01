#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// export
void exporta(void *root)
{
    if (root == NULL)
        return;
    NODE *node = (NODE *)root;
    print_node(node);
    if (node->children == NULL)
        return;
    for (int i = 0; i < node->children_count; i++)
    {
        exporta(node->children[i]);
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
    free(lexeme);
    if (lexeme_type == LITERAL)
        if (literal_type != STRING)
            return;
    if (string_value == NULL)
        return;
    free(string_value);
}

NODE *create_node(LEXEME *lexeme)
{
    if (lexeme == NULL)
        return NULL;
    NODE *node = malloc(sizeof(NODE));
    node->children_count = 0;
    node->children = NULL;
    node->lexeme = lexeme;

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
        memcpy(new_children_array, parent->children, new_children_size);
        free(parent->children);
    }

    parent->children_count = new_children_count;
    parent->children = new_children_array;
    parent->children[new_children_count - 1] = child;
}

void print_node(NODE *node)
{
    if (node == NULL)
        return;
    if (node->lexeme == NULL)
        return;
    LEXEME *lexeme = node->lexeme;
    switch (lexeme->type)
    {
    case SPECIAL_CHAR:
    case OPERATOR:
    case IDENTIFIER:
        printf("%s\n", lexeme->literal_value.string);
        break;

    default:
        printf("TODO\n");
        break;
    }
}
