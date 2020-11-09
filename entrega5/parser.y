%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexeme.h"
#include "tree.h"
#include "table.h"
#include "errors.h"
#include "iloc.h"
int yylex(void);
void yyerror (char const *s);
LITERAL_TYPE type_from_lexeme(LEXEME* lexeme);
LITERAL_TYPE infer_type(LITERAL_TYPE type_1, LITERAL_TYPE type_2, char* token);
int infer_type_function(LITERAL_TYPE type_1, LITERAL_TYPE type_2);
void validate_access_to_variable(LEXEME* lexeme);
void validate_vector_access(LEXEME* lexeme);
void validate_function_call(LEXEME* lexeme);
void validate_arguments(FUNCTION_ARGUMENT *arguments_def, FUNCTION_ARGUMENT *arguments_call, char* token);
void validate_variable_attribution(LITERAL_TYPE expected_value, LITERAL_TYPE assigned_value_type, char* token);
void validate_variable_declaration(LEXEME* lexeme);
void validate_function_return_type(LITERAL_TYPE type);
void validate_input_identifier(LEXEME* lexeme);
void validate_output_identifier(LEXEME* lexeme);
void validate_output_literal_type(LITERAL_TYPE type);
void validate_shift_literal(LEXEME* lexeme);
void validate_string_size(LITERAL_TYPE type, int string_length, char* token);
void throw_error(int code);
void throw_error_for_token(int code, char* token);
char *get_error_message(int code);
extern int yylineno;
extern void* arvore;

TABLE_STACK *table_stack = NULL;
FUNCTION_CALL_CONTEXT *function_call_context = NULL;
LITERAL_TYPE current_declaration_type = NONE;
LITERAL_TYPE current_function_type = NONE;
ILOC_INSTRUCTION_LIST *instruction_list = NULL;
char *main_label = NULL;
%}

%verbose
%define parse.error verbose
%union {
        struct lexeme* valor_lexico;
        struct node* node;
        int type;
        struct function_argument* argument;
        int int_v;
}

%token<valor_lexico> TK_PR_INT
%token<valor_lexico> TK_PR_FLOAT
%token<valor_lexico> TK_PR_BOOL
%token<valor_lexico> TK_PR_CHAR
%token<valor_lexico> TK_PR_STRING
%token<valor_lexico> TK_PR_IF
%token<valor_lexico> TK_PR_THEN
%token<valor_lexico> TK_PR_ELSE
%token<valor_lexico> TK_PR_WHILE
%token<valor_lexico> TK_PR_DO
%token<valor_lexico> TK_PR_INPUT
%token<valor_lexico> TK_PR_OUTPUT
%token<valor_lexico> TK_PR_RETURN
%token<valor_lexico> TK_PR_CONST
%token<valor_lexico> TK_PR_STATIC
%token<valor_lexico> TK_PR_FOREACH
%token<valor_lexico> TK_PR_FOR
%token<valor_lexico> TK_PR_SWITCH
%token<valor_lexico> TK_PR_CASE
%token<valor_lexico> TK_PR_BREAK
%token<valor_lexico> TK_PR_CONTINUE
%token<valor_lexico> TK_PR_CLASS
%token<valor_lexico> TK_PR_PRIVATE
%token<valor_lexico> TK_PR_PUBLIC
%token<valor_lexico> TK_PR_PROTECTED
%token<valor_lexico> TK_PR_END
%token<valor_lexico> TK_PR_DEFAULT
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token<valor_lexico> TK_LIT_FALSE
%token<valor_lexico> TK_LIT_TRUE
%token<valor_lexico> TK_LIT_CHAR
%token<valor_lexico> TK_LIT_STRING
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TOKEN_ERRO

%left<valor_lexico> TK_OC_AND TK_OC_OR
%left<valor_lexico> TK_OC_LE TK_OC_GE TK_OC_EQ TK_OC_NE TK_OC_SL TK_OC_SR TK_OC_FORWARD_PIPE TK_OC_BASH_PIPE '<' '>'
%left<valor_lexico> ',' ';' '(' ')' '[' ']' '{' '}' '=' '!' '#' '.' '$' '?' ':' '|' '&' '%' '^'
%left<valor_lexico> '+' '-'
%left<valor_lexico> '*' '/'

