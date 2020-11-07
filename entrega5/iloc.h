#ifndef __iloc__
#define __iloc__

typedef enum iloc_operator
{
    ADD,
    MULT
} ILOC_OPERATOR;

typedef struct iloc_operand_list
{
    char *operand;
    struct iloc_operand_list *next;
} ILOC_OPERAND_LIST;

typedef struct iloc_instruction
{
    ILOC_OPERATOR op;
    struct iloc_operand_list *source_operand_list;
    struct iloc_operand_list *target_operand_list;
} ILOC_INSTRUCTION;

typedef struct iloc_instruction_list
{
    struct iloc_instruction *instruction;
    struct iloc_instruction_list *next;
} ILOC_INSTRUCTION_LIST;

#endif

ILOC_INSTRUCTION_LIST *create_instruction_list(ILOC_INSTRUCTION *instruction);
void add_instruction(ILOC_INSTRUCTION *instruction, ILOC_INSTRUCTION_LIST *instruction_list);
ILOC_INSTRUCTION *create_instruction();
ILOC_OPERAND_LIST *create_operand_list(char *operand);
ILOC_OPERAND_LIST *add_operand(char *operand, ILOC_OPERAND_LIST *operand_list);
void print_instruction_list(ILOC_INSTRUCTION_LIST *iloc_instruction_list);
void print_instruction(ILOC_INSTRUCTION *instruction);
void print_operator(ILOC_OPERATOR op);
void print_operand_list(ILOC_OPERAND_LIST *operands);
char *generate_register();
