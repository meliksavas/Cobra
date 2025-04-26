%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void yyerror(char *s);
int yylex();

// Symbol table structure
typedef struct {
    char* name;
    int type;  // 0: int, 1: float, 2: text, 3: boolean, 4: char, 5: void
    union {
        int i_val;
        float f_val;
        char* s_val;
        bool b_val;
        char c_val;
    } value;
    bool is_const;
} Symbol;

#define MAX_SYMBOLS 1000
Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

// Function to add a symbol to the table
int add_symbol(char* name, int type, bool is_const);
// Function to find a symbol in the table
int find_symbol(char* name);
// Function to update a symbol's value
void update_symbol_value(int index, void* value);
// Function to print a symbol's value
void print_symbol_value(int index);

// Exception handling
#define MAX_EXCEPTIONS 10
char* exception_stack[MAX_EXCEPTIONS];
int exception_count = 0;

void push_exception(char* message);
char* pop_exception();
%}

%union {
    int i_val;
    float f_val;
    char* s_val;
    bool b_val;
    char c_val;
    int symbol_index;
}

/* Tokens */
%token RUN FINISH
%token VAR CONST
%token INT_TYPE FLOAT_TYPE STRING_TYPE BOOL_TYPE CHAR_TYPE VOID_TYPE
%token FUNCTION RETURN
%token IF THEN ELIF ELSE
%token WHILE FOR DO
%token PRINT INPUT
%token OPNCURLYBRACKES CLSCURLYBRACKES
%token AND_OP OR_OP NOT_OP
%token EQUALTO NOTEQUALTO LOWERTHAN GREATERTHAN LOWEREQUALTO GREATEREQUALTO
%token <i_val> INTEGER
%token <f_val> FLOAT
%token <s_val> STRING VARIABLE
%token <b_val> BOOL_TRUE BOOL_FALSE
%token <c_val> CHAR_LITERAL
%token TRY CATCH THROW

/* Operator precedence */
%left OR_OP
%left AND_OP
%left EQUALTO NOTEQUALTO
%left LOWERTHAN GREATERTHAN LOWEREQUALTO GREATEREQUALTO
%left '+' '-'
%left '*' '/'
%right NOT_OP
%left '(' ')'

/* Non-terminal types */
%type <i_val> exp
%type <f_val> float_exp
%type <s_val> string_exp
%type <b_val> bool_exp condition
%type <c_val> char_exp
%type <symbol_index> declaration variable_declaration constant_declaration assignment

/* Start symbol */
%start program

%%

/* Grammar rules */

program : RUN statements FINISH ';' { printf("Program executed successfully\n"); }
        ;

statements : statement
           | statements statement
           | /* empty */
           ;

statement : declaration ';'
          | assignment ';'
          | conditional  
          | loop
          | io_operation ';'
          | function_declaration
          | function_call ';'
          | RETURN exp ';' { printf("Return value: %d\n", $2); }
          | RETURN float_exp ';' { printf("Return value: %f\n", $2); }
          | RETURN string_exp ';' { printf("Return value: %s\n", $2); }
          | RETURN bool_exp ';' { printf("Return value: %s\n", $2 ? "true" : "false"); }
          | RETURN char_exp ';' { printf("Return value: %c\n", $2); }
          | exception_statement
          ;

declaration : variable_declaration
            | constant_declaration
            ;

