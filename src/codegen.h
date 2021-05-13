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

extern string curr_func;

void code_generator();
void assignment_exp_asm(int i);
void operator_asm1(int i);
void operator_asm2(int i);
void call_seq_asm_code();
void return_seq_asm_code();
void putln(string a);
void print_code();
void reset_reg();
string get_reg(qid temp);
void putdata(string a);
void save_reg();
void array_to_reg(qid temp, string regtmp);
void scan_string_asm();
void scan_float_asm();
void scan_int_asm();
void print_string_asm();
void print_float_asm();
void print_int_asm();
void read_file();
void write_file();
