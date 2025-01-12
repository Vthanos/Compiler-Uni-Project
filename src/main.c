#include <stdio.h>
#include "parser.tab.h"

extern FILE *yyin;

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    if (!yyparse()) {
        printf("Parsing completed successfully!\n");
    } else {
        printf("Parsing failed.\n");
    }

    fclose(yyin);
    return 0;
}
