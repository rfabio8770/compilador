%{
#include <stdio.h>
int yylex();
void yyerror(const char * s);
%}
%token FUNC
%token IDENT
%token NUMERIC
%token LPAR
%token RPAR
%token LCURLY
%token RCURLY
%start program

%%
program:    functions   { printf("program -> functions\n"); }

functions:  function functions { printf("functions -> function functions\n");}
            | %empty { printf("functions -> empty\n");}       

function:   FUNC IDENT LPAR RPAR LCURLY RCURLY { printf("program -> FUNC IDENT LPAR RPAR LCURLY RCURLY\n");}
%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}