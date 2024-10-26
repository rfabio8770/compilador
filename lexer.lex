%{

#include <stdio.h>
#include "parser.tab.h"

char* create_string(char *value, int length) {
    char *return_value = new char[length + 1];
    strcpy(return_value, value);
    return return_value;
}

%}

%%
"func"  { return FUNC; }
"("     { return LPAR; }
")"     { return RPAR; }
"{"     { return LCURLY; }
"}"     { return RCURLY; }
[0-9]+  { yylval.op_value = create_string(yytext, yyleng); return NUMERIC; }
[a-z]+  { yylval.op_value = create_string(yytext, yyleng); return IDENT; }
[ \t\n] {}

%%

/* int main() 
{
    yylex();
    return 0;
}  */

int yywrap()
{
    return 1;
}