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
./bin/mycompiler -i ./test/input -o output.txt

#### For example:
./bin/mycompiler -i ./test/test1.c -o output.txt

#### For multiple input files :
./bin/mycompiler -i ./test/test1.c ./test/test2.c -o output.txt

## References:

The grammar specifiactions have been taken from:

- https://www.lysator.liu.se/c/ANSI-C-grammar-l.html
- https://www.lysator.liu.se/c/ANSI-C-grammar-y.html