%type<node>programa
%type<node>start
%type<node>optional_static
%type<node>optional_const
%type<type>type
%type<node>literal
%type<node>global_variable
%type<int_v>optional_vector_definition_brackets
%type<node>identifier_access
%type<node>global_identifier_list
%type<node>function
%type<node>function_header
%type<argument>parameter_list
%type<argument>parameter_list_tail
%type<node>function_body
%type<node>command_block
%type<node>command_list
%type<node>command
%type<node>variable_declaration
%type<node>local_identifier_list
%type<node>variable_attribution
%type<node>control_flow
%type<node>if
%type<node>for
%type<node>while
%type<node>io_operation
%type<node>input
%type<node>output
%type<node>return_operation
%type<node>return
%type<node>break
%type<node>continue
%type<node>function_call
%type<node>argument_list
%type<node>argument_list_tail
%type<node>argument
%type<node>shift_operation
%type<node>shift_operator
%type<node>expression
%type<node>expression_term
%type<node>unary_expression
%type<node>binary_expression
%type<node>ternary_expression
%type<node>expression_literal

%start programa

%locations

%%

programa: init start destroy { arvore = $2; print_instruction_list($2->code); }

init: start_scope_global {
        // Exemplo de como criar instruções
        // ILOC_OPERAND_LIST *source_operands, *target_operands;
        // ILOC_INSTRUCTION *instruction;

        // // Criando soma
        // source_operands = create_operand_list(generate_register());
        // add_operand(generate_register(), source_operands);

        // target_operands = create_operand_list(generate_register());

        // instruction = create_instruction(ADD, source_operands, target_operands);
        // instruction_list = create_instruction_list(instruction);

        // // Criando multiplicação
        // source_operands = create_operand_list(target_operands->operand);
        // add_operand(generate_register(), source_operands);

        // target_operands = create_operand_list(generate_register());

        // instruction = create_instruction(MULT, source_operands, target_operands);
        // add_instruction(instruction, instruction_list);


        // print_instruction_list(instruction_list);
}

destroy: end_scope {
}

start_scope_global: %empty {
        table_stack = push_table_stack(table_stack, GLOBAL);
}

start_scope_named: %empty {
        table_stack = push_table_stack(table_stack, NAMED);
}

start_scope_unnamed: %empty {
        table_stack = push_table_stack(table_stack, UNNAMED);
}

end_scope: %empty {
        // print_table_stack(table_stack);
        table_stack = pop_table_stack(table_stack);
}

start: global_variable start { $$ = $2; }
        | function start {
                $$ = $1;
                add_child($$, $2);
                if ($2 != NULL)
                    $$->code = concat_instruction_list($$->code, $2->code);
        }
        | %empty { $$ = NULL; }


optional_static: TK_PR_STATIC {}
        | %empty {}

optional_const: TK_PR_CONST {}
        | %empty {}

type: TK_PR_INT { $$ = INT; current_declaration_type = $$; }
        | TK_PR_FLOAT { $$ = FLOAT; current_declaration_type = $$; }
        | TK_PR_BOOL { $$ = BOOL; current_declaration_type = $$; }
        | TK_PR_CHAR { $$ = CHAR; current_declaration_type = $$; }
        | TK_PR_STRING { $$ = STRING; current_declaration_type = $$; }

literal: TK_LIT_INT {
                $$ = create_node(table_stack, $1, INT, 0);
                add_entry(table_stack, $$->lexeme, LIT, INT, NULL, -1);
                $$->local = generate_register();
                $$->code = generate_literal_code($$->lexeme->raw_value, $$->local);
        }
        | TK_LIT_FLOAT { $$ = create_node(table_stack, $1, FLOAT, 0); add_entry(table_stack, $$->lexeme, LIT, FLOAT, NULL, -1); }
        | TK_LIT_TRUE { $$ = create_node(table_stack, $1, BOOL, 0); add_entry(table_stack, $$->lexeme, LIT, BOOL, NULL, -1); }
        | TK_LIT_FALSE { $$ = create_node(table_stack, $1, BOOL, 0); add_entry(table_stack, $$->lexeme, LIT, BOOL, NULL, -1); }
        | TK_LIT_CHAR { $$ = create_node(table_stack, $1, CHAR, 0); add_entry(table_stack, $$->lexeme, LIT, CHAR, NULL, -1); }
        | TK_LIT_STRING { $$ = create_node(table_stack, $1, STRING, 0); add_entry(table_stack, $$->lexeme, LIT, STRING, NULL, -1); }


