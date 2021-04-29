
#include "symbol_table.h"
#include <vector>
#include <iostream>
using namespace std;
map<string , string> funcArgumentMap;
map<symTable *, symTable*> tParent;
map<symTable *, int> symTable_type;
map<string ,int> switchItem;
map<int, string> statusMap;
long int blockSize[100];
int blockNo ;
//////////////////////////////
long long offsetNext[100];
int offsetNo;
////////////////////////////////
long long offsetG[100];
int offsetGNo;

symTable GST;
int is_next;
symTable *curr;

void symbol_table:: switchItemMap(){
   //symbol_table temp = this;
   statusMap.insert(make_pair<int, string>(1,"iVal"));
   statusMap.insert(make_pair<int, string>(2,"fVal"));
   statusMap.insert(make_pair<int, string>(3,"dVal"));
   statusMap.insert(make_pair<int, string>(4,"sVal"));
   statusMap.insert(make_pair<int, string>(5,"cVal"));
   statusMap.insert(make_pair<int, string>(6,"bVal"));
   switchItem.insert(make_pair<string, int>("string", 1));
   switchItem.insert(make_pair<string, int>("int", 2));
   switchItem.insert(make_pair<string, int>("func", 3));
   switchItem.insert(make_pair<string, int>("Keyword", 1));
   switchItem.insert(make_pair<string, int>("Operator",1));
   switchItem.insert(make_pair<string, int>("IDENTIFIER", 1));
   switchItem.insert(make_pair<string, int>("ENUMERATION_CONSTANT", 1));
   switchItem.insert(make_pair<string, int>("TYPEDEF_NAME", 1));
   // cout<<switchItem["string"];
}

void symbol_table:: stInitialize(){
    for(blockNo=0;blockNo<100;blockNo++){
        blockSize[blockNo]=0;
    }
    offsetGNo=0;
    offsetG[offsetGNo]=0;
    offsetNo=0;
    blockNo=0;
    switchItemMap();
    tParent.insert(make_pair<symTable*, symTable*>(&GST, NULL));
    symTable_type.insert(make_pair<symTable*, int>(&GST, 1));
    curr = &GST;
    is_next = 0;
    addKeywords();
    funcArgumentMap.insert(pair<string,string>(string("printf"),string("char*,...")));
    funcArgumentMap.insert(pair<string,string>(string("scanf"),string("char*,...")));
    funcArgumentMap.insert(pair<string,string>(string("strlen"),string("void*")));

}
void symbol_table:: paramTable(){   
      offsetNo++;
      offsetNext[offsetNo]=offsetG[offsetGNo];
      makeSymTable(string("Next"),S_FUNC,string(""));
      is_next=1;
}

sEntry* symbol_table:: makeEntry(string type,ull size,ll offset,int isInit){
    sEntry* mynew = new sEntry();
    mynew->type = type;
    mynew->size = size;
    mynew->offset = offset;
    mynew->is_init = isInit;
    return mynew;
}

string symbol_table:: returnSymType(string key){
    sEntry* temp = lookup(key);
    if(temp){ string a = temp->type;return a;}
    else return string();
}

void symbol_table:: insertSymbol(symTable& table,string key,string type,ull size,ll offset, int isInit){
   blockSize[blockNo] = blockSize[blockNo] + size;
   if(offset==10){ table.insert (pair<string,sEntry *>(key,makeEntry(type,size,offsetNext[offsetNo],isInit))); }
   else { table.insert (pair<string,sEntry *>(key,makeEntry(type,size,offsetG[offsetGNo],isInit))); }
   offsetG[offsetGNo] = offsetG[offsetGNo] + size;
   return;
}

void symbol_table:: fprintStruct(sEntry *a, FILE* file){
   // cout << a->type << " " << "";
    fprintf(file, "%s,",a->type.c_str());
    switch(switchItem[a->type]){
        case 1:{ 
  //               cout << *tmp << endl;
                 fprintf(file, " %lld,%lld,%d\n", a->size, a->offset,a->is_init);
                 break;
               }
        case 2:{ //int* tmp = (int  *)(a->value);
                 fprintf(file, "%lld,%lld ,%d\n", a->size, a->offset,a->is_init);
    //             cout << *tmp << endl;
                 break;
                }
        case 3:{
               //  fprintf(file, "This is a function,");
                 fprintf(file, "%lld, %lld,%d\n", a->size, a->offset,a->is_init); break;

               }
       default : {
                 //fprintf(file, "NULL,");
                 fprintf(file, "%lld, %lld, %d\n", a->size, a->offset,a->is_init);

               }

    }

}

string symbol_table:: funcArgList(string key){
      string a = funcArgumentMap[key];
      return a;
}

void symbol_table:: makeSymTable(string name,int type,string funcType){
  string f ;
  if(funcType!="12345") f =string("FUNC_")+funcType; else f = string("Block");
  if(is_next==1){ insertSymbol(*tParent[curr],name,f,0,10,1);
                  offsetNo--;
                  // updateOffset(name,string("Next")); 
                  (*tParent[curr]).erase(string("Next"));   
       }
  else { 
   blockNo++;
   symTable* myTable = new symTable;
    insertSymbol(*curr,name,f,0,0,1);
    offsetGNo++;
    offsetG[offsetGNo]=0;
    tParent.insert(pair<symTable*, symTable*>(myTable,curr));
    symTable_type.insert(pair<symTable*, int>(myTable,type));
    curr = myTable; }
    is_next=0;
}

void symbol_table:: updateSymTable(string key){
    curr = tParent[curr];
    offsetGNo--;
    offsetG[offsetGNo] += offsetG[offsetGNo+1];
    updateSymtableSize(key);
    blockSize[blockNo-1] = blockSize[blockNo]+blockSize[blockNo-1];
    blockSize[blockNo] = 0;
    blockNo--;
}

