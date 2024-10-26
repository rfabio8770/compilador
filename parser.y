%{
#include <stdio.h>
int yylex();
void yyerror(const char * s);
%}
%union {
    char *op_value;
}

%token FUNC
%token PRINT
%token SEMICOLON
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

function:   FUNC IDENT LPAR RPAR LCURLY statements RCURLY { printf("program -> FUNC IDENT %s LPAR RPAR LCURLY statements RCURLY\n",$2);}

statements:    statement statements { printf("statements -> statement statements\n"); }
                | %empty {printf("statement -> empty\n"); }

statement: PRINT LPAR variable RPAR SEMICOLON { printf("statement -> PRINT LPAR variable RPAR SEMICOLON\n");}

variable:   IDENT   { printf("variable -> IDENT %s\n", $1); }
            | NUMERIC   { printf("variable -> NUMERIC %s\n", $1); }
%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}