%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
void yyerror (char *s);
int yylex();


%}
%%
":" return COLON;
";" return SEMICOLON;
"=" return EQUALS;
"(" return OPNPARENTHESIS;
")" return CLSPARENTHESIS;
[-]?[0-9]+ {yylval.num = atoi(yytext); return INTEGER;}
"+" return ADD;
"-" return SUB;
"/" return DIVIDE;
"*" return MULTIPLY;
"for" return FLOOP;
"while" return WLOOP;
"display" return DISPLAY;
"if" return IF;
"else" return ELSE;
"//".* /*COMMENT*/;
"exit" return EXIT;
"{" return OPNCURLYBRACKES;
"}" return CLSCURLYBRACKES;
"<" return LOWER;
">" return GREATER;
"==" return EQUALTO;
"!=" return NOTEQUALTO;
"<=" return LOWEREQUALTO;
">=" return GREATEREQUALTO;
"input" return INPUT;
"true" return TRUE;
"false" return FALSE;
"|" return OR;
"RUN" return RUN_PROG;
"FINISH" return FINISH_PROG;
\"[^\"]*\" {yylval.str = strdup(yytext); return STRING;};
[a-zA-Z][_a-zA-Z0-9]* {yylval.id = yytext[0]; return IDENTIFIER;};
[ \t\n] ;
. {printf("Error!Undefined Token");}
%%

int yywrap(void){
    return 1;
}