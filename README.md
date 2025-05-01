# Cobra Programming Language

A lightweight, educational programming language designed for teaching compiler fundamentals, featuring a custom syntax, type system, and exception handling.

---

## Group Members

| Name                    | Student ID     |
|-------------------------|----------------|
| **Melik Savaş**         | 20220808015    |
| **Cenker Aydın**        | 20210808002    |
| **Emre Cecanpunar**     | 20220808020    |
| **Göktuğ Berke Güngören** | 20210808057  |

---

## Getting Started

### Build Instructions

```bash
# Compile the compiler
make cobra
```

### Running a Cobra Program

```bash
./cobra < example.cbr
```

### Clean Up

```bash
make clean
```

---

## Language Grammar (BNF)

```bnf
<program> ::= <declarations> <code_blocks>

<declarations> ::= (<declaration> ";")*
<declaration> ::= <variable_declaration> | <constant_declaration> | <function_declaration>

<variable_declaration> ::= "var" <type> <id> "=" <expression>
<constant_declaration> ::= "const" <type> <id> "=" <expression>

<type> ::= "int" | "float" | "text" | "boolean" | "char" | "void"

<function_declaration> ::= "function" <function_name> "(" <parameters> ")" "<<" <code_blocks> ">>"

<parameters> ::= <parameter> | <parameter> "," <parameters>
<parameter> ::= <type> <id>

<code_blocks> ::= <statement> (";" <statement>)*

<statement> ::= <assignment> | <conditional> | <loop> | <io_operations> | <function_call> | <comment> | <return> | <exception_statement>

<assignment> ::= <id> "=" <expression>

<conditional> ::= "if" "(" <condition> ")" "then"
                 "<<" <code_blocks> ">>"
                 ("elif" "(" <condition> ")" "then" "<<" <code_blocks> ">>")*
                 ("else" "<<" <code_blocks> ">>")?

<loop> ::= <while_loop> | <for_loop>

<while_loop> ::= "while" "(" <condition> ")" "do"
                 "<<" <code_blocks> ">>"

<for_loop> ::= "for" "(" <assignment> ";" <condition> ";" <assignment> ")" "do"
               "<<" <code_blocks> ">>"

<io_operations> ::= "print" "(" <expression> ("," <expression>)* ")" | "input" "(" <id> ")"

<function_call> ::= <id> "(" [<argument_list>] ")"

<argument_list> ::= <expression> ("," <expression>)*

<comment> ::= "//" <comment_text>
<comment_text> ::= <any_character_except_newline>*

<return> ::= "return" <expression>

<exception_statement> ::= "try" "<<" <code_blocks> ">>" "catch" "<<" <code_blocks> ">>" | "throw" <expression>

<condition> ::= <expression> <operator> <expression> | "!" <condition> | <condition> ("&&" | "||") <condition>

<operator> ::= "<" | ">" | "==" | "!=" | "<=" | ">="

<expression> ::= <term> (("+" | "-") <term>)*
<term> ::= <factor> (("*" | "/") <factor>)*
<factor> ::= <number> | <boolean> | <char> | <text> | <id> | "(" <expression> ")"

<number> ::= <integer> | <float_number>
<integer> ::= [0-9]+
<float_number> ::= [0-9]+ "." [0-9]+
<boolean> ::= "true" | "false"
<char> ::= "'" [a-zA-Z0-9] "'"
<text> ::= """ <text_content> """
<text_content> ::= [a-zA-Z0-9_ .,!?]*

<id> ::= [a-zA-Z_][a-zA-Z0-9_]*
```

# Language Features

### Statement-by-Statement Execution

All Cobra programs execute statements in sequential order unless altered by control flow.

### Comments

```cobra
// This is a comment
var int x = 10; // This is also a comment
```

### Conditional Statements

```cobra
if (x > 10) then
<<
    print("x is greater than 10");
>>
elif (x == 10) then
<<
    print("x is equal to 10");
>>
else
<<
    print("x is less than 10");
>>
```

### Loops

```cobra
// While loop
var int counter = 0;
while (counter < 5) do
<<
    print(counter);
    counter = counter + 1;
>>

// For loop
for (i = 0; i < 5; i = i + 1) do
<<
    print(i);
>>
```

### Functions

```cobra
function add(int a, int b)
<<
    return a + b;
>>

var int result = add(5, 3);
print(result);
```

### Exception Handling

```cobra
try
<<
    var int x = 10 / 0;
>>
catch
<<
    print("Division by zero error");
>>

throw "Error message";
```

---

## Design Decisions

- **Symbol Table**: Tracks variable names, types, and immutability.
- **Type System**: Supports `int`, `float`, `text`, `boolean`, `char`, `void`.
- **Code Blocks**: Enclosed with `<< >>` for structural clarity.
- **Program Structure**: Begins with `RUN`, ends with `FINISH;`
- **Exception Stack**: Custom stack handles `throw` and `catch`.

---

## Implementation Details

- **Lexer**: Built with **Flex** (`cobra.l`)
- **Parser**: Built with **Bison/Yacc** (`cobra.y`)
- **Symbol Table**: Hash table for type & mutability tracking
- **Semantic Actions**: Used for control flow, type checking, and exception management
- **Function Execution**: Basic return and call semantics implemented
- **Error Handling**: Primitive type error warnings printed to stderr

---

## Future Enhancements

- Type inference
- Arrays and collections
- Object-oriented extensions
- Module & import system
- Optimizing compiler backend
- Debugging and visualization tools