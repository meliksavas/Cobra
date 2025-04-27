%{
#include <stdio.h>
void yyerror (char* s);
int yylex();
int yylineno();
#include <string.h>
char* strings[52][256];
#include <stdio.h>     
#include <stdlib.h>
#include <ctype.h>
int symbols[52];
int symbolVal(char symbol);
void updateSymbolVal(char symbol, int val);
int i = 0;
%}

%union {int num; char id; char* str;}        /* Yacc */
%start program
%token DISPLAY 
%token EXIT
%token EQUALS ADD SUB DIVIDE MULTIPLY
%token COLON SEMICOLON OPNPARENTHESIS CLSPARENTHESIS OPNCURLYBRACKES CLSCURLYBRACKES
%token IF ELSE
%token FLOOP WLOOP
%token COMMENT
%token LOWER GREATER EQUALTO NOTEQUALTO LOWEREQUALTO GREATEREQUALTO
%token INPUT
%token RUN_PROG
%token FINISH_PROG
%token <num> INTEGER
%token <id> IDENTIFIER
%token <str> STRING 
%token TRUE FALSE OR

    
%type <num> program expr term factor whileStmt
%type <num> if_else conditions function io

%%

program    	
            : RUN_PROG SEMICOLON                   { printf("RUN_PROG\n"); }
            | program RUN_PROG SEMICOLON           { printf("RUN_PROG \n"); }
            | program FINISH_PROG SEMICOLON        { printf("FINISH_PROG \n"); exit(EXIT_SUCCESS); }
            | assignment SEMICOLON					{;}
			| assignment error						{ yyerror("Missing semicolon after assignment"); } /* Custom exception */
			| program assignment error  			{ yyerror("Missing semicolon after assignment"); } /* Custom exception */
			| EXIT SEMICOLON						{exit(EXIT_SUCCESS);}
			| EXIT error							{ yyerror("Missing semicolon after exit\n");} /* Custom exception */
			| DISPLAY expr SEMICOLON				{printf("%d\n", $2);}
			| DISPLAY STRING SEMICOLON				{printf("%s\n", $2);}
			| DISPLAY function SEMICOLON			{printf("%d\n", $2);}
			| program assignment SEMICOLON			{;}
			| program DISPLAY expr SEMICOLON		{printf("%d\n", $3);}
			| program DISPLAY STRING SEMICOLON  	{printf("%s\n", $3);}
			| program DISPLAY function SEMICOLON	{printf("%d\n", $3);}
			| program EXIT SEMICOLON				{exit(EXIT_SUCCESS);}
			| program EXIT error					{ yyerror("Missing semicolon after exit"); } /* Custom exception */
        	| if_else 				{;}
        	| program if_else 		{;}
			| conditions 			{;}
			| program conditions 	{;}
        	| comment_line   		{;}  
        	| whileStmt 			{;}
        	| program whileStmt		{;}
        	| function 				{;}
        	| program function 		{;}
        	| io 					{;}
        	| program io 			{;}
			| error  				{;} /* Handle errors here */
			| program error   		{;} /* Handle errors here */
        	;

assignment  : IDENTIFIER EQUALS expr 		{updateSymbolVal($1,$3);}
            ;

expr    : term                      {$$ = $1;}
       	| expr ADD term             {$$ = $1 + $3;}
       	| expr SUB term        		{$$ = $1 - $3;}
       	;


term    : factor                    {$$ = $1;}	
        | term MULTIPLY factor      {$$ = $1 * $3;}
        | term DIVIDE factor        {$$ = $1 / $3;}
        | IDENTIFIER                {$$ = symbolVal($1);}
        ;

factor  : INTEGER                   {$$ = $1;}
		| IDENTIFIER			    {$$ = symbolVal($1);}
        ;

if_else	: IF OPNPARENTHESIS conditions CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON CLSCURLYBRACKES 	{if($3==1){printf("%d\n", $7);}}
		| IF OPNPARENTHESIS conditions CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON CLSCURLYBRACKES ELSE OPNCURLYBRACKES DISPLAY expr SEMICOLON CLSCURLYBRACKES	{if($3==1){printf("%d\n", $7);}else{printf("%d\n", $13);}} 		
		| IF OPNPARENTHESIS conditions CLSPARENTHESIS OPNCURLYBRACKES DISPLAY STRING SEMICOLON CLSCURLYBRACKES ELSE OPNCURLYBRACKES DISPLAY STRING SEMICOLON EXIT SEMICOLON CLSCURLYBRACKES	{if($3==1){printf("%s\n", $7);}else{printf("%s\n", $13); exit(EXIT_SUCCESS);}}
		;

conditions	: expr LOWER expr			{ $$ = $1 < $3 ;}
			| expr EQUALTO expr			{ $$ = $1 == $3;}
			| expr GREATER expr			{ $$ = $1 > $3; }
			| expr LOWEREQUALTO expr	{ $$ = $1 <= $3;}
			| expr GREATEREQUALTO expr	{ $$ = $1 >= $3;}
			| expr NOTEQUALTO expr		{ $$ = $1 != $3;}
			;
whileStmt   : WLOOP OPNPARENTHESIS expr GREATER expr CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON expr EQUALS expr SUB term SEMICOLON CLSCURLYBRACKES 			{while($3>$5){printf("%d\n", $9); $11=$13-$15; $13=$11; $3=$11; $9=$11;}}
			| WLOOP OPNPARENTHESIS expr GREATER expr CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON expr EQUALS expr ADD term SEMICOLON CLSCURLYBRACKES 			{while($3>$5){printf("%d\n", $9); $11=$13+$15; $13=$11; $3=$11; $9=$11;}}
			| WLOOP OPNPARENTHESIS expr GREATER expr CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON expr EQUALS term DIVIDE factor SEMICOLON CLSCURLYBRACKES 	{while($3>$5){printf("%d\n", $9); $11=$13/$15; $13=$11; $3=$11; $9=$11;}}
			| WLOOP OPNPARENTHESIS expr GREATER expr CLSPARENTHESIS OPNCURLYBRACKES DISPLAY expr SEMICOLON expr EQUALS term MULTIPLY factor SEMICOLON CLSCURLYBRACKES 	{while($3>$5){printf("%d\n", $9); $11=$13*$15; $13=$11; $3=$11; $9=$11;}}
			;


function	: IDENTIFIER OPNPARENTHESIS expr CLSPARENTHESIS OPNCURLYBRACKES IDENTIFIER EQUALS expr SEMICOLON CLSCURLYBRACKES 	{;}
			| IDENTIFIER OPNPARENTHESIS expr CLSPARENTHESIS 	{$$ = $3*$3;}
			;
io			: IDENTIFIER EQUALS INPUT SEMICOLON		{int i; printf("enter value: "); scanf("%d\n", &i); updateSymbolVal($1,i);}
			; 


comment_line :	COMMENT  { /*Write comment*/ } 
			 ;

%%                    

int computeSymbolIndex(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
}

/* returns the value of a given symbol */
int symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket]; 
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}

	return yyparse ( );
}

void yyerror (char *s) {fprintf(stderr, "%s\n", s);} 
