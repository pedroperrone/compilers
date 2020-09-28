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
