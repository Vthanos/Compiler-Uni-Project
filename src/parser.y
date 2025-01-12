%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lexer.h"
#include "symbol_table.h"


void yyerror(const char *s);
int yylex();

// Intermediate code storage
#define MAX_CODE_SIZE 1000
char *code[MAX_CODE_SIZE];
int code_index = 0;

void emit(const char *instruction);
void print_code();
%}

%union {
    int num;
    char *id;
}

%token <num> NUM
%token <id> ID
%token IF ELSE FOR WHILE SWITCH CASE BREAK DEFAULT
%token EQ NE LT LE GT GE PLUS MINUS MUL DIV MOD AND OR NOT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COLON

%start program

%%

program:
    statements { print_code(); }
    ;

statements:
    statement
    | statements statement
    ;

statement:
      assignment
    | conditional
    | loop
    | switch_stmt
    ;

assignment:
    ID EQ expression SEMICOLON {
        if (get_symbol_type($1) == NULL) {
            fprintf(stderr, "Semantic error: Undeclared variable '%s'\n", $1);
            exit(1);
        }
        emit("STORE");
    }
    ;


expression:
      NUM {
        char buf[100];
        sprintf(buf, "PUSH %d", $1);
        emit(buf);
    }
    | ID {
        char buf[100];
        sprintf(buf, "LOAD %s", $1);
        emit(buf);
    }
    | expression PLUS expression {
        emit("ADD");
    }
    | expression MINUS expression {
        emit("SUB");
    }
    | expression MUL expression {
        emit("MUL");
    }
    | expression DIV expression {
        emit("DIV");
    }
    | expression MOD expression {
        emit("MOD");
    }
    | LPAREN expression RPAREN { /* Pass-through */ }
    ;

    declaration:
        type ID SEMICOLON {
            if (get_symbol_type($2)) {
                fprintf(stderr, "Semantic error: Redeclaration of variable '%s'\n", $2);
                exit(1);
            }
            add_symbol($2, $1);
        }
        ;

    type:
        "int" { $$ = "int"; }
        | "char" { $$ = "char"; }
        ;


conditional:
    IF LPAREN expression RPAREN statement {
        emit("IF-GOTO END_IF");
        emit("END_IF:");
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        emit("IF-GOTO ELSE_BLOCK");
        emit("GOTO END_IF");
        emit("ELSE_BLOCK:");
        emit("END_IF:");
    }
    ;

loop:
    FOR LPAREN assignment expression SEMICOLON assignment RPAREN statement {
        emit("FOR-LOOP-BEGIN");
        emit("FOR-LOOP-END");
    }
    | WHILE LPAREN expression RPAREN statement {
        emit("WHILE-BEGIN");
        emit("WHILE-END");
    }
    ;

switch_stmt:
    SWITCH LPAREN expression RPAREN LBRACE cases RBRACE {
        emit("SWITCH-END");
    }
    ;

cases:
    CASE NUM COLON statements BREAK SEMICOLON {
        emit("CASE-END");
    }
    | cases CASE NUM COLON statements BREAK SEMICOLON {
        emit("CASE-END");
    }
    | DEFAULT COLON statements {
        emit("DEFAULT-END");
    }
    ;
%%

void emit(const char *instruction) {
    if (code_index < MAX_CODE_SIZE) {
        code[code_index++] = strdup(instruction);
    } else {
        fprintf(stderr, "Code storage exceeded\n");
        exit(1);
    }
}

void print_code() {
    printf("Generated Code:\n");
    for (int i = 0; i < code_index; ++i) {
        printf("%s\n", code[i]);
        free(code[i]);
    }
    code_index = 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d, column %d: %s\n", line_number, column_number, s);
}
