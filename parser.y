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
%token INT_KEYWORD
%token PLUS
%token EQUAL
%token <op_value> IDENT
%token <op_value> NUMBER
%token LPAR
%token RPAR
%token LCURLY
%token RCURLY
%start program

%type <codenode> functions
%type <codenode> function 
%type <codenode> statement
%type <codenode> statements
%type <op_value> variable

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
	struct CodeNode *statements = $6;
	node->code += std::string("func ") + $2 + std::string("\n");
	node->code += statements->code;
	node->code += std::string("endfunc\n");
	$$ = node;
}
statements:    statement statements {  
    	struct CodeNode *statement = $1;
    	struct CodeNode *statements =  $2;
    	struct CodeNode *node= new CodeNode;
    	node->code = statement->code + statements->code;
	$$ = node;
	}
        | %empty {  
                struct CodeNode *node = new CodeNode;
                $$ = node;
            }       

statement: PRINT LPAR variable RPAR SEMICOLON {
	
                struct CodeNode *node = new CodeNode;
		node->code = std::string(".> ") + std::string($3) + std::string("\n");
                $$ = node;      
   	 }
	 | IDENT EQUAL variable PLUS variable SEMICOLON {

                struct CodeNode *node = new CodeNode;
                node->code = std::string("+ ") + std::string($1) + std::string(", ") + std::string($3) + std::string(", ") + std::string($5) + std::string("\n") ;
		$$ = node;
            }      
	 | IDENT EQUAL variable SEMICOLON {
	
                struct CodeNode *node = new CodeNode;
                node->code = std::string("= ") + std::string($1) + std::string(", ") + std::string($3) + std::string("\n") ;
                $$ = node;
            }       
	 | INT_KEYWORD IDENT SEMICOLON {
			struct CodeNode *node = new CodeNode;
			node->code = std::string(". ") + $2 + std::string("\n");
			$$ = node;
		}

variable:   IDENT   { $$ = $1; }
            | NUMBER   { $$ = $1; }
%%

int main() {
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}
