#ifndef __lexeme__
#define __lexeme__

typedef enum lexeme_type
{
    SPECIAL_CHAR,
    OPERATOR,
    IDENTIFIER,
    LITERAL,
    KEYWORD
} LEXEME_TYPE;

typedef enum literal_type
{
    INT,
    FLOAT,
    CHAR,
    STRING,
    BOOL,
    NONE
} LITERAL_TYPE;

typedef union literal_value
{
    int int_v;
    float float_v;
    char char_v;
    int bool_v;
    char *string;
} LITERAL_VALUE;

typedef struct lexeme
{
    int line_number;
    LEXEME_TYPE type;
    LITERAL_TYPE literal_type;
    LITERAL_VALUE literal_value;
} LEXEME;

#endif
