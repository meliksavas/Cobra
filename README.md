# Cobra Programming Language

## Group Members
- **Melik Savaş** - *20220808015*  
- **Cenker Aydın** - *20210808002*  
- **Emre Cecanpunar** - *20220808020*  
- **Göktuğ Berke Güngören** - *20210808057*  

## Running Instructions

```bash
# Compile the compiler
make cobra

# Run a Cobra program
./cobra < example.cbr

# Clean up generated files
make clean
```

## Grammar of our programming language in BNF format

```
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
<text> ::= "\"" <text_content> "\""
<text_content> ::= [a-zA-Z0-9_ .,!?]*

<id> ::= [a-zA-Z_][a-zA-Z0-9_]*
```

## Language Features

### 1. Simple PL with statement-by-statement execution
The Cobra language supports sequential execution of statements. Each statement is executed in the order it appears in the program.

### 2. Comments
Comments in Cobra start with `//` and continue until the end of the line.

Example:
```
// This is a comment
var int x = 10; // This is also a comment
```

### 3. Conditional Statements
Cobra supports if-else and if-elif-else constructs for conditional execution.

Example:
```
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

### 4. Loops
Cobra supports both while and for loops.

Example:
```
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

### 5. Functions
Cobra allows you to define and call functions.

Example:
```
// Function definition
function add(int a, int b)
<<
    return a + b;
>>

// Function call
var int result = add(5, 3);
print(result);
```

### 6. Exception Handling
Cobra provides try-catch blocks for exception handling and a throw mechanism for raising exceptions.

Example:
```
try
<<
    // Code that might throw an exception
    var int x = 10 / 0;
>>
catch
<<
    print("Division by zero error");
>>

// Throw an exception
throw "Error message";
```

## Key Syntax Notes

Important notes about using the Cobra language with our implementation:

1. The parser reports type errors for non-integer variables when using print, but the output is still shown if you print variables of other types.

2. Our example demonstrates all the required language features:
   - Simple PL with statement-by-statement execution
   - Comments
   - Conditional statements (if-else, if-elif-else)
   - Loops (for, while)
   - Functions
   - Exception handling (try-catch, throw)

3. Boolean operations like `flag && true` are not supported directly in variable assignments.

4. Example usage:
   ```
   make cobra
   ./cobra < full_test.cbr
   ```

## Design Decisions

1. **Symbol Table**: We implemented a symbol table to track variable names, types, and values. This allows for type checking and enforcing constant values.

2. **Type System**: Cobra supports five basic types:
   - int: Integer values
   - float: Floating-point values
   - text: String values
   - boolean: Boolean values (true/false)
   - char: Single character values

3. **Block Structure**: Code blocks are enclosed in `<<` and `>>` symbols, providing clear visual separation for nested structures.

4. **Program Structure**: All Cobra programs begin with `RUN` and end with `FINISH;`.

5. **Exception Handling**: The language includes built-in exception handling with try-catch blocks and the ability to throw custom exceptions.

6. **Variables and Constants**: Cobra distinguishes between variables (mutable) and constants (immutable) to enhance code safety and readability.

## Implementation Details

1. **Lexical Analysis**: Implemented using Flex (cobra.l) to tokenize the input program.

2. **Syntax Analysis**: Implemented using Bison/Yacc (cobra.y) to parse the tokens and construct a parse tree.

3. **Symbol Table**: A simple symbol table stores variable information, including name, type, value, and mutability.

4. **Type Checking**: Basic type checking ensures that operations are performed on compatible types.

5. **Control Flow**: Conditional statements and loops are implemented with appropriate semantic actions.

6. **Function Handling**: Functions are parsed and their calls are implemented, supporting basic return values.

7. **Exception Handling**: Exception stack maintains thrown exceptions that can be caught and handled.

## Future Enhancements

1. **Type Inference**: Automatically deduce variable types from assigned expressions.

2. **Arrays and Collections**: Add support for arrays and other collection types.

3. **Classes and Objects**: Extend the language with object-oriented features.

4. **Module System**: Implement a module system for better code organization.

5. **Optimizations**: Add compiler optimizations for better performance.

6. **Debugging Tools**: Integrate debugging capabilities into the language.
