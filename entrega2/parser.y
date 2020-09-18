%{
#include <stdio.h>
int yylex(void);
void yyerror (char const *s);
extern int yylineno;
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_PR_END
%token TK_PR_DEFAULT
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

%start programa

%locations

%%

programa: start

start: global_variable start |
       function start |
       %empty


optional_static: TK_PR_STATIC | %empty
optional_const: TK_PR_CONST | %empty

type: TK_PR_INT |
      TK_PR_FLOAT |
      TK_PR_BOOL |
      TK_PR_CHAR |
      TK_PR_STRING

literal: TK_LIT_INT |
         TK_LIT_FLOAT |
         TK_LIT_TRUE |
         TK_LIT_FALSE |
         TK_LIT_CHAR |
         TK_LIT_STRING


/* === Global Variable === */

global_variable: optional_static type global_identifier_list ';'
optional_vector_definition_brackets: '[' TK_LIT_INT ']' | %empty
optional_vector_access_brackets: '[' expression ']' | %empty
global_identifier_list: TK_IDENTIFICADOR optional_vector_definition_brackets |
                        TK_IDENTIFICADOR optional_vector_definition_brackets ',' global_identifier_list


/* === Function === */

function: function_header function_body

function_header: optional_static type TK_IDENTIFICADOR '(' parameter_list ')'
parameter_list: optional_const type TK_IDENTIFICADOR parameter_list_tail | %empty
parameter_list_tail: ',' optional_const type TK_IDENTIFICADOR parameter_list_tail | %empty

function_body: command_block
command_block: '{' command_list '}'
command_list: command command_list | %empty


/* === Command === */

command: variable_declaration ';' |
         variable_attribution ';' |
         control_flow |
         io_operation ';' |
         return_operation ';' |
         command_block |
         function_call ';' |
         shift_operation ';'

variable_declaration: optional_static optional_const type local_identifier_list
local_identifier_list: TK_IDENTIFICADOR |
                       TK_IDENTIFICADOR ',' local_identifier_list

variable_attribution: TK_IDENTIFICADOR optional_vector_access_brackets '=' expression

control_flow: if | for | while
if: TK_PR_IF '(' expression ')' command_block optional_else
optional_else: TK_PR_ELSE command_block | %empty
for: TK_PR_FOR '(' variable_attribution ':' expression ':' variable_attribution ')' command_block
while: TK_PR_WHILE '(' expression ')' TK_PR_DO command_block

io_operation: input | output
input: TK_PR_INPUT TK_IDENTIFICADOR
output: TK_PR_OUTPUT TK_IDENTIFICADOR | TK_PR_OUTPUT literal

return_operation: return | break | continue
return: TK_PR_RETURN expression
break: TK_PR_BREAK
continue: TK_PR_CONTINUE

function_call: TK_IDENTIFICADOR '(' argument_list ')'
argument_list: argument argument_list_tail | %empty
argument_list_tail: ',' argument argument_list_tail | %empty
argument: literal | expression

shift_operation: TK_IDENTIFICADOR optional_vector_access_brackets shift_operator TK_LIT_INT
shift_operator: TK_OC_SL | TK_OC_SR

/* === Expression === */

expression: '*'

%%

void yyerror(char const *s) {
    printf("ERROR: line %d - %s\n", yylineno, s);
}
