#include <iostream>
#include <string>
#include <cstring>
#include <vector>
#include <list>
#include <map>
#include <iomanip>
#include "symbol_table.h"
using namespace std;
extern map<string, int> Goto_entry_no;
extern unordered_map<string, list<int>> Goto_patching;

extern map<int , string> Goto_labels;
typedef pair <string, sEntry*> qid;

typedef struct quadruple{
  qid id1;
  qid id2; 
  qid op;
  qid res;
  int stmtCounter;
} quad;


extern vector <quad> IRcode;
string getVar();
pair<string, sEntry*> getSym(string type);
int emit (qid id1, qid id2, qid op, qid  res, int stmtNum);
void backPatch(list<int> li, int i);
void write3acfile();
int assignment1(char *op, string type, string type1, string type3, qid place1, qid place3);
void assignment2(char *op, string type, string type1, string type3, qid place1, qid place3);
char* isunfinishedGoto();
