%{
#include "parser.tab.h"
%}
%option yylineno

SPECIAL_CHAR [,;:()\[\]{}+-|*/<>=!&%#^.$]

LETTER_OR_UNDERSCORE [a-zA-Z_]
NUMBER [0-9]
IDENTIFIER {LETTER_OR_UNDERSCORE}({LETTER_OR_UNDERSCORE}|{NUMBER})*

INTEGER {NUMBER}+

SIGNAL [+-]
SCIENTIFIC_NOTATION [eE]{SIGNAL}?{INTEGER}
FLOATING_POINT_NOTATION {INTEGER}\.{NUMBER}+
FLOAT {FLOATING_POINT_NOTATION}{SCIENTIFIC_NOTATION}?

CHAR '.'

ANY_SCAPED_CHAR \\.
NON_QUOTE_OR_NEW_LINE_CHAR [^"\n]
STRING \"({ANY_SCAPED_CHAR}|{NON_QUOTE_OR_NEW_LINE_CHAR})*\"

INVALID_SUBSEQUENT_TOKENS ({INTEGER}|{FLOAT}){IDENTIFIER}

WHITE_SPACES [\n \t]

INLINE_COMMENT "//".*

BEGIN_MULTILINE_COMMENT "/*"
END_MULTILINE_COMMENT "*/"

%x MULTILINE_COMMENT

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

"false" { return TK_LIT_FALSE; }
"true" { return TK_LIT_TRUE; }

"<=" { return TK_OC_LE; }
">=" { return TK_OC_GE; }
"==" { return TK_OC_EQ; }
"!=" { return TK_OC_NE; }
"&&" { return TK_OC_AND; }
"||" { return TK_OC_OR; }
"<<" { return TK_OC_SL; }
">>" { return TK_OC_SR; }

{IDENTIFIER} { return TK_IDENTIFICADOR; }

{CHAR} { return TK_LIT_CHAR; }

{STRING} { return TK_LIT_STRING; }

{INTEGER} { return TK_LIT_INT; }

{FLOAT} { return TK_LIT_FLOAT; }

{INVALID_SUBSEQUENT_TOKENS} { return TOKEN_ERRO; }

{SPECIAL_CHAR} { return (int) yytext[0]; }

({WHITE_SPACES}|{INLINE_COMMENT}) { }

{BEGIN_MULTILINE_COMMENT} { BEGIN(MULTILINE_COMMENT); }
<MULTILINE_COMMENT>{END_MULTILINE_COMMENT} { BEGIN(INITIAL); }
<MULTILINE_COMMENT>{WHITE_SPACES} { }
<MULTILINE_COMMENT>. { }

. { return TOKEN_ERRO; }

%%

int get_line_number(void) {
  return yylineno;
}
