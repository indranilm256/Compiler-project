
#include "symbol_table.h"
#include <vector>
#include <iostream>
using namespace std;
map<string , string> funcArgumentMap;
map<string , symTable*> toStructTable;
map<string , int> structSize;
map<symTable *, symTable*> tParent;
map<symTable *, int> symTable_type;
// map<string ,int> switchItem;
map<int, string> statusMap;
long int blockSize[100];
int blockNo ;
//////////////////////////////
long long offsetNext[100];
int offsetNo;
////////////////////////////////
long long global_offset[100];
int global_offset_number;
int structCount;
int structOffset;
symTable GST;
int is_next;
symTable *curr;
symTable *structTable;
symTable *tempStructTable;


void symbol_table:: makeStructTable(){
   symTable* myStruct = new symTable;
   structCount++;
   structTable = myStruct;
   structOffset = 0;  
}

bool symbol_table:: insertStructSymbol(string key, string type, ull size, ull offset, int isInit ){
           if((*structTable).count(key)) return false;
           insertSymbol(*structTable, key, type, size, -10, isInit);
           structOffset += size;
           return true;
}

bool symbol_table::endStructTable(string structName){
   if(toStructTable.count(structName)) return false;
   toStructTable.insert(pair<string, symTable*>(string("STRUCT_")+structName, structTable)); 
   tParent.insert(pair<symTable*, symTable*>(structTable, NULL));
   //cout<<structOffset<<"xsa"<<endl;
   structSize.insert(pair<string, int>(string("STRUCT_")+structName, structOffset));
   structName = "struct_" + structName + ".csv";
   printSymTables(structTable, structName);
   return true;
}

string symbol_table::structMemberType(string structName, string idT){
   tempStructTable = toStructTable[structName];
   sEntry* aT = (*tempStructTable)[idT];
   return aT->type;
}

bool symbol_table::isStruct(string structName){
   if(toStructTable.count(structName)) return true;
}

int symbol_table::structLookup(string structName, string idStruct){
   if(toStructTable.count(structName)!=1) return 1;
   else if((*toStructTable[structName]).count(idStruct)!=1) return 2;
   return 0;

}


void symbol_table:: symbol_table_init(){
    for(blockNo=0;blockNo<100;blockNo++){
        blockSize[blockNo]=0;
    }
    global_offset_number=0;
    global_offset[global_offset_number]=0;
    offsetNo=0;
    blockNo=0;
    tParent.insert(make_pair<symTable*, symTable*>(&GST, NULL));
    symTable_type.insert(make_pair<symTable*, int>(&GST, 1));
    curr = &GST;
    is_next = 0;
    addKeywords();
    funcArgumentMap.insert(pair<string,string>(string("printf"),string("float")));
    funcArgumentMap.insert(pair<string,string>(string("printn"),string("int")));
    funcArgumentMap.insert(pair<string,string>(string("prints"),string("char*,...")));
    funcArgumentMap.insert(pair<string,string>(string("scanf"),string("char*,float")));
    funcArgumentMap.insert(pair<string,string>(string("scann"),string("char*,int")));
    funcArgumentMap.insert(pair<string,string>(string("scans"),string("char*,...")));
    funcArgumentMap.insert(pair<string,string>(string("strlen"),string("char*")));
    funcArgumentMap.insert(pair<string,string>(string("fread"),string("char*")));
    funcArgumentMap.insert(pair<string,string>(string("fwrite"),string("char*,char*")));
    funcArgumentMap.insert(pair<string,string>(string("pow"),string("int,int")));
    funcArgumentMap.insert(pair<string,string>(string("sqrt"),string("int")));
}
void symbol_table:: paramTable(){   
      offsetNo++;
      offsetNext[offsetNo]=global_offset[global_offset_number];
      make_symbol_table(string("Next"),S_FUNC,string(""));
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
   else if(offset==-10){table.insert (pair<string,sEntry *>(key,makeEntry(type,size,structOffset,isInit))); }
   else { table.insert (pair<string,sEntry *>(key,makeEntry(type,size,global_offset[global_offset_number],isInit))); }
   global_offset[global_offset_number] = global_offset[global_offset_number] + size;
   return;
}

