%{

#include <stdio.h>
#include "parser.tab.h"

%}

%%
"func"  { return FUNC; }
"("     { return LPAR; }
")"     { return RPAR; }
"{"     { return LCURLY; }
"}"     { return RCURLY; }
[0-9]+  { return NUMERIC; }
[a-z]+  { return IDENT; }
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