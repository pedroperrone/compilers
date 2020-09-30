%{
#include "parser.tab.h"
#include "lexeme.h"

void create_special_char_lexeme();
void create_operator_lexeme();
void create_identifier_lexeme();
void init_non_operator_lexeme(LEXEME_TYPE type);
void create_literal_lexeme(LITERAL_TYPE type);
void init_lexeme();
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

"false" {
  create_operator_lexeme(BOOL);
  return TK_LIT_FALSE;
}
"true" {
  create_operator_lexeme(BOOL);
  return TK_LIT_TRUE;
}

"<=" {
  create_operator_lexeme();
  return TK_OC_LE;
}
">=" {
  create_operator_lexeme();
  return TK_OC_GE;
}
"==" {
  create_operator_lexeme();
  return TK_OC_EQ;
}
"!=" {
  create_operator_lexeme();
  return TK_OC_NE;
}
"&&" {
  create_operator_lexeme();
  return TK_OC_AND;
}
"||" {
  create_operator_lexeme();
  return TK_OC_OR;
}
"<<" {
  create_operator_lexeme();
  return TK_OC_SL;
}
">>" {
  create_operator_lexeme();
  return TK_OC_SR;
}

{IDENTIFIER} {
  create_identifier_lexeme();
  return TK_IDENTIFICADOR;
}

{CHAR} {
  create_literal_lexeme(CHAR);
  return TK_LIT_CHAR;
}

{STRING} {
  create_literal_lexeme(STRING);
  return TK_LIT_STRING;
}

{INTEGER} {
  create_literal_lexeme(INT);
  return TK_LIT_INT;
}

{FLOAT} {
  create_literal_lexeme(FLOAT);
  return TK_LIT_FLOAT;
}

{INVALID_SUBSEQUENT_TOKENS} { return TOKEN_ERRO; }

{SPECIAL_CHAR} {
  create_special_char_lexeme();
  return (int) yytext[0];
}

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

void create_special_char_lexeme() {
  init_non_operator_lexeme(SPECIAL_CHAR);
}

void create_operator_lexeme() {
  init_non_operator_lexeme(OPERATOR);
}

void create_identifier_lexeme() {
  init_non_operator_lexeme(IDENTIFIER);
}

void init_non_operator_lexeme(LEXEME_TYPE type) {
  init_lexeme();
  yylval.valor_lexico->type = type;
  yylval.valor_lexico->literal_type = NONE;
  yylval.valor_lexico->literal_value.string = strdup(yytext);
}

void create_literal_lexeme(LITERAL_TYPE type) {
  init_lexeme();
  yylval.valor_lexico->type = LITERAL;
  yylval.valor_lexico->literal_type = type;
  switch(type) {
  case INT:
    yylval.valor_lexico->literal_value.int_v = atoi(yytext);
    break;
  case FLOAT:
    yylval.valor_lexico->literal_value.float_v = atof(yytext);
    break;
  case CHAR:
    yylval.valor_lexico->literal_value.char_v = yytext[1];
    break;
  case STRING:
    yylval.valor_lexico->literal_value.string = strdup(yytext);
    break;
  case BOOL:
    if(strcmp(yytext, "true")) {
      yylval.valor_lexico->literal_value.bool_v = 0;
    } else {
      yylval.valor_lexico->literal_value.bool_v = 1;
    }
  }
}

void init_lexeme() {
	yylval.valor_lexico = (LEXEME*) malloc(sizeof(LEXEME));
	yylval.valor_lexico->line_number = yylineno;
}
