#include <iostream>
#include <string>
#include <cstring>
#include <vector>
#include <list>
#include <map>
#include <iomanip>
#include "symbol_table.h"
using namespace std;
extern map<string, int> gotoIndex;
extern unordered_map<string, list<int>> gotoIndexPatchList;
typedef pair <string, sEntry*> qid;

typedef struct quadruple{
  qid id1;
  qid id2; 
  qid op;
  qid res;
  int stmtNum;
} quad;

extern vector <quad> emittedCode;
extern map<int , string> gotoLabels;

string getTmpVar();
pair<string, sEntry*> getTmpSym(string type);
int emit (qid id1, qid id2, qid op, qid  res, int stmtNum);
void backPatch(list<int> li, int i);
void display3ac();
int assignment1(char *op, string type, string type1, string type3, qid place1, qid place3);
void assignment2(char *op, string type, string type1, string type3, qid place1, qid place3);
char* backPatchGoto();
