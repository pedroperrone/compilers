#include "iloc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int current_register = 1;

ILOC_INSTRUCTION_LIST *create_instruction_list(ILOC_INSTRUCTION *instruction) {
    ILOC_INSTRUCTION_LIST *instruction_list = malloc(sizeof(ILOC_INSTRUCTION_LIST));
    instruction_list->instruction = instruction;
    instruction_list->next = NULL;

    return instruction_list;
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
    print_operator(instruction->op);
    print_operand_list(instruction->source_operand_list);
    printf(" =>");
    print_operand_list(instruction->target_operand_list);
    printf("\n");
}

void print_operator(ILOC_OPERATOR op) {
    switch(op) {
        case ADD: 
            printf("add");
            break;
        case MULT: 
            printf("mult");
            break;
        default:
            printf("DEU RUIM");
    }
}

void print_operand_list(ILOC_OPERAND_LIST *operands) {
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
    return &buf[i + 1];
}

char* generate_register() {
    char *number_as_string = itoa(current_register, 10);
    current_register++;
    char register_name[11] = "r";
    strcat(register_name, number_as_string);
    return strdup(register_name);
}