/* === Global Variable === */

global_variable: optional_static type global_identifier_list ';' { current_declaration_type = NONE; }

optional_vector_definition_brackets: '[' TK_LIT_INT ']' { $$ = $2->literal_value.int_v; free_lexeme($1); free_lexeme($2); }
        | %empty { $$ = -1; }

identifier_access: TK_IDENTIFICADOR '[' expression ']' {
        validate_vector_access($1);
        $$ = create_node_with_type(table_stack, VECTOR_ACCESS, $2, $3->literal_type, 0);
        add_child($$, create_node(table_stack, $1, NONE, $3->string_length));
        add_child($$, $3);
    }
        | TK_IDENTIFICADOR {
            $$ = create_node(table_stack, $1, type_from_lexeme($1), 0);
            validate_access_to_variable($1);
    }

global_identifier_list: TK_IDENTIFICADOR optional_vector_definition_brackets {
                int nature;
                if ($2 == -1) {
                    nature = VAR;
                } else {
                    nature = VEC;
                }
                validate_variable_declaration($1);
                add_global_var_entry(table_stack, $1, nature, current_declaration_type, NULL, $2);
                free_lexeme($1);
        }
            | global_identifier_list ',' TK_IDENTIFICADOR optional_vector_definition_brackets {
                int nature;
                if ($4 == -1) {
                    nature = VAR;
                } else {
                    nature = VEC;
                }
                validate_variable_declaration($3);
                add_global_var_entry(table_stack, $3, nature, current_declaration_type, NULL, $4);
                free_lexeme($3);
        }

/* === Function === */

function: function_header function_body {
                $$ = $1;
                add_child($$, $2);
                $$->code = concat_instruction_list($1->code, $2->code);
        }

function_header: optional_static type TK_IDENTIFICADOR '(' parameter_list ')' {
        add_entry(table_stack, $3, FUNC, $2, $5, -1);
        $$ = create_node(table_stack, $3, $2, 0);
        current_function_type = $2;
        char *label = generate_label();
        $$->local = label;
        $$->code = generate_labeled_nop_code(label);
        if (strcmp($3->raw_value, "main") == 0) {
            main_label = label;
        }
}

parameter_list: optional_const type TK_IDENTIFICADOR parameter_list_tail { $$ = create_argument($4, $2); free_lexeme($3); }
        | %empty { $$ = NULL; }
parameter_list_tail: ',' optional_const type TK_IDENTIFICADOR parameter_list_tail { $$ = create_argument($5, $3); free_lexeme($4); }
        | %empty { $$ = NULL; }

function_body: start_scope_named command_block { $$ = $2; }
command_block: '{' command_list '}' end_scope { $$ = $2; }
command_list: command ';' command_list {
                if ($1 == NULL) {
                    $$ = $3;
                } else {
                    $$ = $1;
                    add_child($$, $3);
                    if ($3 != NULL)
                        $$->code = concat_instruction_list($$->code, $3->code);
                }
        }
        | %empty { $$ = NULL; }


/* === Command === */

command: variable_declaration { $$ = $1; }
        | variable_attribution { $$ = $1; }
        | control_flow { $$ = $1; }
        | io_operation { $$ = $1; }
        | return_operation { $$ = $1; }
        | start_scope_unnamed command_block { $$ = $2; }
        | function_call { $$ = $1; }
        | shift_operation { $$ = $1; }

