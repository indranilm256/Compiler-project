# Compiler-project

Implementation Language : C++
Target Language : MIPS

## Install steps:
1. git clone https://github.com/indranilm256/Compiler-project.git
2. cd Compiler-project
3. make

## Testing:

Test files are available in ./test directory.

#### To test run the command:
./bin/parser ./test/testfile -o myAST.dot

#### For example:
./bin/parser ./test/test1.c -o myAST.dot

GST.csv is generated which is the global symbol table. Corresponding to every statement block a .csv file is generated with related name to the block(local symbol table).

#### To display the graph:
xdot myAST.dot / display myAST.dot

## References:

The grammar specifiactions have been taken from:

- https://www.lysator.liu.se/c/ANSI-C-grammar-l.html
- https://www.lysator.liu.se/c/ANSI-C-grammar-y.html