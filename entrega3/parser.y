%{
#include <stdio.h>
#include "lexeme.h"
#include "tree.h"
int yylex(void);
void yyerror (char const *s);
extern int yylineno;
%}

%verbose
%define parse.error verbose
// TODO: use typedef definition
%union {
	struct lexeme* valor_lexico;
	struct node* node;
}

%token<lexeme> TK_PR_INT
%token<lexeme> TK_PR_FLOAT
%token<lexeme> TK_PR_BOOL
%token<lexeme> TK_PR_CHAR
%token<lexeme> TK_PR_STRING
%token<lexeme> TK_PR_IF
%token<lexeme> TK_PR_THEN
%token<lexeme> TK_PR_ELSE
%token<lexeme> TK_PR_WHILE
%token<lexeme> TK_PR_DO
%token<lexeme> TK_PR_INPUT
%token<lexeme> TK_PR_OUTPUT
%token<lexeme> TK_PR_RETURN
%token<lexeme> TK_PR_CONST
%token<lexeme> TK_PR_STATIC
%token<lexeme> TK_PR_FOREACH
%token<lexeme> TK_PR_FOR
%token<lexeme> TK_PR_SWITCH
%token<lexeme> TK_PR_CASE
%token<lexeme> TK_PR_BREAK
%token<lexeme> TK_PR_CONTINUE
%token<lexeme> TK_PR_CLASS
%token<lexeme> TK_PR_PRIVATE
%token<lexeme> TK_PR_PUBLIC
%token<lexeme> TK_PR_PROTECTED
%token<lexeme> TK_PR_END
%token<lexeme> TK_PR_DEFAULT
%token<lexeme> TK_OC_LE
%token<lexeme> TK_OC_GE
%token<lexeme> TK_OC_EQ
%token<lexeme> TK_OC_NE
%token<lexeme> TK_OC_AND
%token<lexeme> TK_OC_OR
%token<lexeme> TK_OC_SL
%token<lexeme> TK_OC_SR
%token<lexeme> TK_OC_FORWARD_PIPE
%token<lexeme> TK_OC_BASH_PIPE
%token<lexeme> TK_LIT_INT
%token<lexeme> TK_LIT_FLOAT
%token<lexeme> TK_LIT_FALSE
%token<lexeme> TK_LIT_TRUE
%token<lexeme> TK_LIT_CHAR
%token<lexeme> TK_LIT_STRING
%token<lexeme> TK_IDENTIFICADOR
%token<lexeme> TOKEN_ERRO

%type<node>programa
%type<node>start
%type<node>optional_static
%type<node>optional_const
%type<node>type
%type<node>literal
%type<node>global_variable
%type<node>optional_vector_definition_brackets
%type<node>optional_vector_access_brackets
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
%type<node>optional_attribution
%type<node>variable_attribution
%type<node>control_flow
%type<node>if
%type<node>optional_else
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
%type<node>unary_operator
%type<node>binary_expression
%type<node>ternary_expression
%type<node>binary_operator
%type<node>expression_literal

%start programa

%locations

%%

programa: start

start: global_variable start {}
        | function start {}
        | %empty{}


optional_static: TK_PR_STATIC {}
        | %empty {}

optional_const: TK_PR_CONST {}
        | %empty {}

type: TK_PR_INT {}
        | TK_PR_FLOAT  {}
        | TK_PR_BOOL {}
        | TK_PR_CHAR {}
        | TK_PR_STRING {}

literal: TK_LIT_INT {}
        | TK_LIT_FLOAT {}
        | TK_LIT_TRUE {}
        | TK_LIT_FALSE {}
        | TK_LIT_CHAR {}
        | TK_LIT_STRING {}


/* === Global Variable === */

global_variable: optional_static type global_identifier_list ';' {}

optional_vector_definition_brackets: '[' TK_LIT_INT ']' {}
        | %empty {}

optional_vector_access_brackets: '[' expression ']' {}
        | %empty {}

identifier_access: TK_IDENTIFICADOR optional_vector_access_brackets {}

global_identifier_list: TK_IDENTIFICADOR optional_vector_definition_brackets {}
        | TK_IDENTIFICADOR optional_vector_definition_brackets ',' global_identifier_list {}


/* === Function === */

function: function_header function_body {}

function_header: optional_static type TK_IDENTIFICADOR '(' parameter_list ')' {}

parameter_list: optional_const type TK_IDENTIFICADOR parameter_list_tail {}
        | %empty {}
parameter_list_tail: ',' optional_const type TK_IDENTIFICADOR parameter_list_tail {}
        | %empty {}

function_body: command_block {}
command_block: '{' command_list '}' {}
command_list: command ';' command_list {}
        | %empty {}


/* === Command === */

command: variable_declaration {}
        | variable_attribution {}
        | control_flow {}
        | io_operation {}
        | return_operation {}
        | command_block {}
        | function_call {}
        | shift_operation {}

variable_declaration: optional_static optional_const type local_identifier_list {}
local_identifier_list: TK_IDENTIFICADOR optional_attribution {}
        | TK_IDENTIFICADOR optional_attribution ',' local_identifier_list{}
optional_attribution: TK_OC_LE TK_IDENTIFICADOR {}
        | TK_OC_LE literal {}
        | %empty {}

variable_attribution: identifier_access '=' expression {}

control_flow: if {}
        | for {}
        | while {}

if: TK_PR_IF '(' expression ')' command_block optional_else {}
optional_else: TK_PR_ELSE command_block {}
        | %empty {}
for: TK_PR_FOR '(' variable_attribution ':' expression ':' variable_attribution ')' command_block {}
while: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block {}

io_operation: input {}
        | output {}
input: TK_PR_INPUT TK_IDENTIFICADOR {}
output: TK_PR_OUTPUT TK_IDENTIFICADOR {}
        | TK_PR_OUTPUT literal {}

return_operation: return {}
        | break {}
        | continue {}
return: TK_PR_RETURN expression {}
break: TK_PR_BREAK {}
continue: TK_PR_CONTINUE {}

function_call: TK_IDENTIFICADOR '(' argument_list ')' {}
argument_list: argument argument_list_tail {}
        | %empty {}
argument_list_tail: ',' argument argument_list_tail {}
        | %empty {}
argument: expression {}

shift_operation: identifier_access shift_operator TK_LIT_INT {}
shift_operator: TK_OC_SL {}
        | TK_OC_SR {}

/* === Expression === */

expression: unary_expression {}
        | expression_term {}
        | binary_expression {}
        | ternary_expression {}

expression_term: expression_literal {}
        | identifier_access {}
        | function_call {}
        | '(' expression ')' {}

unary_expression: unary_operator expression {}

unary_operator: '+' {}
        | '-' {}
        | '!' {}
        | '&' {}
        | '*' {}
        | '?' {}
        | '#' {}

binary_expression: expression_term binary_operator expression {}

ternary_expression: expression_term '?' expression ':' expression {}

binary_operator: '+' {}
        | '-' {}
        | '/' {}
        | '%' {}
        | '|' {}
        | '&' {}
        | '^' {}
        | TK_OC_LE {}
        | TK_OC_GE {}
        | TK_OC_EQ {}
        | TK_OC_NE {}
        | TK_OC_AND {}
        | TK_OC_OR {}

expression_literal: TK_LIT_INT {}
        | TK_LIT_FLOAT {}
        | TK_LIT_TRUE {}
        | TK_LIT_FALSE {}

%%

void yyerror(char const *s) {
    fprintf(stderr,"ERROR: line %d - %s\n", yylineno, s);
}
