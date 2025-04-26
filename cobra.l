%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"

void yyerror(char *s);
%}

%option yylineno

%%

"RUN"                   { printf("Lexer: RUN\n"); return RUN; }
"FINISH"                { printf("Lexer: FINISH\n"); return FINISH; }

"var"                   { printf("Lexer: VAR\n"); return VAR; }
"const"                 { printf("Lexer: CONST\n"); return CONST; }

"int"                   { printf("Lexer: INT_TYPE\n"); return INT_TYPE; }
"float"                 { printf("Lexer: FLOAT_TYPE\n"); return FLOAT_TYPE; }
"text"                  { printf("Lexer: STRING_TYPE\n"); return STRING_TYPE; }
"boolean"               { printf("Lexer: BOOL_TYPE\n"); return BOOL_TYPE; }
"char"                  { printf("Lexer: CHAR_TYPE\n"); return CHAR_TYPE; }
"void"                  { printf("Lexer: VOID_TYPE\n"); return VOID_TYPE; }

"function"              { printf("Lexer: FUNCTION\n"); return FUNCTION; }
"return"                { printf("Lexer: RETURN\n"); return RETURN; }

"if"                    { printf("Lexer: IF\n"); return IF; }
"then"                  { printf("Lexer: THEN\n"); return THEN; }
"elif"                  { printf("Lexer: ELIF\n"); return ELIF; }
"else"                  { printf("Lexer: ELSE\n"); return ELSE; }

"while"                 { printf("Lexer: WHILE\n"); return WHILE; }
"for"                   { printf("Lexer: FOR\n"); return FOR; }
"do"                    { printf("Lexer: DO\n"); return DO; }

"print"                 { printf("Lexer: PRINT\n"); return PRINT; }
"input"                 { printf("Lexer: INPUT\n"); return INPUT; }

"try"                   { printf("Lexer: TRY\n"); return TRY; }
"catch"                 { printf("Lexer: CATCH\n"); return CATCH; }
"throw"                 { printf("Lexer: THROW\n"); return THROW; }

"<<"                    { printf("Lexer: OPNCURLYBRACKES\n"); return OPNCURLYBRACKES; }
">>"                    { printf("Lexer: CLSCURLYBRACKES\n"); return CLSCURLYBRACKES; }

"=="                    { printf("Lexer: EQUALTO\n"); return EQUALTO; }
"!="                    { printf("Lexer: NOTEQUALTO\n"); return NOTEQUALTO; }
"<"                     { printf("Lexer: LOWERTHAN\n"); return LOWERTHAN; }
">"                     { printf("Lexer: GREATERTHAN\n"); return GREATERTHAN; }
"<="                    { printf("Lexer: LOWEREQUALTO\n"); return LOWEREQUALTO; }
">="                    { printf("Lexer: GREATEREQUALTO\n"); return GREATEREQUALTO; }

"&&"                    { printf("Lexer: AND_OP\n"); return AND_OP; }
"||"                    { printf("Lexer: OR_OP\n"); return OR_OP; }
"!"                     { printf("Lexer: NOT_OP\n"); return NOT_OP; }

"true"                  { printf("Lexer: BOOL_TRUE\n"); yylval.b_val = true; return BOOL_TRUE; }
"false"                 { printf("Lexer: BOOL_FALSE\n"); yylval.b_val = false; return BOOL_FALSE; }

"//".*                  { /* Skip comments */ }

[0-9]+                  { printf("Lexer: INTEGER (%s)\n", yytext); yylval.i_val = atoi(yytext); return INTEGER; }
[0-9]+\.[0-9]+          { printf("Lexer: FLOAT (%s)\n", yytext); yylval.f_val = atof(yytext); return FLOAT; }
\"[^\"]*\"              { printf("Lexer: STRING (%s)\n", yytext); yylval.s_val = strdup(yytext); return STRING; }
\'[a-zA-Z0-9]\'         { printf("Lexer: CHAR_LITERAL (%s)\n", yytext); yylval.c_val = yytext[1]; return CHAR_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]*  { printf("Lexer: VARIABLE (%s)\n", yytext); yylval.s_val = strdup(yytext); return VARIABLE; }

[ \t\n]                 { /* Ignore whitespace */ }
[-+*/():;,={}]          { printf("Lexer: '%c'\n", yytext[0]); return yytext[0]; }

.                       { printf("Lexer: Unexpected character: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
} 