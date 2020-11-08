#ifndef __table__
#define __table__

#include "lexeme.h"

typedef enum nature
{
    LIT,
    VAR,
    FUNC,
    VEC
} NATURE;

typedef enum scope_type
{
    GLOBAL,
    NAMED,
    UNNAMED
} SCOPE_TYPE;

typedef struct function_argument
{
    LITERAL_TYPE type;
    struct function_argument *next;
} FUNCTION_ARGUMENT;

typedef struct function_call_context
{
    struct function_argument *arguments;
    struct function_call_context *next;
} FUNCTION_CALL_CONTEXT;

typedef struct table_entry
{
    char *key;
    int memory_address;
    NATURE nature;
    LITERAL_TYPE type;
    int vector_size;
    int line;
    int size;
    char *value;
    FUNCTION_ARGUMENT *arguments;
    struct table_entry *next;
    SCOPE_TYPE scope_type;
} TABLE_ENTRY;

typedef struct table_stack
{
    SCOPE_TYPE scope_type;
    int current_displacement;
    struct table_entry *table;
    struct table_stack *child;
} TABLE_STACK;

#endif

TABLE_STACK *create_table_stack();
TABLE_STACK *push_table_stack(TABLE_STACK *table_stack, SCOPE_TYPE scope_type);
TABLE_STACK *pop_table_stack(TABLE_STACK *table_stack);
TABLE_ENTRY *symbol_lookup_single_scope(TABLE_STACK *table_stack, char *key);
TABLE_ENTRY *symbol_lookup(TABLE_STACK *table_stack, char *key);
TABLE_ENTRY *symbol_lookup_entry(TABLE_ENTRY *table_entry, char *key);
FUNCTION_ARGUMENT *create_argument(FUNCTION_ARGUMENT *argument, LITERAL_TYPE type);
FUNCTION_CALL_CONTEXT *push_function_call_context(FUNCTION_CALL_CONTEXT *context);
FUNCTION_CALL_CONTEXT *pop_function_call_context(FUNCTION_CALL_CONTEXT *context);
void add_entry(TABLE_STACK *table_stack, LEXEME *lexeme, NATURE nature, LITERAL_TYPE type, FUNCTION_ARGUMENT *arguments, int vector_size);
void add_global_var_entry(TABLE_STACK *table_stack, LEXEME *lexeme, NATURE nature, LITERAL_TYPE type, FUNCTION_ARGUMENT *arguments, int vector_size);
int get_size(LITERAL_TYPE type, NATURE nature, char *raw_value, int vector_size);
void update_string_var_size_expression(TABLE_STACK *table_stack, LITERAL_TYPE type, char *key, int size);
void update_string_var_size_identifier(TABLE_STACK *table_stack, LITERAL_TYPE type, char *key, char *identifier);
void print_table_stack(TABLE_STACK *table_stack);
void print_table(TABLE_STACK *table);
void print_entries(TABLE_ENTRY *table_entry);
void print_type(LITERAL_TYPE type);
void print_nature(NATURE nature);
void print_arguments(FUNCTION_ARGUMENT *argument);
void free_table_stack(TABLE_STACK *table_stack);
void free_table_entry(TABLE_ENTRY *table_entry);
void free_function_arguments(FUNCTION_ARGUMENT *function_argument);
void free_function_call_context(FUNCTION_CALL_CONTEXT *context);
