%{
#include "parser.tab.h"
%}

%%
[ \t\n]+            ;       // Ignore whitespace
"if"                return IF;
"else"              return ELSE;
"for"               return FOR;
"while"             return WHILE;
"switch"            return SWITCH;
"case"              return CASE;
"break"             return BREAK;
"default"           return DEFAULT;

[0-9]+              return NUM;
[a-zA-Z_][a-zA-Z0-9_]* return ID;

"=="                return EQ;
"!="                return NE;
"<"                 return LT;
"<="                return LE;
">"                 return GT;
">="                return GE;
"+"                 return PLUS;
"-"                 return MINUS;
"*"                 return MUL;
"/"                 return DIV;
"%"                 return MOD;
"&&"                return AND;
"||"                return OR;
"!"                 return NOT;

"("                 return LPAREN;
")"                 return RPAREN;
"{"                 return LBRACE;
"}"                 return RBRACE;
";"                 return SEMICOLON;
":"                 return COLON;

.                   return yytext[0];  // Return single characters

int line_number = 1;
int column_number = 1;
%}

%%
\n               { line_number++; column_number = 1; }
.                { column_number++; return yytext[0]; }
[ \t]+           { column_number += yyleng; }
[0-9]+           { column_number += yyleng; return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { column_number += yyleng; return ID; }
%%
%%
