%{
#include <stdio.h>
#include "lexeme.h"
#include "tree.h"
int yylex(void);
void yyerror (char const *s);
extern int yylineno;
extern void* arvore;
%}

%verbose
%define parse.error verbose
// TODO: use typedef definition
%union {
	struct lexeme* valor_lexico;
	struct node* node;
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
%type<node>type
%type<node>literal
%type<node>global_variable
%type<node>optional_vector_definition_brackets
%type<node>identifier_access
%type<node>global_identifier_list
%type<node>function
%type<node>function_header
%type<node>parameter_list
%type<node>parameter_list_tail
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

programa: start { arvore = $1; }

start: global_variable start { $$ = $2; }
        | function start { $$ = $1; add_child($$, $2); }
        | %empty{ $$ = NULL; }


optional_static: TK_PR_STATIC {}
        | %empty {}

optional_const: TK_PR_CONST {}
        | %empty {}

type: TK_PR_INT {}
        | TK_PR_FLOAT  {}
        | TK_PR_BOOL {}
        | TK_PR_CHAR {}
        | TK_PR_STRING {}

literal: TK_LIT_INT { $$ = create_node($1); }
        | TK_LIT_FLOAT { $$ = create_node($1); }
        | TK_LIT_TRUE { $$ = create_node($1); }
        | TK_LIT_FALSE { $$ = create_node($1); }
        | TK_LIT_CHAR { $$ = create_node($1); }
        | TK_LIT_STRING { $$ = create_node($1); }


/* === Global Variable === */

global_variable: optional_static type global_identifier_list ';' {}

optional_vector_definition_brackets: '[' TK_LIT_INT ']' {}
        | %empty {}

identifier_access: TK_IDENTIFICADOR '[' expression ']' { $$ = create_node_with_type(VECTOR_ACCESS, $2); add_child($$, create_node($1)); add_child($$, $3); }
        | TK_IDENTIFICADOR { $$ = create_node($1); }

global_identifier_list: TK_IDENTIFICADOR optional_vector_definition_brackets { free_lexeme($1); }
        | TK_IDENTIFICADOR optional_vector_definition_brackets ',' global_identifier_list { free_lexeme($1); }


/* === Function === */

function: function_header function_body { $$ = $1; add_child($$, $2); }

function_header: optional_static type TK_IDENTIFICADOR '(' parameter_list ')' { $$ = create_node($3); }

parameter_list: optional_const type TK_IDENTIFICADOR parameter_list_tail {}
        | %empty {}
parameter_list_tail: ',' optional_const type TK_IDENTIFICADOR parameter_list_tail {}
        | %empty {}

function_body: command_block { $$ = $1; }
command_block: '{' command_list '}' { $$ = $2; }
command_list: command ';' command_list { if($1 == NULL) $$ = $3; else {$$ = $1; add_child($$, $3);} }
        | %empty { $$ = NULL; }


/* === Command === */

command: variable_declaration { $$ = $1; }
        | variable_attribution { $$ = $1; }
        | control_flow { $$ = $1; }
        | io_operation { $$ = $1; }
        | return_operation { $$ = $1; }
        | command_block { $$ = $1; }
        | function_call { $$ = $1; }
        | shift_operation { $$ = $1; }

variable_declaration: optional_static optional_const type local_identifier_list { $$ = $4; }
local_identifier_list: TK_IDENTIFICADOR { $$ = NULL; free_lexeme($1); }
        | TK_IDENTIFICADOR ',' local_identifier_list { $$ = $3; free_lexeme($1); }
        | TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR { $$ = create_node($2); add_child($$, create_node($1)); add_child($$, create_node($3)); }
        | TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR ',' local_identifier_list { $$ = create_node($2); add_child($$, create_node($1)); add_child($$, create_node($3)); add_child($$, $5); }
        | TK_IDENTIFICADOR TK_OC_LE literal { $$ = create_node($2); add_child($$, create_node($1)); add_child($$, $3); }
        | TK_IDENTIFICADOR TK_OC_LE literal ',' local_identifier_list { $$ = create_node($2); add_child($$, create_node($1)); add_child($$, $3); add_child($$, $5); }

variable_attribution: identifier_access '=' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }

control_flow: if { $$ = $1; }
        | for { $$ = $1; }
        | while { $$ = $1; }

