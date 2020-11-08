#include "table.h"
#include "iloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

TABLE_STACK *create_table_stack() {
    TABLE_STACK *table_stack = malloc(sizeof(TABLE_STACK));
    table_stack->table = NULL;
    table_stack->child = NULL;

    return table_stack;
}

TABLE_STACK *push_table_stack(TABLE_STACK *table_stack, SCOPE_TYPE scope_type) {
    TABLE_STACK *new_table_stack = create_table_stack();
    new_table_stack->child = table_stack;
    new_table_stack->scope_type = scope_type;

    if (scope_type == UNNAMED) {
        new_table_stack->current_displacement = table_stack->current_displacement;
    } else {
        new_table_stack->current_displacement = 0;
    }

    return new_table_stack;
}

TABLE_STACK *pop_table_stack(TABLE_STACK *table_stack) {
    // print_table(table_stack);
    TABLE_STACK *child = table_stack->child;
    if (table_stack->scope_type == UNNAMED) {
        child->current_displacement = table_stack->current_displacement;
    }
    free_table_stack(table_stack);
    return child;
}

void free_table_stack(TABLE_STACK *table_stack) {
    if (table_stack == NULL) return;

    free_table_entry(table_stack->table);
    free(table_stack);
}

void free_table_entry(TABLE_ENTRY *table_entry) {
    if (table_entry == NULL) return;

    free(table_entry->key);
    free(table_entry->value);
    free_function_arguments(table_entry->arguments);
    free_table_entry(table_entry->next);
    free(table_entry);
}

void free_function_arguments(FUNCTION_ARGUMENT *function_argument) {
    if (function_argument == NULL) return;

    free_function_arguments(function_argument->next);
    free(function_argument);
}

TABLE_ENTRY *symbol_lookup_single_scope(TABLE_STACK *table_stack, char *key) {
    TABLE_ENTRY *table_entry = symbol_lookup_entry(table_stack->table, key);

    if (table_entry != NULL) return table_entry; 

    return NULL;
}

TABLE_ENTRY *symbol_lookup(TABLE_STACK *table_stack, char *key) {
    if (table_stack == NULL) return NULL;

    TABLE_ENTRY *table_entry = symbol_lookup_entry(table_stack->table, key);

    if (table_entry != NULL) return table_entry; 

    return symbol_lookup(table_stack->child, key);
}

TABLE_ENTRY *symbol_lookup_entry(TABLE_ENTRY *table_entry, char *key) {
    if (table_entry == NULL) return NULL;

    if (strcmp(table_entry->key, key) == 0) return table_entry;

    return symbol_lookup_entry(table_entry->next, key);
}

FUNCTION_ARGUMENT *create_argument(FUNCTION_ARGUMENT *argument, LITERAL_TYPE type) {
    FUNCTION_ARGUMENT *function_argument = malloc(sizeof(FUNCTION_ARGUMENT));
    function_argument->type = type;
    function_argument->next = argument;

    return function_argument;
}

FUNCTION_CALL_CONTEXT *push_function_call_context(FUNCTION_CALL_CONTEXT *context) {
    FUNCTION_CALL_CONTEXT *function_call_context = malloc(sizeof(FUNCTION_CALL_CONTEXT));
    function_call_context->next = context;
    function_call_context->arguments = NULL;

    return function_call_context;
}

FUNCTION_CALL_CONTEXT *pop_function_call_context(FUNCTION_CALL_CONTEXT *context) {
    FUNCTION_CALL_CONTEXT *next = context->next;
    free_function_call_context(context);
    return next;
}

void free_function_call_context(FUNCTION_CALL_CONTEXT *context) {
    if(context == NULL) return;

    free_function_arguments(context->arguments);
    free(context);
}

