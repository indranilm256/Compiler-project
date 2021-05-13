#include <fstream>
#include "3ac.h"
#include "type_check.h"
using namespace std;
using std::setw;

map<int , string> Goto_labels;
ofstream IRcode_file; // intermediate code file
long long inx = -1; //index
map<string, int> Goto_entry_no;
unordered_map<string, list<int>> Goto_patching;

vector <quad> IRcode;
string getVar(){
  static long a = 0;
  a++;
  string str =  string("__t");
  str = str + to_string(a);
  str = str + string("__");
  return str;
}

pair<string, sEntry*> getSym(string type){
  string tmp = getVar();
  char *cstr = new char[type.length() + 1];
  strcpy(cstr, type.c_str());
  symbol_table::insertSymbol(*curr, tmp, type, symbol_table::getSize(cstr),0, 1);
  return pair <string, sEntry* >(tmp, symbol_table::lookup(tmp));
}

int emit (qid op, qid id1, qid id2, qid  res, int stmtCounter){
  quad t;
  t.id1 = id1;
  t.id2 = id2;
  t.res = res;
  t.op = op;
  t.stmtCounter = stmtCounter;
  IRcode.push_back(t);
  inx++;
  return IRcode.size()-1;
}

void backPatch(list<int> li, int p){
  for(auto i : li){
    IRcode[i].stmtCounter = p;
  }
  return;
}


int assignment1(char *o, string type, string type1, string type3, qid place1, qid place3){
	qid t = getSym(type);
  qid t2;
	string op;
	string op1;
  int k, a = 0, b = 0;
  if(!strcmp(o,"=")){
    a=1;
  }else{
		op = o[0];
	}
  op1 = op;
	if(isInt(type1) && isInt(type3)){
		op += "int";
	  if(strcmp(o,"=")) k= emit(pair<string, sEntry*>(op, symbol_table::lookup(op1)), place1, place3, t, -1);
	}
	else if(isFloat(type1) && isInt(type3)){
		t2 = getSym(type);
		k = emit(pair<string, sEntry*>("inttoreal",NULL), place3,pair<string, sEntry*>("",NULL),t2,-1);
		op += "real";
		if(strcmp(o,"=")) emit(pair<string, sEntry*>(op, symbol_table::lookup(op1)), place1, t2, t, -1);
    b=1;
	}
	else if(isFloat(type3) && isInt(type1)){
		t2 = getSym(type);
		k = emit(pair<string, sEntry*>("realtoint",NULL),place3,pair<string, sEntry*>("",NULL),t2,-1);
		op += "int";
		if(strcmp(o,"=")) emit(pair<string, sEntry*>(op, symbol_table::lookup(op1)), place1, t2, t, -1);
    b=1;
	}
	else if(isFloat(type3) && isFloat(type1)){
		op += "real";
		if(strcmp(o,"=")) k=emit(pair<string, sEntry*>(op, symbol_table::lookup(op1)), place1, place3, t, -1);
	}
  if(a && b){emit(pair<string, sEntry*>("=", symbol_table::lookup("=")),  t2, pair<string, sEntry*>("", NULL), place1, -1);}
  else k = emit(pair<string, sEntry*>("=", symbol_table::lookup("=")),  t, pair<string, sEntry*>("", NULL), place1, -1);
  return k;
}
void assignment2(char *o, string type, string type1, string type3, qid place1, qid place3){
	qid t = getSym(type);
	string op;
	string op1;
  if(!strcmp(o,"%=")) op = "%";
  else if(!strcmp(o,"^=")) op = "^";
  else if(!strcmp(o,"|=")) op = "|";
  else if(!strcmp(o,"&=")) op = "&";
  op1 = op;
  if(!strcmp(o,"<<=")){ op="LEFT_OP"; op1="<<"; }
  if(!strcmp(o,">>=")){ op="RIGHT_OP"; op1=">>"; }
  emit(pair<string, sEntry*>(op, symbol_table::lookup(op1)), place1, place3, t, -1);
  emit(pair<string, sEntry*>("=", symbol_table::lookup("=")),  t, pair<string, sEntry*>("", NULL), place1, -1);
}
char* isunfinishedGoto(){
  for (auto it : Goto_patching){
    if(Goto_entry_no.find(it.first)==Goto_entry_no.end()){
        char *a;
        strcpy(a, it.first.c_str());
        return a;
    }
    else {
        backPatch(Goto_patching[it.first] , Goto_entry_no[it.first]);
    }
  }
    return NULL;
}

void write3acfile(){//name change merge
  IRcode_file.open("intermediateCode.txt");
	for(int i = 0; i<IRcode.size(); ++i)  {
		//display(IRcode[i], i);
      quad q = IRcode[i];
      if(q.stmtCounter == -1 || q.stmtCounter == -4){
        IRcode_file << setw(5) << "[" << i << "]" << ": " << setw(15) << q.op.first << " " <<
          setw(15) << q.id1.first << " " <<
          setw(15) << q.id2.first << " " <<
          setw(15) << q.res.first << '\n';
      }
      else if(q.stmtCounter==-2 || q.stmtCounter == -3){
        IRcode_file  << endl << "[" << i << "]" << ": "<< q.op.first << endl << endl;
      }

      else{
          int k = q.stmtCounter;
          while(IRcode[k].op.first == "GOTO" && IRcode[k].id1.first == ""){
              k = IRcode[k].stmtCounter;
          } 
          
          if(Goto_labels.find(k)==Goto_labels.end())Goto_labels.insert(pair<int, string>(k, "Label"+to_string(k)));
          IRcode_file << setw(5) << "[" << i << "]" << ": " << setw(15) << q.op.first << " " <<
          setw(15) << q.id1.first << " " <<
          setw(15) << q.id2.first << " " <<
          setw(15) << k << "---" << '\n';
          IRcode[i].stmtCounter = k;
      }

	}
	return;
  IRcode_file.close();
}
