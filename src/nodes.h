#include <string>
#include <iostream>
#include <sstream>
#include <list>
#include <stdio.h>
#include "3ac.h"

using namespace std;
void graphStart();
void graphEnd();
int ID_for_Node();
class Node{
        
    public:
        string node_name;
        string node_type;
        string node_key;
        int node_id;
        long long size;
        long long int iVal;
        long double rVal;
        char* str;
        char cVal;
        int is_init;
        int expr_type;
        Node(char* str){
            node_name = str;
            node_id = ID_for_Node();
        }
        void mkleaf();
        void mknode(char *op, Node *l, Node *r);
        void mknode(Node *l,Node *m, Node *r);
        void mknode(char *op1,char *op3, Node *l,char *op2);
        void mknode(Node *a1,Node *a2, Node *a3, Node*a4,char* op);
        void mknode(Node *a1,Node *a2, Node *a3, Node*a4,Node *a5);
        void mknode(Node *a, int flag);
        //3AC
      qid place;
      list<int> truelist;
      list<int> nextlist;
      list<int> falselist;
      list<int> breaklist;
      list<int> continuelist;
      list<int> caselist;
};
enum ntype {
    N_INT , N_LONG , N_LONGLONG , N_FLOAT , N_DOUBLE, N_LONGDOUBLE
};
typedef struct{
   int nType; /* 0 int , 1 long , 2 long long ,3 float,4 : double , 5:long double */
   int is_unsigned;
   char* str;
   long long int iVal  ;
   long double rVal;
} numb;
typedef struct{
   long long int iVal;
   long double rVal;
   char* str;
   char cVal;
   int expr_type;
   Node* nPtr;
} exprNode;

