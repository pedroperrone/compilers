#include "iloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_register = 1;
int current_label = 1;
int rbss_displacement = 0;

ILOC_INSTRUCTION_LIST *create_instruction_list(ILOC_INSTRUCTION *instruction) {
    ILOC_INSTRUCTION_LIST *instruction_list = malloc(sizeof(ILOC_INSTRUCTION_LIST));
    instruction_list->instruction = instruction;
    instruction_list->next = NULL;

    return instruction_list;
}

ILOC_INSTRUCTION_LIST *concat_instruction_list(ILOC_INSTRUCTION_LIST *instruction_list1, ILOC_INSTRUCTION_LIST *instruction_list2) {
    ILOC_INSTRUCTION_LIST *aux = instruction_list1;

    if (instruction_list1 == NULL) return instruction_list2;

    while (aux->next != NULL) aux = aux->next;
    aux->next = instruction_list2;

    return instruction_list1;
}

void add_instruction(ILOC_INSTRUCTION *instruction, ILOC_INSTRUCTION_LIST *instruction_list) {
    while (instruction_list->next != NULL) instruction_list = instruction_list->next;
    instruction_list->next = create_instruction_list(instruction);
}

ILOC_INSTRUCTION *create_instruction(ILOC_OPERATOR op ,ILOC_OPERAND_LIST *source_operands, ILOC_OPERAND_LIST *target_operands) {
    ILOC_INSTRUCTION *instruction = malloc(sizeof(ILOC_INSTRUCTION));
    instruction->op = op;
    instruction->source_operand_list = source_operands;
    instruction->target_operand_list = target_operands;
    instruction->label = NULL;

    return instruction;
}

ILOC_OPERAND_LIST *create_operand_list(char *operand) {
    return add_operand(operand, NULL);
}

ILOC_OPERAND_LIST *add_operand(char *operand, ILOC_OPERAND_LIST *operand_list) {
    ILOC_OPERAND_LIST *new_operand_list = malloc(sizeof(ILOC_OPERAND_LIST));
    new_operand_list->operand = strdup(operand);

    if (operand_list == NULL) return new_operand_list;

    while (operand_list->next != NULL) operand_list = operand_list->next;

    operand_list->next = new_operand_list;

    return operand_list;
}

void print_instruction_list(ILOC_INSTRUCTION_LIST *iloc_instruction_list) {
    if (iloc_instruction_list == NULL) return;

    print_instruction(iloc_instruction_list->instruction);
    print_instruction_list(iloc_instruction_list->next);
}

void print_instruction(ILOC_INSTRUCTION *instruction) {
    print_label(instruction->label);
    print_operator(instruction->op);
    print_operand_list(instruction->source_operand_list);
    if (!(instruction->source_operand_list == NULL && instruction->target_operand_list == NULL))
        print_arrow(instruction->op);
    print_operand_list(instruction->target_operand_list);
    printf("\n");
}

void print_arrow(ILOC_OPERATOR op) {
    switch (op) {
    case CMP_LE:
    case CMP_LT:
    case CMP_EQ:
    case CMP_GE:
    case CMP_GT:
    case CMP_NE:
    case CBR:
    case JUMPI:
        printf(" ->");
        break;
    default:
        printf(" =>");
        break;
    }
}

void print_label(char* label) {
    if (label == NULL) return;

    printf("%s: ", label);
}

