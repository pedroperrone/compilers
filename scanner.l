%{
#include "tokens.h"
#include <stdio.h>
// TODO: ignore inline comments
// TODO: ignore multiline comments
// TODO: raise lexical errors
// TODO: literals
// TODO: ignore blank chars

// QUESTIONS: is ">>" TK_OC_SL and "<<" TK_OC_SR?
//    Is ____ a valid identifier?
%}

SPECIAL_CHAR [,;:()\[\]{}+-|?@*/<>=!&%#^.$~`]

LETTER_OR_UNDERSCORE [a-zA-Z_]
NUMBER [0-9]
IDENTIFIER {LETTER_OR_UNDERSCORE}({LETTER_OR_UNDERSCORE}|{NUMBER})*

%%

"int" { return TK_PR_INT; }
"float" { return TK_PR_FLOAT; }
"bool" { return TK_PR_BOOL; }
"char" { return TK_PR_CHAR; }
"string" { return TK_PR_STRING; }
"if" { return TK_PR_IF; }
"then" { return TK_PR_THEN; }
"else" { return TK_PR_ELSE; }
"while" { return TK_PR_WHILE; }
"do" { return TK_PR_DO; }
"input" { return TK_PR_INPUT; }
"output" { return TK_PR_OUTPUT; }
"return" { return TK_PR_RETURN; }
"const" { return TK_PR_CONST; }
"static" { return TK_PR_STATIC; }
"foreach" { return TK_PR_FOREACH; }
"for" { return TK_PR_FOR; }
"switch" { return TK_PR_SWITCH; }
"case" { return TK_PR_CASE; }
"break" { return TK_PR_BREAK; }
"continue" { return TK_PR_CONTINUE; }
"class" { return TK_PR_CLASS; }
"private" { return TK_PR_PRIVATE; }
"public" { return TK_PR_PUBLIC; }
"protected" { return TK_PR_PROTECTED; }
"end" { return TK_PR_END; }
"default" { return TK_PR_DEFAULT; }

"<=" { return TK_OC_LE; }
">=" { return TK_OC_GE; }
"==" { return TK_OC_EQ; }
"!=" { return TK_OC_NE; }
"&&" { return TK_OC_AND; }
"||" { return TK_OC_OR; }
">>" { return TK_OC_SL; }
"<<" { return TK_OC_SR; }
"%>%" { return TK_OC_FORWARD_PIPE; }
"%|%" { return TK_OC_BASH_PIPE; }

{IDENTIFIER} { return TK_IDENTIFICADOR; }

{SPECIAL_CHAR} { return (int) yytext[0]; }

%%

// TODO: correct implementation of the function
int get_line_number(void) {
  return 0;
}