sEntry* symbol_table:: lookup(string a){
   symTable * tmp;
   tmp = curr;
   while (1){
      if ((*tmp).count(a)){
         return (*tmp)[a];
      }
      if(tParent[tmp]!=NULL) tmp= tParent[tmp];
      else break;
   }
   return NULL;
}
sEntry* symbol_table:: scopeLookup(string a){
   symTable * tmp;
   tmp = curr;
      if ((*tmp).count(a)){
         return (*tmp)[a];
      }
   return NULL;
}
/*
void updateKey(string key,void *val){
   sEntry *temp = lookup(key);
   if(temp){ temp->value = val;
       temp->is_init =1;
   }
}
*/
ull symbol_table:: getSize (char* id){
  // integer
  if(!strcmp(id, "int")) return sizeof(int);
  if(!strcmp(id, "long int")) return sizeof(long int);
  if(!strcmp(id, "long long")) return sizeof(long long);
  if(!strcmp(id, "long long int")) return sizeof(long long int);
  if(!strcmp(id, "unsigned int")) return sizeof(unsigned int);
  if(!strcmp(id, "unsigned long int")) return sizeof(unsigned long int);
  if(!strcmp(id, "unsigned long long")) return sizeof(unsigned long long);
  if(!strcmp(id, "unsigned long long int")) return sizeof(unsigned long long int);
  if(!strcmp(id, "signed int")) return sizeof(signed int);
  if(!strcmp(id, "signed long int")) return sizeof(signed long int);
  if(!strcmp(id, "signed long long")) return sizeof(signed long long);
  if(!strcmp(id, "signed long long int")) return sizeof(signed long long int);
  if(!strcmp(id, "short")) return sizeof(short);
  if(!strcmp(id, "short int")) return sizeof(short int);
  if(!strcmp(id, "unsigned short int")) return sizeof(unsigned short int);
  if(!strcmp(id, "signed short int")) return sizeof(signed short int);


  //float
  if(!strcmp(id, "float")) return sizeof(float);
  if(!strcmp(id, "double")) return sizeof(double);
  if(!strcmp(id, "long double")) return sizeof(long double);

  //char
  if(!strcmp(id, "char")) return sizeof(char);

  return 8;

}

void symbol_table:: update_isInit(string key){
   sEntry *temp = lookup(key);
   if(temp){
       temp->is_init =1;
   }
}
void symbol_table:: updateSymtableSize(string key){
   sEntry *temp = lookup(key);
   if(temp){
       temp->size = blockSize[blockNo];
   }
}
/*
void updateOffset(string key1,string key2){
   sEntry *temp1 = lookup(key2);
   ull o;
   if(temp1) o = temp1->offset;
   sEntry *temp = lookup(key1);
   if(temp){
       temp->offset = o;
   }
} 
*/
void symbol_table:: insertFuncArguments(string a,string b){
     funcArgumentMap.insert(pair<string,string>(a,b));
}

void symbol_table:: printFuncArguments(){
     FILE* file = fopen("FuncArguments.csv","w");
     for(auto it:funcArgumentMap){
        fprintf(file,"%s,",it.first.c_str());
        fprintf(file,"%s\n",it.second.c_str());
     }
     fclose(file);     
}
void symbol_table:: printSymTables(symTable* a, string filename) {
  FILE* file = fopen(filename.c_str(), "w");
  fprintf( file,"Key,Type,Size,Offset,is_Initialized\n");


  for(auto it: *a ){
    fprintf( file,"%s,", it.first.c_str());
    fprintStruct(it.second, file);  
  }
  fclose(file);
}
void symbol_table:: addKeywords(){ //keywords inserted into GST

//-------------------inserting keywords-------------------------------------------
vector<string> Keyword = {"auto","break","case","char","const",
                        "continue","default","do","double","else",
                        "enum","extern","float","for","goto","if","inline","int","long",
                        "register","restrict","return","short","signed",
                        "sizeof","static","struct","switch","typedef",
                        "union","unsigned","void","volatile","while",
                        "_Alignas","_Alignof","_Atomic","_Bool","_Complex",
                        "_Generic","_Imaginary","_Noreturn","_Static_assert","_Thread_local","__func__"};
   for(int i=0;i<45;i++){
      insertSymbol(*curr,Keyword[i],"Keyword",8,0,1);
   }
//-----------------------------inserting operators---------------------------------------------------
vector<string> Operator = {"...",">>==","<<==","+=","-=","*=","/=","%=","&=","^=","|=",">>","<<","++","--","->","&&","||","<=",">=","\=\=","!=",
                           ";","{","<%","}","%>",",",":","=","(",")","[","]","<:",":>",".","&","!","~","-","+","*","/","%","<",
                           ">","^","|","?"};
  
for(int i=0;i<50;i++){
   insertSymbol(*curr,Operator[i],"Operator",8,0,1);
}

//////////////// basic printf, scanf, strlen :: to get the code running /////////
  insertSymbol(*curr,"printf","FUNC_void",8,0,1); //
  insertSymbol(*curr,"scanf","FUNC_int",8,0,1);
  insertSymbol(*curr,"prints","FUNC_void",8,0,1); //
  insertSymbol(*curr,"strlen","FUNC_int",8,0,1); //
  insertSymbol(*curr,"printn","FUNC_void",8,0,1); //
  insertSymbol(*curr,"readFile","FUNC_int",8,0,1);
  insertSymbol(*curr,"writeFile","FUNC_int",8,0,1);

}