variable_declaration: optional_static optional_const type local_identifier_list { $$ = $4; }
local_identifier_list: TK_IDENTIFICADOR {
                $$ = NULL;
                validate_variable_declaration($1);
                add_entry(table_stack, $1, VAR, current_declaration_type, NULL, -1);
                free_lexeme($1);
        }
        | local_identifier_list ',' TK_IDENTIFICADOR {
                $$ = $1;
                validate_variable_declaration($3);
                add_entry(table_stack, $3, VAR, current_declaration_type, NULL, -1);
                free_lexeme($3);
        }
        | TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {
                validate_variable_declaration($1);
                add_entry(table_stack, $1, VAR, current_declaration_type, NULL, -1);
                $$ = create_node(table_stack, $2, type_from_lexeme($1), 0);
                add_child($$, create_node(table_stack, $1, type_from_lexeme($1), 0));
                add_child($$, create_node(table_stack, $3, type_from_lexeme($3), 0));
                validate_variable_attribution(type_from_lexeme($1), type_from_lexeme($3), $1->raw_value);
                update_string_var_size_identifier(table_stack, type_from_lexeme($1), $1->raw_value, $3->raw_value);
        }
        | local_identifier_list ',' TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR {
                validate_variable_declaration($3);
                add_entry(table_stack, $3, VAR, current_declaration_type, NULL, -1);
                $$ = create_node(table_stack, $4, type_from_lexeme($3), 0);
                add_child($$, create_node(table_stack, $3, type_from_lexeme($3), 0));
                add_child($$, create_node(table_stack, $5, type_from_lexeme($5), 0));
                add_child($$, $1);
                validate_variable_attribution(type_from_lexeme($3), type_from_lexeme($5), $3->raw_value);
                update_string_var_size_identifier(table_stack, type_from_lexeme($3), $3->raw_value, $5->raw_value);
        }
        | TK_IDENTIFICADOR TK_OC_LE literal {
                validate_variable_declaration($1);
                add_entry(table_stack, $1, VAR, current_declaration_type, NULL, -1);
                $$ = create_node(table_stack, $2, type_from_lexeme($1), 0);
                add_child($$, create_node(table_stack, $1, type_from_lexeme($1), $3->string_length));
                add_child($$, $3);
                validate_variable_attribution(type_from_lexeme($1), $3->literal_type, $1->raw_value);
                update_string_var_size_identifier(table_stack, type_from_lexeme($1), $1->raw_value, $3->lexeme->raw_value);
        }
        | local_identifier_list ',' TK_IDENTIFICADOR TK_OC_LE literal {
                validate_variable_declaration($3);
                add_entry(table_stack, $3, VAR, current_declaration_type, NULL, -1);
                $$ = create_node(table_stack, $4, type_from_lexeme($3), 0);
                add_child($$, create_node(table_stack, $3, type_from_lexeme($3), $5->string_length));
                add_child($$, $5); add_child($$, $1);
                validate_variable_attribution(type_from_lexeme($3), $5->literal_type, $3->raw_value);
                update_string_var_size_identifier(table_stack, type_from_lexeme($3), $3->raw_value, $5->lexeme->raw_value);
        }

variable_attribution: identifier_access '=' expression {
                $$ = create_node(table_stack, $2, $1->literal_type, $1->string_length);
                add_child($$, $1);
                add_child($$, $3);
                validate_variable_attribution($1->literal_type, $3->literal_type, "=");
                update_string_var_size_expression(table_stack, $3->literal_type, $1->lexeme->raw_value, $3->string_length);
                validate_string_size($1->literal_type, $3->string_length, $1->lexeme->raw_value);
                TABLE_ENTRY* entry = symbol_lookup(table_stack, $1->lexeme->raw_value);

                if (entry->scope_type == GLOBAL) {
                    $$->code = generate_attribution_code($3->local, "rbss", entry->memory_address);
                } else {
                    $$->code = generate_attribution_code($3->local, "rfp", entry->memory_address);
                }
                $$->code = concat_instruction_list($3->code, $$->code);
        }

control_flow: if { $$ = $1; }
        | for { $$ = $1; }
        | while { $$ = $1; }

if: TK_PR_IF '(' expression ')' start_scope_unnamed command_block {
                $$ = create_node(table_stack, $1, NONE, 0);
                add_child($$, $3);
                add_child($$, $6);

                ILOC_INSTRUCTION* nop_before = create_instruction(NOP, NULL, NULL);
                nop_before->label = generate_label();

                ILOC_INSTRUCTION* nop_after = create_instruction(NOP, NULL, NULL);
                nop_after->label = generate_label();


                $$->code = generate_if_code($3->local, nop_before->label, nop_after->label);
                $$->code = concat_instruction_list($3->code, $$->code);
                add_instruction(nop_before, $$->code);
                $$->code = concat_instruction_list($$->code, $6->code);
                add_instruction(nop_after, $$->code);
        }
        | TK_PR_IF '(' expression ')' start_scope_unnamed command_block TK_PR_ELSE start_scope_unnamed command_block {
                $$ = create_node(table_stack, $1, NONE, 0);
                add_child($$, $3);
                add_child($$, $6);
                free_lexeme($7);
                add_child($$, $9);

                ILOC_INSTRUCTION* nop_before = create_instruction(NOP, NULL, NULL);
                nop_before->label = generate_label();

                ILOC_INSTRUCTION* nop_else = create_instruction(NOP, NULL, NULL);
                nop_else->label = generate_label();

                ILOC_INSTRUCTION* nop_after = create_instruction(NOP, NULL, NULL);
                nop_after->label = generate_label();

                $$->code = generate_if_code($3->local, nop_before->label, nop_else->label);
                $$->code = concat_instruction_list($3->code, $$->code);
                add_instruction(nop_before, $$->code);
                $$->code = concat_instruction_list($$->code, $6->code);
                $$->code = concat_instruction_list($$->code, generate_jumpi_code(nop_after->label));
                add_instruction(nop_else, $$->code);
                $$->code = concat_instruction_list($$->code, $9->code);
                add_instruction(nop_after, $$->code);
        }
