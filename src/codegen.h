#include <string>
#include <cstring>
#include <vector>
#include <map>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <stack>
#include <queue>
#include "nodes.h"
using namespace std;

extern string currFunction;

void generateCode();
void assignment_expression_asm_code(int i);
void operator_asm_code1(int i);
void operator_asm_code2(int i);
void call_seq_asm_code();
void return_seq_asm_code();
void addLine(string a);
void printCode();
void resetRegister();
string getNextReg(qid temporary);
void addData(string a);
void saveOnJump();
void loadArrayElement(qid temporary, string registerTmp);
void scan_string_asm();
void scan_float_asm();
void scan_int_asm();
void print_string_asm();
void print_float_asm();
void print_int_asm();
void read_file();
void write_file();