variable_declaration : VAR INT_TYPE VARIABLE '=' exp 
                     { 
                         int idx = add_symbol($3, 0, false);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | VAR FLOAT_TYPE VARIABLE '=' float_exp 
                     { 
                         int idx = add_symbol($3, 1, false);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | VAR STRING_TYPE VARIABLE '=' string_exp 
                     { 
                         int idx = add_symbol($3, 2, false);
                         update_symbol_value(idx, $5);
                         $$ = idx;
                     }
                     | VAR BOOL_TYPE VARIABLE '=' bool_exp 
                     { 
                         int idx = add_symbol($3, 3, false);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | VAR CHAR_TYPE VARIABLE '=' char_exp 
                     { 
                         int idx = add_symbol($3, 4, false);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     ;

constant_declaration : CONST INT_TYPE VARIABLE '=' exp 
                     { 
                         int idx = add_symbol($3, 0, true);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | CONST FLOAT_TYPE VARIABLE '=' float_exp 
                     { 
                         int idx = add_symbol($3, 1, true);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | CONST STRING_TYPE VARIABLE '=' string_exp 
                     { 
                         int idx = add_symbol($3, 2, true);
                         update_symbol_value(idx, $5);
                         $$ = idx;
                     }
                     | CONST BOOL_TYPE VARIABLE '=' bool_exp 
                     { 
                         int idx = add_symbol($3, 3, true);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     | CONST CHAR_TYPE VARIABLE '=' char_exp 
                     { 
                         int idx = add_symbol($3, 4, true);
                         update_symbol_value(idx, &$5);
                         $$ = idx;
                     }
                     ;

assignment : VARIABLE '=' exp 
           {
               int idx = find_symbol($1);
               if (idx != -1) {
                   if (symbol_table[idx].is_const) {
                       yyerror("Cannot modify a constant");
                   } else if (symbol_table[idx].type == 0) {
                       update_symbol_value(idx, &$3);
                   } else {
                       yyerror("Type mismatch in assignment");
                   }
               } else {
                   yyerror("Undefined variable");
               }
               $$ = idx;
           }
           | VARIABLE '=' float_exp 
           {
               int idx = find_symbol($1);
               if (idx != -1) {
                   if (symbol_table[idx].is_const) {
                       yyerror("Cannot modify a constant");
                   } else if (symbol_table[idx].type == 1) {
                       update_symbol_value(idx, &$3);
                   } else {
                       yyerror("Type mismatch in assignment");
                   }
               } else {
                   yyerror("Undefined variable");
               }
               $$ = idx;
           }
           | VARIABLE '=' string_exp 
           {
               int idx = find_symbol($1);
               if (idx != -1) {
                   if (symbol_table[idx].is_const) {
                       yyerror("Cannot modify a constant");
                   } else if (symbol_table[idx].type == 2) {
                       update_symbol_value(idx, $3);
                   } else {
                       yyerror("Type mismatch in assignment");
                   }
               } else {
                   yyerror("Undefined variable");
               }
               $$ = idx;
           }
           | VARIABLE '=' bool_exp 
           {
               int idx = find_symbol($1);
               if (idx != -1) {
                   if (symbol_table[idx].is_const) {
                       yyerror("Cannot modify a constant");
                   } else if (symbol_table[idx].type == 3) {
                       update_symbol_value(idx, &$3);
                   } else {
                       yyerror("Type mismatch in assignment");
                   }
               } else {
                   yyerror("Undefined variable");
               }
               $$ = idx;
           }
           | VARIABLE '=' char_exp 
           {
               int idx = find_symbol($1);
               if (idx != -1) {
                   if (symbol_table[idx].is_const) {
                       yyerror("Cannot modify a constant");
                   } else if (symbol_table[idx].type == 4) {
                       update_symbol_value(idx, &$3);
                   } else {
                       yyerror("Type mismatch in assignment");
                   }
               } else {
                   yyerror("Undefined variable");
               }
               $$ = idx;
           }
           ;

conditional : IF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES
            {
                if ($3) {
                    printf("Condition is true\n");
                } else {
                    printf("Condition is false\n");
                }
            }
            | IF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES 
              ELSE OPNCURLYBRACKES statements CLSCURLYBRACKES
            {
                if ($3) {
                    printf("Condition is true\n");
                } else {
                    printf("Condition is false, entering else block\n");
                }
            }
            | IF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES 
              ELIF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES
            {
                if ($3) {
                    printf("First condition is true\n");
                } else if ($11) {
                    printf("Second condition is true\n");
                } else {
                    printf("Both conditions are false\n");
                }
            }
            | IF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES 
              ELIF '(' condition ')' THEN OPNCURLYBRACKES statements CLSCURLYBRACKES
              ELSE OPNCURLYBRACKES statements CLSCURLYBRACKES
            {
                if ($3) {
                    printf("First condition is true\n");
                } else if ($11) {
                    printf("Second condition is true\n");
                } else {
                    printf("Both conditions are false, entering else block\n");
                }
            }
            ;

loop : WHILE '(' condition ')' DO OPNCURLYBRACKES statements CLSCURLYBRACKES
     {
         printf("While loop executed\n");
     }
     | FOR '(' assignment ';' condition ';' assignment ')' DO OPNCURLYBRACKES statements CLSCURLYBRACKES
     {
         printf("For loop executed\n");
     }
     ;

io_operation : PRINT '(' exp ')' { printf("Output: %d\n", $3); }
             | PRINT '(' float_exp ')' { printf("Output: %f\n", $3); }
             | PRINT '(' string_exp ')' { printf("Output: %s\n", $3); }
             | PRINT '(' bool_exp ')' { printf("Output: %s\n", $3 ? "true" : "false"); }
             | PRINT '(' char_exp ')' { printf("Output: %c\n", $3); }
             | INPUT '(' STRING ')' { printf("Input requested: %s\n", $3); }
             ;

function_declaration : FUNCTION VARIABLE '(' parameter_list ')' OPNCURLYBRACKES statements CLSCURLYBRACKES
                     {
                         printf("Function %s declared\n", $2);
                     }
                     ;

parameter_list : /* empty */
               | parameter
               | parameter_list ',' parameter
               ;

parameter : INT_TYPE VARIABLE
          | FLOAT_TYPE VARIABLE
          | STRING_TYPE VARIABLE
          | BOOL_TYPE VARIABLE
          | CHAR_TYPE VARIABLE
          ;

function_call : VARIABLE '(' argument_list ')'
              {
                  printf("Function %s called\n", $1);
              }
              ;

argument_list : /* empty */
              | exp
              | float_exp
              | string_exp
              | bool_exp
              | char_exp
              | argument_list ',' exp
              | argument_list ',' float_exp
              | argument_list ',' string_exp
              | argument_list ',' bool_exp
              | argument_list ',' char_exp
              ;

exception_statement : TRY OPNCURLYBRACKES statements CLSCURLYBRACKES CATCH OPNCURLYBRACKES statements CLSCURLYBRACKES
                    {
                        printf("Try-catch block executed\n");
                    }
                    | THROW STRING
                    {
                        push_exception($2);
                        printf("Exception thrown: %s\n", $2);
                    }
                    ;

exp : INTEGER { $$ = $1; }
    | VARIABLE 
    {
        int idx = find_symbol($1);
        if (idx != -1 && symbol_table[idx].type == 0) {
            $$ = symbol_table[idx].value.i_val;
        } else {
            yyerror("Variable not found or not an integer");
            $$ = 0;
        }
    }
    | exp '+' exp { $$ = $1 + $3; }
    | exp '-' exp { $$ = $1 - $3; }
    | exp '*' exp { $$ = $1 * $3; }
    | exp '/' exp 
    { 
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | '(' exp ')' { $$ = $2; }
    ;

float_exp : FLOAT { $$ = $1; }
          | INTEGER { $$ = (float)$1; }
          | VARIABLE 
          {
              int idx = find_symbol($1);
              if (idx != -1 && symbol_table[idx].type == 1) {
                  $$ = symbol_table[idx].value.f_val;
              } else {
                  yyerror("Variable not found or not a float");
                  $$ = 0.0;
              }
          }
          | float_exp '+' float_exp { $$ = $1 + $3; }
          | float_exp '-' float_exp { $$ = $1 - $3; }
          | float_exp '*' float_exp { $$ = $1 * $3; }
          | float_exp '/' float_exp 
          { 
              if ($3 == 0.0) {
                  yyerror("Division by zero");
                  $$ = 0.0;
              } else {
                  $$ = $1 / $3;
              }
          }
          | '(' float_exp ')' { $$ = $2; }
          ;

string_exp : STRING { $$ = $1; }
           | VARIABLE 
           {
               int idx = find_symbol($1);
               if (idx != -1 && symbol_table[idx].type == 2) {
                   $$ = symbol_table[idx].value.s_val;
               } else {
                   yyerror("Variable not found or not a string");
                   $$ = "";
               }
           }
           ;

bool_exp : BOOL_TRUE { $$ = true; }
         | BOOL_FALSE { $$ = false; }
         | VARIABLE 
         {
             int idx = find_symbol($1);
             if (idx != -1 && symbol_table[idx].type == 3) {
                 $$ = symbol_table[idx].value.b_val;
             } else {
                 yyerror("Variable not found or not a boolean");
                 $$ = false;
             }
         }
         ;

char_exp : CHAR_LITERAL { $$ = $1; }
         | VARIABLE 
         {
             int idx = find_symbol($1);
             if (idx != -1 && symbol_table[idx].type == 4) {
                 $$ = symbol_table[idx].value.c_val;
             } else {
                 yyerror("Variable not found or not a char");
                 $$ = '\0';
             }
         }
         ;

condition : bool_exp { $$ = $1; }
          | exp EQUALTO exp { $$ = $1 == $3; }
          | exp NOTEQUALTO exp { $$ = $1 != $3; }
          | exp LOWERTHAN exp { $$ = $1 < $3; }
          | exp GREATERTHAN exp { $$ = $1 > $3; }
          | exp LOWEREQUALTO exp { $$ = $1 <= $3; }
          | exp GREATEREQUALTO exp { $$ = $1 >= $3; }
          | float_exp EQUALTO float_exp { $$ = $1 == $3; }
          | float_exp NOTEQUALTO float_exp { $$ = $1 != $3; }
          | float_exp LOWERTHAN float_exp { $$ = $1 < $3; }
          | float_exp GREATERTHAN float_exp { $$ = $1 > $3; }
          | float_exp LOWEREQUALTO float_exp { $$ = $1 <= $3; }
          | float_exp GREATEREQUALTO float_exp { $$ = $1 >= $3; }
          | NOT_OP condition { $$ = !$2; }
          | condition AND_OP condition { $$ = $1 && $3; }
          | condition OR_OP condition { $$ = $1 || $3; }
          | '(' condition ')' { $$ = $2; }
          ;

%%

/* C code section */

int add_symbol(char* name, int type, bool is_const) {
    // Check if the symbol already exists
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            yyerror("Symbol already defined");
            return -1;
        }
    }
    
    // Add the new symbol
    if (symbol_count < MAX_SYMBOLS) {
        symbol_table[symbol_count].name = strdup(name);
        symbol_table[symbol_count].type = type;
        symbol_table[symbol_count].is_const = is_const;
        return symbol_count++;
    } else {
        yyerror("Symbol table full");
        return -1;
    }
}

int find_symbol(char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void update_symbol_value(int index, void* value) {
    if (index >= 0 && index < symbol_count) {
        switch (symbol_table[index].type) {
            case 0: // int
                symbol_table[index].value.i_val = *(int*)value;
                break;
            case 1: // float
                symbol_table[index].value.f_val = *(float*)value;
                break;
            case 2: // text
                symbol_table[index].value.s_val = strdup((char*)value);
                break;
            case 3: // boolean
                symbol_table[index].value.b_val = *(bool*)value;
                break;
            case 4: // char
                symbol_table[index].value.c_val = *(char*)value;
                break;
        }
    }
}

void print_symbol_value(int index) {
    if (index >= 0 && index < symbol_count) {
        printf("Symbol %s = ", symbol_table[index].name);
        switch (symbol_table[index].type) {
            case 0: // int
                printf("%d\n", symbol_table[index].value.i_val);
                break;
            case 1: // float
                printf("%f\n", symbol_table[index].value.f_val);
                break;
            case 2: // text
                printf("%s\n", symbol_table[index].value.s_val);
                break;
            case 3: // boolean
                printf("%s\n", symbol_table[index].value.b_val ? "true" : "false");
                break;
            case 4: // char
                printf("%c\n", symbol_table[index].value.c_val);
                break;
        }
    }
}

void push_exception(char* message) {
    if (exception_count < MAX_EXCEPTIONS) {
        exception_stack[exception_count++] = strdup(message);
    } else {
        yyerror("Exception stack overflow");
    }
}

char* pop_exception() {
    if (exception_count > 0) {
        return exception_stack[--exception_count];
    } else {
        return "No exception";
    }
}

int main(void) {
    return yyparse();
}

void yyerror(char *s) {
    extern int yylineno;
    extern char *yytext;
    fprintf(stderr, "Error: %s at line %d, near token '%s'\n", s, yylineno, yytext);
} 