for: TK_PR_FOR '(' variable_attribution ':' expression ':' variable_attribution ')' start_scope_unnamed command_block { $$ = create_node(table_stack, $1, NONE, 0);
                                                                                                    add_child($$, $3);
                                                                                                    free_lexeme($4);
                                                                                                    add_child($$, $5);
                                                                                                    free_lexeme($6);
                                                                                                    add_child($$, $7);
                                                                                                    add_child($$, $10); }
while: TK_PR_WHILE '(' expression ')' TK_PR_DO start_scope_unnamed command_block {
                $$ = create_node(table_stack, $1, NONE, 0);
                add_child($$, $3);
                add_child($$, $7);

                ILOC_INSTRUCTION* nop_condition = create_instruction(NOP, NULL, NULL);
                nop_condition->label = generate_label();

                ILOC_INSTRUCTION* nop_block = create_instruction(NOP, NULL, NULL);
                nop_block->label = generate_label();

                ILOC_INSTRUCTION* nop_after = create_instruction(NOP, NULL, NULL);
                nop_after->label = generate_label();

                $$->code = create_instruction_list(nop_condition);
                $$->code = concat_instruction_list($$->code, $3->code);
                $$->code = concat_instruction_list($$->code, generate_if_code($3->local, nop_block->label, nop_after->label));
                add_instruction(nop_block, $$->code);
                $$->code = concat_instruction_list($$->code, $7->code);
                $$->code = concat_instruction_list($$->code, generate_jumpi_code(nop_condition->label));
                add_instruction(nop_after, $$->code);
        }

io_operation: input { $$ = $1; }
        | output { $$ = $1; }
input: TK_PR_INPUT TK_IDENTIFICADOR { $$ = create_node(table_stack, $1, NONE, 0); add_child($$, create_node(table_stack, $2, type_from_lexeme($2), 0)); validate_input_identifier($2); }
output: TK_PR_OUTPUT TK_IDENTIFICADOR { $$ = create_node(table_stack, $1, NONE, 0); add_child($$, create_node(table_stack, $2, type_from_lexeme($2), 0)); validate_output_identifier($2); }
        | TK_PR_OUTPUT literal { $$ = create_node(table_stack, $1, NONE, 0); add_child($$, $2); validate_output_literal_type($2->literal_type); }

return_operation: return { $$ = $1; }
        | break { $$ = $1; }
        | continue { $$ = $1; }
return: TK_PR_RETURN expression {
                $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length);
                add_child($$, $2);
                validate_function_return_type($2->literal_type);
                $$->code = $2->code;
        }
break: TK_PR_BREAK { $$ = create_node(table_stack, $1, NONE, 0); }
continue: TK_PR_CONTINUE { $$ = create_node(table_stack, $1, NONE, 0); }

function_call: TK_IDENTIFICADOR '(' argument_list ')' {
                $$ = create_node_with_type(table_stack, FUNCTION_CALL, $1, type_from_lexeme($1), 0);
                add_child($$, $3);
                validate_function_call($1);
                function_call_context = pop_function_call_context(function_call_context);
        }

push_context: %empty { function_call_context = push_function_call_context(function_call_context); }

argument_list: push_context argument argument_list_tail {
                $$ = $2;
                add_child($$, $3);
                function_call_context->arguments = create_argument(function_call_context->arguments, $2->literal_type);
        }
        | push_context { $$ = NULL; }
argument_list_tail: ',' argument argument_list_tail {
                $$ = $2;
                add_child($$, $3);
                function_call_context->arguments = create_argument(function_call_context->arguments, $2->literal_type);
        }
        | %empty { $$ = NULL; }