// void symbol_table:: fprintStruct(sEntry *a, FILE* file){
   
//     fprintf(file, "%s,",a->type.c_str());
//     switch(switchItem[a->type]){
//         case 1:{ 
//   //               cout << *tmp << endl;
//                  fprintf(file, " %lld,%lld,%d\n", a->size, a->offset,a->is_init);
//                  break;
//                }
//         case 2:{ //int* tmp = (int  *)(a->value);
//                  fprintf(file, "%lld,%lld ,%d\n", a->size, a->offset,a->is_init);
//     //             cout << *tmp << endl;
//                  break;
//                 }
//         case 3:{
//                //  fprintf(file, "This is a function,");
//                  fprintf(file, "%lld, %lld,%d\n", a->size, a->offset,a->is_init); break;

//                }
//        default : {
//                  //fprintf(file, "NULL,");
//                  fprintf(file, "%lld, %lld, %d\n", a->size, a->offset,a->is_init);

//                }

//     }

// }

string symbol_table:: funcArgList(string key){
      string a = funcArgumentMap[key];
      return a;
}

void symbol_table:: make_symbol_table(string name,int type,string funcType){
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
    global_offset_number++;
    global_offset[global_offset_number]=0;
    tParent.insert(pair<symTable*, symTable*>(myTable,curr));
    symTable_type.insert(pair<symTable*, int>(myTable,type));
    curr = myTable; }
    is_next=0;
}

void symbol_table:: update_symbol_table(string key){
    curr = tParent[curr];
    global_offset_number--;
    global_offset[global_offset_number] += global_offset[global_offset_number+1];
    update_symbol_table_size(key);
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
  if(structSize.count(id)) return structSize[string(id)];
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
void symbol_table:: update_symbol_table_size(string key){
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
void symbol_table:: insert_function_args(string a,string b){
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
    
   //  fprintStruct(it.second, file);  
    fprintf(file, "%s,",it.second->type.c_str());
    fprintf(file, " %lld,%lld,%d\n", it.second->size, it.second->offset,it.second->is_init);
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
   /*for(int i=0;i<45;i++){
      insertSymbol(*curr,Keyword[i],"Keyword",8,0,1);
   }*/
//-----------------------------inserting operators---------------------------------------------------
vector<string> Operator = {"...",">>==","<<==","+=","-=","*=","/=","%=","&=","^=","|=",">>","<<","++","--","->","&&","||","<=",">=","\=\=","!=",
                           ";","{","<%","}","%>",",",":","=","(",")","[","]","<:",":>",".","&","!","~","-","+","*","/","%","<",
                           ">","^","|","?"};
  
/*for(int i=0;i<50;i++){
   insertSymbol(*curr,Operator[i],"Operator",8,0,1);
}*/

//////////////// basic printf, scanf, strlen :: to get the code running /////////
  insertSymbol(*curr,"printf","FUNC_void",8,0,1); // print_float
  insertSymbol(*curr,"prints","FUNC_void",8,0,1); // print_string
  insertSymbol(*curr,"printn","FUNC_void",8,0,1); // print_int
  insertSymbol(*curr,"scanf","FUNC_int",8,0,1); // read_float
  insertSymbol(*curr,"scann","FUNC_int",8,0,1); // read_int
  insertSymbol(*curr,"scans","FUNC_int",8,0,1); // read_string
  insertSymbol(*curr,"strlen","FUNC_int",8,0,1); //
  insertSymbol(*curr,"fread","FUNC_int",8,0,1);
  insertSymbol(*curr,"fwrite","FUNC_int",8,0,1);
  insertSymbol(*curr,"pow","FUNC_int",8,0,1);
  insertSymbol(*curr,"sqrt","FUNC_int",8,0,1);
}
