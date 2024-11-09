%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>

int yylex();
void yyerror(const char * s);
enum Type {Integer, Array};

struct CodeNode {
    std::string code;
    std::string name;
};


struct Symbol {
	std::string name;
	Type type;
};

struct Function {
	std::string name;
	std::vector<Symbol> declarations;
};

std::vector<Function> symbol_table;

// remember that Bison is a bottom up parser: that it parses leaf nodes first
// then parsing the parent nodes.So control flow begins at the leaf grammar nodes
// and propagates up to the parents

Function *get_function() {
	int last = symbol_table.size()-1;
	if (last < 0) {
		printf("***Error. Attempt to call get_function with an empty symbol table\n");
		printf("Create a Function object using addd_function_to_symbol_table before\n");
		printf("callinf find or add_variable_to_symbol_table");
		exit(1);
	}
	return &symbol_table[last];
}

// find a particular variable using the symbol table.
// grab the most recent function, and linear search to
// find the symbol you are lookinf for.
// you may want to extends "find" to handle diferent types of "Integer" vs "Array"
bool find(std::string &value) {
	Function *f = get_function();
	int i;
	for(i =0; i < f->declarations.size(); i++) {
		Symbol *s = &f->declarations[i];
		if (s->name == value) {
			return true;
		}
	}
	return false;
} 


// when you see a function declaration inside the grammar, add
// the function name to the symbol table
void add_function_to_symbol_table(std::string &value) {
	Function f;
	f.name = value;
	symbol_table.push_back(f);
}

// when you see a symbol declaration inside the grammar, add
// the symbol table as well some type information to the symbol table
void add_variable_to_symbol_table(std::string &value, Type t) {
	Symbol s;
	s.name = value;
	s.type = t;
	Function *f = get_function();
	f->declarations.push_back(s);
}

// a function to print out the symbol table to the screen
// largely for debugging purposes
void print_symbol_table(void) {
	printf("symbol table:\n");
	printf("--------------------\n");
	for(int i = 0; i < symbol_table.size(); ++i) {
		printf("function: %s\n", symbol_table[i].name.c_str());
		for(int j = 0; j < symbol_table[i].declarations.size(); ++j) {
			printf("   locals: %s\n", symbol_table[i].declarations[j].name.c_str());	
		}	
	}
	printf("------------------\n");
}

%}
%union {
    char *op_value;
    struct CodeNode *codenode;
}

%token FUNC
%token WHILE
%token LT
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
%type <op_value> function_header

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

function_header: FUNC IDENT {
	std::string function_name = $2;
	add_function_to_symbol_table(function_name);
	$$ = $2;	       
}


function:   function_header LPAR RPAR LCURLY statements RCURLY { 
    	struct CodeNode *node = new CodeNode;
	struct CodeNode *statements = $5;
	node->code += std::string("func ") + $1 + std::string("\n");
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
		std::string variable_name $3;
		
		if (!find(variable_name)) {
			yyerror("Undefined variable.");
		}
                struct CodeNode *node = new CodeNode;
		node->code = std::string(".> ") + variable_name + std::string("\n");
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
			std::string variable_name = $2;
					
			if (find(variable_name)) {
				yyerror("Duplicate variable.");
			}	

			add_variable_to_symbol_table(variable_name, Integer);
			struct CodeNode *node = new CodeNode;
			node->code = std::string(". ") + $2 + std::string("\n");
			$$ = node;
		}
	| WHILE variable LT variable LCURLY statements RCURLY {
		printf("WHILE variable\n");
		struct CodeNode *node = new CodeNode;
		struct CodeNode *statements = $6;
		std::string var1 = $2;
		std::string var2 = $4;
		node->code += std::string(": beginloop\n");
		//  a < 10 
		node->code += std::string(". temp\n");
		node->code += std::string("< temp, ") + var1 + std::string(", ") + var2 + std::string("\n");
		node->code += std::string("?:= loopbody , temp\n");
		node->code += std::string(":= endloop\n");
		node->code += std::string(": loopbody\n");
		node->code += statements->code;
		node->code += std::string(":= beginloop\n");
		node->code += std::string(": endloop\n");
		$$ = node;

	}

variable:   IDENT   { $$ = $1; }
            | NUMBER   { $$ = $1; }
%%

int main() {
    yyparse();
    print_symbol_table();
    return 0;
}

void yyerror(const char* s) {
    printf("Error %s\n", s);
}