argument: expression { $$ = $1; }

shift_operation: identifier_access shift_operator TK_LIT_INT { $$ = $2; add_child($$, $1); add_child($$, create_node(table_stack, $3, INT, 0)); validate_shift_literal($3); }
shift_operator: TK_OC_SL { $$ = create_node(table_stack, $1, infer_type($1->literal_type, INT, $1->raw_value), 0); }
        | TK_OC_SR { $$ = create_node(table_stack, $1, infer_type($1->literal_type, INT, $1->raw_value), 0); }

/* === Expression === */

expression: unary_expression { $$ = $1; }
        | expression_term { $$ = $1; }
        | binary_expression { $$ = $1; }
        | ternary_expression { $$ = $1; }

expression_term: expression_literal { $$ = $1; }
        | identifier_access {
            $$ = $1;
            TABLE_ENTRY* entry = symbol_lookup(table_stack, $$->lexeme->raw_value);
            $$->local = generate_register();
            if (entry->scope_type == GLOBAL) {
                $$->code = generate_load_code("rbss", entry->memory_address, $$->local);
            } else {
                $$->code = generate_load_code("rfp", entry->memory_address, $$->local);
            }
        }
        | function_call { $$ = $1;}
        | '(' expression ')' { $$ = $2; }

unary_expression: '+' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '-' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '!' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '&' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '*' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '?' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }
        | '#' expression { $$ = create_node(table_stack, $1, $2->literal_type, $2->string_length); add_child($$, $2); }

