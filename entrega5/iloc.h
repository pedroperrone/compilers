#ifndef __iloc__
#define __iloc__

#define VAR_SIZE 4

typedef enum iloc_operator
{
    ADD,
    SUB,
    MULT,
    DIV,
    CMP_LT,
    CMP_LE,
    CMP_EQ,
    CMP_GE,
    CMP_GT,
    CMP_NE,

    CBR,
    JUMPI,

    LOADI,
    LOADAI,
    STOREAI,
    I2I,

    HALT,
    NOP
} ILOC_OPERATOR;

typedef struct iloc_operand_list
{
    char *operand;
    struct iloc_operand_list *next;
} ILOC_OPERAND_LIST;

typedef struct iloc_instruction
{
    ILOC_OPERATOR op;
    char* label;
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
ILOC_INSTRUCTION_LIST *concat_instruction_list(ILOC_INSTRUCTION_LIST *instruction_list1, ILOC_INSTRUCTION_LIST *instruction_list2);
void add_instruction(ILOC_INSTRUCTION *instruction, ILOC_INSTRUCTION_LIST *instruction_list);
ILOC_INSTRUCTION *create_instruction();
ILOC_OPERAND_LIST *create_operand_list(char *operand);
ILOC_OPERAND_LIST *add_operand(char *operand, ILOC_OPERAND_LIST *operand_list);
void print_instruction_list(ILOC_INSTRUCTION_LIST *iloc_instruction_list);
void print_instruction(ILOC_INSTRUCTION *instruction);
void print_operator(ILOC_OPERATOR op);
void print_operand_list(ILOC_OPERAND_LIST *operands);
char *itoa(int val, int base);
char *generate_register();
char *generate_label();
int new_global_var_address();
int count_instructions(ILOC_INSTRUCTION_LIST *instruction_list);
ILOC_INSTRUCTION_LIST* generate_loadi_code(char *literal, char *reg);
ILOC_INSTRUCTION_LIST* generate_binary_expression_code(ILOC_OPERATOR operation, char *source1, char *source2, char *target);
ILOC_INSTRUCTION_LIST *generate_attribution_code(char *source, char *base_register, int mem_offset);
ILOC_INSTRUCTION_LIST *generate_load_code(char *base_register, int mem_offset, char *target);
ILOC_INSTRUCTION_LIST* generate_if_code(char *condition_register, char *on_true_label, char *on_false_label);
ILOC_INSTRUCTION_LIST* generate_jumpi_code(char *label);
void print_arrow(ILOC_OPERATOR op);
void print_label(char *label);
ILOC_INSTRUCTION_LIST* generate_labeled_nop_code(char *label);
ILOC_INSTRUCTION_LIST* generate_halt_code();
ILOC_INSTRUCTION_LIST *generate_move_code(char *source, char *target);
