#include <string>
#include <iostream>
#include <sstream>
#include <list>
#include <stdio.h>

using namespace std;

typedef struct {
  int node_id;
  char *str;
  string node_name;  
} node;

int ID_for_Node();
void graphStart();
void graphEnd();
node *terminal(char *str);
node *non_terminal_symbol_type1(char *str,char *op, node *l, node *r);
node *non_terminal_symbol_type2(char *str,node *l,node *m, node *r);
node *non_terminal_symbol_type3(char *str,char *op1,char *op3, node *l,char *op2);
node *non_terminal_symbol_type4(char *str,node *a1,node *a2, node *a3, node*a4,char* op);
node *non_terminal_symbol_type5(char *str,node *a1,node *a2, node *a3, node*a4,node *a5);
node *paranthesis_non_terminal(char *str, node *a);
node *square_non_terminal(char *str, node *a);