binary_expression: expression '+' expression {
                $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(ADD, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression '-' expression {
                $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(SUB, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression '*' expression {
                $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(MULT, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression '/' expression {
                $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(DIV, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression '%' expression { $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length); add_child($$, $1); add_child($$, $3); }
        | expression '|' expression { $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length); add_child($$, $1); add_child($$, $3); }
        | expression '&' expression { $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length); add_child($$, $1); add_child($$, $3); }
        | expression '^' expression { $$ = create_node(table_stack, $2, infer_type($1->literal_type, $3->literal_type, $2->raw_value), $1->string_length + $3->string_length); add_child($$, $1); add_child($$, $3); }
        | expression '>' expression {
                $$ = create_node(table_stack, $2, BOOL, 0);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(CMP_GT, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression '<' expression {
                $$ = create_node(table_stack, $2, BOOL, 0);
                add_child($$, $1);
                add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(CMP_LT, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression TK_OC_LE expression {
                $$ = create_node(table_stack, $2, BOOL, 0);
                add_child($$, $1); add_child($$, $3);
                $$->local = generate_register();
                $$->code = generate_binary_expression_code(CMP_LE, $1->local, $3->local, $$->local);
                $$->code = concat_instruction_list($3->code, $$->code);
                $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression TK_OC_GE expression {
            $$ = create_node(table_stack, $2, BOOL, 0);
            add_child($$, $1);
            add_child($$, $3);
            $$->local = generate_register();
            $$->code = generate_binary_expression_code(CMP_GE, $1->local, $3->local, $$->local);
            $$->code = concat_instruction_list($3->code, $$->code);
            $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression TK_OC_EQ expression {
            $$ = create_node(table_stack, $2, BOOL, 0);
            add_child($$, $1);
            add_child($$, $3);
            $$->local = generate_register();
            $$->code = generate_binary_expression_code(CMP_EQ, $1->local, $3->local, $$->local);
            $$->code = concat_instruction_list($3->code, $$->code);
            $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression TK_OC_NE expression {
            $$ = create_node(table_stack, $2, BOOL, 0);
            add_child($$, $1);
            add_child($$, $3);
            $$->local = generate_register();
            $$->code = generate_binary_expression_code(CMP_NE, $1->local, $3->local, $$->local);
            $$->code = concat_instruction_list($3->code, $$->code);
            $$->code = concat_instruction_list($1->code, $$->code);
        }
        | expression TK_OC_AND expression { $$ = create_node(table_stack, $2, BOOL, 0); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_OR expression { $$ = create_node(table_stack, $2, BOOL, 0); add_child($$, $1); add_child($$, $3); }

ternary_expression: expression_term '?' expression ':' expression { $$ = create_node_with_type(table_stack, TERNARY_EXPRESSION, $2, NONE, 0);
                                                                    add_child($$, $1);
                                                                    add_child($$, $3);
                                                                    free_lexeme($4);
                                                                    add_child($$, $5); }

expression_literal: TK_LIT_INT {
                $$ = create_node(table_stack, $1, INT, 0);
                add_entry(table_stack, $$->lexeme, LIT, INT, NULL, -1);
                $$->local = generate_register();
                $$->code = generate_literal_code($$->lexeme->raw_value, $$->local);
        }
        | TK_LIT_FLOAT { $$ = create_node(table_stack, $1, FLOAT, 0); add_entry(table_stack, $$->lexeme, LIT, FLOAT, NULL, -1); }
        | TK_LIT_TRUE { $$ = create_node(table_stack, $1, BOOL, 0); add_entry(table_stack, $$->lexeme, LIT, BOOL, NULL, -1); }
        | TK_LIT_FALSE { $$ = create_node(table_stack, $1, BOOL, 0); add_entry(table_stack, $$->lexeme, LIT, BOOL, NULL, -1); }
        | TK_LIT_STRING { $$ = create_node(table_stack, $1, STRING, 0); add_entry(table_stack, $$->lexeme, LIT, STRING, NULL, -1); }
        | TK_LIT_CHAR { $$ = create_node(table_stack, $1, CHAR, 0); add_entry(table_stack, $$->lexeme, LIT, CHAR, NULL, -1); }

%%

void yyerror(char const *s) {
    fprintf(stderr,"ERROR: line %d - %s\n", yylineno, s);
}

LITERAL_TYPE type_from_lexeme(LEXEME* lexeme) {
    if (lexeme == NULL) return NONE;

    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
        return NONE;
    }

    return entry->type;
}

void validate_access_to_variable(LEXEME* lexeme) {
    if (lexeme == NULL) return;

    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
    }

    if (entry->nature == VAR) {
        return;
    }

    if (entry->nature == FUNC) {
        throw_error_for_token(ERR_FUNCTION, lexeme->raw_value);
    }

    if (entry->nature == VEC) {
        throw_error_for_token(ERR_VECTOR, lexeme->raw_value);
    }
}

void validate_vector_access(LEXEME* lexeme) {
    if (lexeme == NULL) return;

    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
    }

    if (entry->nature == VEC) {
        return;
    }

    if (entry->nature == FUNC) {
        throw_error_for_token(ERR_FUNCTION, lexeme->raw_value);
    }

    if (entry->nature == VAR) {
        throw_error_for_token(ERR_VARIABLE, lexeme->raw_value);
    }
}

void validate_function_call(LEXEME* lexeme) {
    if (lexeme == NULL) return;

    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
    }

    validate_arguments(entry->arguments, function_call_context->arguments, lexeme->raw_value);

    if (entry->nature == FUNC) {
        return;
    }

    if (entry->nature == VAR) {
        throw_error_for_token(ERR_VARIABLE, lexeme->raw_value);
    }

    if (entry->nature == VEC) {
        throw_error_for_token(ERR_VECTOR, lexeme->raw_value);
    }
}

void validate_arguments(FUNCTION_ARGUMENT *arguments_def, FUNCTION_ARGUMENT *arguments_call, char* token) {
    if (arguments_def == NULL && arguments_call == NULL) {
        return;
    }

    if (arguments_def == NULL) {
        throw_error_for_token(ERR_EXCESS_ARGS, token);
    }

    if (arguments_call == NULL) {
        throw_error_for_token(ERR_MISSING_ARGS, token);
    }

    if (infer_type_function(arguments_def->type, arguments_call->type) == 1) {
        throw_error_for_token(ERR_WRONG_TYPE_ARGS, token);
    }

    validate_arguments(arguments_def->next, arguments_call->next, token);
}

void validate_function_return_type(LITERAL_TYPE type) {
    if (infer_type_function(type, current_function_type) == 1) {
        throw_error(ERR_WRONG_PAR_RETURN);
    }
}

void throw_error(int code) {
    fprintf(stderr,"ERROR: line %d - %s\n", yylineno, get_error_message(code));
    exit(code);
}

void throw_error_for_token(int code, char* token) {
    fprintf(stderr,"ERROR: line %d, token %s - %s\n", yylineno, token, get_error_message(code));
    exit(code);
}

char *get_error_message(int code) {
    switch(code) {
    case ERR_UNDECLARED:
        return "Undefined token";
    case ERR_DECLARED:
        return "Token has already been declared";
    case ERR_VARIABLE:
        return "Variable cannot be accessed as vector or function";
    case ERR_VECTOR:
        return "Vector cannot be used as a variable or a function";
    case ERR_FUNCTION:
        return "Function cannot be used as a variable";
    case ERR_WRONG_TYPE:
        return "Cannot assign with incompatible types";
    case ERR_STRING_TO_X:
        return "Strings cannot be coherced to other types";
    case ERR_CHAR_TO_X:
        return "Chars cannot be coherced to other types";
    case ERR_STRING_SIZE:
        return "Cannot assign a string greater than the variable size";
    case ERR_MISSING_ARGS:
        return "There are missing arguments on a function call";
    case ERR_EXCESS_ARGS:
        return "There are extra arguments on a function call";
    case ERR_WRONG_TYPE_ARGS:
        return "Function cannot be called with incompatible argument types";
    case ERR_WRONG_PAR_RETURN:
        return "Type mismatch between function declaration and return";
    case ERR_WRONG_PAR_INPUT:
        return "Input variable must be an integer or a float";
    case ERR_WRONG_PAR_OUTPUT:
        return "Output must be an integer or a float";
    case ERR_WRONG_PAR_SHIFT:
        return "Greatest allowed value for shift is 16";
    }
    return "[Error Description]";
}

LITERAL_TYPE infer_type(LITERAL_TYPE type_1, LITERAL_TYPE type_2, char* token) {
    if (type_1 == type_2)
        return type_1;
    if (type_1 == STRING || type_2 == STRING)
        throw_error_for_token(ERR_STRING_TO_X, token);
    if (type_1 == CHAR || type_2 == CHAR)
        throw_error_for_token(ERR_CHAR_TO_X, token);
    if (type_1 == FLOAT || type_2 == FLOAT)
        return FLOAT;
    if (type_1 == INT || type_2 == INT)
        return INT;
    return BOOL;
}

int infer_type_function(LITERAL_TYPE type_1, LITERAL_TYPE type_2) {
    if (type_1 == type_2)
        return 0;
    if (type_1 == STRING || type_2 == STRING)
        return 1;
    if (type_1 == CHAR || type_2 == CHAR)
        return 1;
    return 0;
}

void validate_variable_attribution(LITERAL_TYPE expected_value, LITERAL_TYPE assigned_value_type, char* token) {
    if (expected_value == assigned_value_type) {
        return;
    }

    if (assigned_value_type == STRING) {
        throw_error_for_token(ERR_WRONG_TYPE, token);
    }

    if (assigned_value_type == CHAR) {
        throw_error_for_token(ERR_WRONG_TYPE, token);
    }
}

void validate_variable_declaration(LEXEME* lexeme) {
    TABLE_ENTRY* entry = symbol_lookup_single_scope(table_stack, lexeme->raw_value);

    if (entry != NULL) {
        throw_error_for_token(ERR_DECLARED, lexeme->raw_value);
    }
}


void validate_input_identifier(LEXEME* lexeme) {
    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
    }

    if (entry->type == INT || entry->type == FLOAT) return;

    throw_error_for_token(ERR_WRONG_PAR_INPUT, lexeme->raw_value);
}

void validate_output_identifier(LEXEME* lexeme) {
    TABLE_ENTRY* entry = symbol_lookup(table_stack, lexeme->raw_value);

    if (entry == NULL) {
        throw_error_for_token(ERR_UNDECLARED, lexeme->raw_value);
    }

    if (entry->type == INT || entry->type == FLOAT) return;

    throw_error_for_token(ERR_WRONG_PAR_OUTPUT, lexeme->raw_value);
}

void validate_output_literal_type(LITERAL_TYPE type) {
    if (type == INT || type == FLOAT) return;

    throw_error(ERR_WRONG_PAR_OUTPUT);
}

void validate_shift_literal(LEXEME* lexeme) {
    if (lexeme->literal_value.int_v > 16) throw_error_for_token(ERR_WRONG_PAR_SHIFT, lexeme->raw_value);
}

void validate_string_size(LITERAL_TYPE type, int string_length, char* token) {
    if(type != STRING) return;

    int var_size = symbol_lookup(table_stack, token)->size;

    if(var_size < string_length) {
        throw_error_for_token(ERR_STRING_SIZE, token);
    }
}