void add_entry(TABLE_STACK *table_stack, LEXEME *lexeme, NATURE nature, LITERAL_TYPE type, FUNCTION_ARGUMENT *arguments, int vector_size) {
    if (symbol_lookup_single_scope(table_stack, lexeme->raw_value)) {
        return;
    }
    TABLE_ENTRY *table_entry = malloc(sizeof(TABLE_ENTRY));
    table_entry->key = strdup(lexeme->raw_value);
    table_entry->nature = nature;
    table_entry->vector_size = vector_size;
    table_entry->type = type;
    table_entry->next = table_stack->table;
    table_entry->value = NULL;
    table_entry->arguments = arguments;
    table_entry->scope_type = table_stack->scope_type;

    if (vector_size >= 0) {
        table_entry->size = get_size(type, nature, lexeme->raw_value, vector_size);
    } else {
        table_entry->size = get_size(type, nature, lexeme->raw_value, 1);
    }

    table_entry->memory_address = table_stack->current_displacement;
    if (nature == VAR) {
        table_stack->current_displacement += table_entry->size;
    }
    table_stack->table = table_entry;
}

void add_global_var_entry(TABLE_STACK *table_stack, LEXEME *lexeme, NATURE nature, LITERAL_TYPE type, FUNCTION_ARGUMENT *arguments, int vector_size) {
    add_entry(table_stack, lexeme, nature, type, arguments, vector_size);
    TABLE_ENTRY *entry = symbol_lookup(table_stack, lexeme->raw_value);
    entry->memory_address = new_global_var_address();
}

int get_size(LITERAL_TYPE type, NATURE nature, char *value, int vector_size) {
        switch (type)
        {
        case INT:
            return 4 * vector_size;
        case FLOAT:
            return 8 * vector_size;
        case CHAR:
            return 1 * vector_size;
        case STRING:
            if (nature == LIT) {
                return strlen(value) - 2;
            } else {
                return 0;
            }
        case BOOL:
            return 1 * vector_size;
        default:
            return 0;
        }
}

void update_string_var_size_expression(TABLE_STACK *table_stack, LITERAL_TYPE type, char *key, int size) {
    if (type != STRING) return;

    TABLE_ENTRY *entry = symbol_lookup(table_stack, key);

    if (entry->size > 0) return;

    entry->size = size;
}

void update_string_var_size_identifier(TABLE_STACK *table_stack, LITERAL_TYPE type, char *key, char *identifier) {
    if (type != STRING) return;
    
    int size = symbol_lookup(table_stack, identifier)->size;
    TABLE_ENTRY *entry = symbol_lookup(table_stack, key);

    if (entry->size > 0) return;

    entry->size = size;
}

void print_table_stack(TABLE_STACK *table_stack) {
    if (table_stack == NULL) return;

    print_table_stack(table_stack->child);
    print_table(table_stack);
}

void print_table(TABLE_STACK *table) {
    printf("====== Table entries ======\n");
    print_entries(table->table);
}

void print_entries(TABLE_ENTRY *table_entry) {
    if (table_entry == NULL) return;

    print_entries(table_entry->next);
    printf("key: %s", table_entry->key);
    printf(",\tmemory_address: %d", table_entry->memory_address);
    printf(",\tnature: ");
    print_nature(table_entry->nature);
    printf(",\ttype: ");
    print_type(table_entry->type);
    printf(",\tsize: %d", table_entry->size);
    printf(",\targuments:");
    print_arguments(table_entry->arguments);
    printf("\n");
}

void print_type(LITERAL_TYPE type) {
    switch (type)
        {
        case INT:
            printf("INT");
            break;
        case FLOAT:
            printf("FLOAT");
            break;
        case CHAR:
            printf("CHAR");
            break;
        case STRING:
            printf("STRING");
            break;
        case BOOL:
            printf("BOOL");
            break;
        default:
            printf("NONE");
            break;
        }
}

void print_nature(NATURE nature) {
    switch (nature)
        {
        case LIT:
            printf("LIT");
            break;
        case VAR:
            printf("VAR");
            break;
        case FUNC:
            printf("FUNC");
            break;
        case VEC:
            printf("VEC");
            break;
        }
}

void print_arguments(FUNCTION_ARGUMENT *argument) {
    if (argument == NULL) return;

    switch (argument->type)
        {
        case INT:
            printf(" INT");
            break;
        case FLOAT:
            printf(" FLOAT");
            break;
        case CHAR:
            printf(" CHAR");
            break;
        case STRING:
            printf(" STRING");
            break;
        case BOOL:
            printf(" BOOL");
            break;
        default:
            printf(" NONE");
            break;
        }

    print_arguments(argument->next);
}