if: TK_PR_IF '(' expression ')' command_block { $$ = create_node($1); add_child($$, $3); add_child($$, $5); }
        | TK_PR_IF '(' expression ')' command_block TK_PR_ELSE command_block { $$ = create_node($1);
                                                                               add_child($$, $3);
                                                                               add_child($$, $5);
                                                                               free_lexeme($6);
                                                                               add_child($$, $7); }
for: TK_PR_FOR '(' variable_attribution ':' expression ':' variable_attribution ')' command_block { $$ = create_node($1);
                                                                                                    add_child($$, $3);
                                                                                                    free_lexeme($4);
                                                                                                    add_child($$, $5);
                                                                                                    free_lexeme($6);
                                                                                                    add_child($$, $7);
                                                                                                    add_child($$, $9); }
while: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block { $$ = create_node($1); add_child($$, $3); add_child($$, $6); }

io_operation: input { $$ = $1; }
        | output { $$ = $1; }
input: TK_PR_INPUT TK_IDENTIFICADOR { $$ = create_node($1); add_child($$, create_node($2)); }
output: TK_PR_OUTPUT TK_IDENTIFICADOR { $$ = create_node($1); add_child($$, create_node($2)); }
        | TK_PR_OUTPUT literal { $$ = create_node($1); add_child($$, $2); }

return_operation: return { $$ = $1; }
        | break { $$ = $1; }
        | continue { $$ = $1; }
return: TK_PR_RETURN expression { $$ = create_node($1); add_child($$, $2); }
break: TK_PR_BREAK { $$ = create_node($1); }
continue: TK_PR_CONTINUE { $$ = create_node($1); }

function_call: TK_IDENTIFICADOR '(' argument_list ')' { $$ = create_node_with_type(FUNCTION_CALL, $1); add_child($$, $3); }
argument_list: argument argument_list_tail { $$ = $1; add_child($$, $2); }
        | %empty { $$ = NULL; }
argument_list_tail: ',' argument argument_list_tail { $$ = $2; add_child($$, $3); }
        | %empty { $$ = NULL; }
argument: expression { $$ = $1; }

shift_operation: identifier_access shift_operator TK_LIT_INT { $$ = $2; add_child($$, $1); add_child($$, create_node($3)); }
shift_operator: TK_OC_SL { $$ = create_node($1); }
        | TK_OC_SR { $$ = create_node($1); }

/* === Expression === */

expression: unary_expression { $$ = $1; }
        | expression_term { $$ = $1; }
        | binary_expression { $$ = $1; }
        | ternary_expression { $$ = $1; }

expression_term: expression_literal { $$ = $1; }
        | identifier_access { $$ = $1; }
        | function_call { $$ = $1;}
        | '(' expression ')' { $$ = $2; }

unary_expression: '+' expression { $$ = create_node($1); add_child($$, $2); }
        | '-' expression { $$ = create_node($1); add_child($$, $2); }
        | '!' expression { $$ = create_node($1); add_child($$, $2); }
        | '&' expression { $$ = create_node($1); add_child($$, $2); }
        | '*' expression { $$ = create_node($1); add_child($$, $2); }
        | '?' expression { $$ = create_node($1); add_child($$, $2); }
        | '#' expression { $$ = create_node($1); add_child($$, $2); }

binary_expression: expression '+' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '-' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '*' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '/' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '%' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '|' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '&' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '^' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '>' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression '<' expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_LE expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_GE expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_EQ expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_NE expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_AND expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }
        | expression TK_OC_OR expression { $$ = create_node($2); add_child($$, $1); add_child($$, $3); }

ternary_expression: expression_term '?' expression ':' expression { $$ = create_node_with_type(TERNARY_EXPRESSION, $2);
                                                                    add_child($$, $1);
                                                                    add_child($$, $3);
                                                                    free_lexeme($4);
                                                                    add_child($$, $5); }

expression_literal: TK_LIT_INT { $$ = create_node($1); }
        | TK_LIT_FLOAT { $$ = create_node($1); }
        | TK_LIT_TRUE { $$ = create_node($1); }
        | TK_LIT_FALSE { $$ = create_node($1); }

%%

void yyerror(char const *s) {
    fprintf(stderr,"ERROR: line %d - %s\n", yylineno, s);
}
