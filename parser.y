%{
#include <stdio.h>
int yylex();
void yyerror(const char * s);
%}
%union {
    char *op_value;
}

%token FUNC
%token <op_value> IDENT
%token <op_value> NUMERIC
%token LPAR
%token RPAR
%token LCURLY
%token RCURLY
%start program

%%
program:    functions   { printf("program -> functions\n"); }

functions:  function functions { printf("functions -> function functions\n");}
            | %empty { printf("functions -> empty\n");}       

function:   FUNC IDENT LPAR RPAR LCURLY RCURLY { printf("program -> FUNC IDENT %s LPAR RPAR LCURLY RCURLY\n",$2);}
%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}