void print_operator(ILOC_OPERATOR op) {
    switch(op) {
        case ADD:
            printf("add");
            break;
        case SUB:
            printf("sub");
            break;
        case MULT:
            printf("mult");
            break;
        case DIV:
            printf("div");
            break;
        case CMP_LE:
            printf("cmp_LE");
            break;
        case CMP_LT:
            printf("cmp_LT");
            break;
        case CMP_EQ:
            printf("cmp_EQ");
            break;
        case CMP_GE:
            printf("cmp_GE");
            break;
        case CMP_GT:
            printf("cmp_GT");
            break;
        case CMP_NE:
            printf("cmp_NE");
            break;
        case CBR:
            printf("cbr");
            break;
        case JUMPI:
            printf("jumpI");
            break;
        case LOADI:
            printf("loadI");
            break;
        case LOADAI:
            printf("loadAI");
            break;
        case STOREAI:
            printf("storeAI");
            break;
        case NOP:
            printf("nop");
            break;
        default:
            printf("IMPLEMENTA O PRINT AE");
    }
}

void print_operand_list(ILOC_OPERAND_LIST *operands) {
    if (operands == NULL) return;
    printf(" %s", operands->operand);

    while (operands->next != NULL) {
        printf(", %s", operands->next->operand);
        operands = operands->next;
    }
}

char *itoa(int val, int base) {
    static char buf[32] = {0};
    int i = 30;
    for (; val && i; --i, val /= base)
        buf[i] = "0123456789abcdef"[val % base];
    if (buf[i + 1] == '\0') {
        return "0";
    }
    return &buf[i + 1];
}

char* generate_register() {
    char *number_as_string = itoa(current_register, 10);
    current_register++;
    char register_name[11] = "r";
    strcat(register_name, number_as_string);
    return strdup(register_name);
}

char* generate_label() {
    char *number_as_string = itoa(current_label, 10);
    current_label++;
    char label_name[11] = "L";
    strcat(label_name, number_as_string);
    return strdup(label_name);
}

int new_global_var_address() {
    int address = rbss_displacement;
    rbss_displacement += VAR_SIZE;
    return address;
}

ILOC_INSTRUCTION_LIST* generate_literal_code(char *literal, char *local) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;

    source_operands = create_operand_list(literal);

    target_operands = create_operand_list(local);

    instruction = create_instruction(LOADI, source_operands, target_operands);

    return create_instruction_list(instruction);
}

ILOC_INSTRUCTION_LIST* generate_binary_expression_code(ILOC_OPERATOR operation, char *source1, char *source2, char *target) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;

    source_operands = create_operand_list(source1);
    add_operand(source2, source_operands);

    target_operands = create_operand_list(target);

    instruction = create_instruction(operation, source_operands, target_operands);

    return create_instruction_list(instruction);
}

ILOC_INSTRUCTION_LIST* generate_attribution_code(char *source, char *base_register, int mem_offset) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;
    char* offset_string = itoa(mem_offset, 10);

    source_operands = create_operand_list(source);

    target_operands = create_operand_list(base_register);
    add_operand(offset_string, target_operands);

    instruction = create_instruction(STOREAI, source_operands, target_operands);
    return create_instruction_list(instruction);
}

ILOC_INSTRUCTION_LIST* generate_load_code(char *base_register, int mem_offset, char *target) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;
    char* offset_string = itoa(mem_offset, 10);

    source_operands = create_operand_list(base_register);
    add_operand(offset_string, source_operands);

    target_operands = create_operand_list(target);

    instruction = create_instruction(LOADAI, source_operands, target_operands);
    return create_instruction_list(instruction);
}

ILOC_INSTRUCTION_LIST* generate_if_code(char *condition_register, char *on_true_label, char *on_false_label) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;

    source_operands = create_operand_list(condition_register);

    target_operands = create_operand_list(on_true_label);
    add_operand(on_false_label, target_operands);

    instruction = create_instruction(CBR, source_operands, target_operands);
    return create_instruction_list(instruction);
}

ILOC_INSTRUCTION_LIST* generate_jumpi_code(char *label) {
    ILOC_OPERAND_LIST *source_operands, *target_operands;
    ILOC_INSTRUCTION *instruction;

    source_operands = NULL;

    target_operands = create_operand_list(label);

    instruction = create_instruction(JUMPI, source_operands, target_operands);
    return create_instruction_list(instruction);
}
