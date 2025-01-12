#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct Symbol {
    char *name;
    char *type;
    struct Symbol *next;
} Symbol;

Symbol *symbol_table = NULL;

void add_symbol(const char *name, const char *type) {
    Symbol *symbol = malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->type = strdup(type);
    symbol->next = symbol_table;
    symbol_table = symbol;
}

const char *get_symbol_type(const char *name) {
    Symbol *current = symbol_table;
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current->type;
        }
        current = current->next;
    }
    return NULL;
}

void print_symbol_table() {
    printf("Symbol Table:\n");
    Symbol *current = symbol_table;
    while (current) {
        printf("Name: %s, Type: %s\n", current->name, current->type);
        current = current->next;
    }
}

#endif
