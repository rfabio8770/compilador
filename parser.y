%{
#include <stdio.h>
#include <iostream>

int yylex();
void yyerror(const char * s);

struct CodeNode {
    std::string code;
    std::string name;
};

%}
%union {
    char *op_value;
    struct CodeNode *codenode;
}

%token FUNC
%token PRINT
%token SEMICOLON
%token <op_value> IDENT
%token <op_value> NUMBER
%token LPAR
%token RPAR
%token LCURLY
%token RCURLY
%start program

%type <codenode> functions
%type <codenode> function 

%%
program:    functions   {  
    struct CodeNode *node = $1;
    printf("%s\n", node->code.c_str());
}

functions:  function functions { 
    struct CodeNode *function = $1;
    struct CodeNode *functions $2;
    struct CodeNode *node= new CodeNode;
    node->code = function->code + functions->code;
    $$ = node;
    
}
            | %empty {
                struct CodeNode *node = new CodeNode;
                    $$ = node;
            }       

function:   FUNC IDENT LPAR RPAR LCURLY statements RCURLY { 
struct CodeNode *node = new CodeNode;
node->code += std::string("func ") + $2 + std::string("\n");
node->code += std::string("endfunc\n");
$$ = node;
}
statements:    statement statements {  }
                | %empty {  }

statement: PRINT LPAR variable RPAR SEMICOLON { }

variable:   IDENT   { }
            | NUMBER   {  }
%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}