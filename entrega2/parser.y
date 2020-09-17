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

/* TODO: multiple variables without coma are accepted. Missing semicolon is error in next line. */
global_variable: optional_static type identifiers_list ';'

optional_static: TK_PR_STATIC |
                 %empty

type: TK_PR_INT |
      TK_PR_FLOAT |
      TK_PR_BOOL |
      TK_PR_CHAR |
      TK_PR_STRING

identifiers_list: TK_IDENTIFICADOR identifiers_list_tail

identifiers_list_tail: ',' TK_IDENTIFICADOR identifiers_list_tail | %empty

/* TODO: implement function */
function: 'f'

%%

void yyerror(char const *s) {
    printf("ERROR: line %d - %s\n", yylineno, s);
}
