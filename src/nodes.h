#include <string>
#include <iostream>
#include <sstream>
#include <list>
#include <stdio.h>

using namespace std;
typedef struct {
  long long size;
  long long int iVal;
  long double rVal;
  char* str;
  char cVal;
  int is_init;
  int expr_type;
  string node_name;
  string node_type;
  string node_key;
  int node_id;
} node;

enum ntype {
    N_INT , N_LONG , N_LONGLONG , N_FLOAT , N_DOUBLE, N_LONGDOUBLE
};
typedef struct{
   int nType; /* 0 int , 1 long , 2 long long ,3 float,4 : double , 5:long double */
   int is_unsigned;
   char* str;
   long long int iVal;
   long double rVal;
} numb;
typedef struct{
   long long int iVal;
   long double rVal;
   char* str;
   char cVal;
   int expr_type;
   node* nPtr;
} exprNode;

int ID_for_Node();
void graphStart();
void graphEnd();
node *mkleaf(char *str);
node *mknode(char *str,char *op, node *l, node *r);
node *mknode(char *str,node *l,node *m, node *r);
node *mknode(char *str,char *op1,char *op3, node *l,char *op2);
node *mknode(char *str,node *a1,node *a2, node *a3, node*a4,char* op);
node *mknode(char *str,node *a1,node *a2, node *a3, node*a4,node *a5);
node *mknode(char *str, node *a, int flag);

