

#include <iostream>
#include <string>
#include <string.h>
#include <unordered_map>
#include <map>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;

enum symTable_types{
	S_FILE,S_BLOCK,S_FUNC,S_PROTO
};

// symbol table entry data structure

//////////////////////////////////
/*class sEntry{
public:
    string type;
    int is_init;
 //   void *value;
    ull size;
    ll offset;
};*/
/////////////////////////////////


typedef struct sTableEntry{
    string type;
    int is_init;
 //   void *value;
    ull size;
    ll offset;
} sEntry;



typedef unordered_map<string,sEntry *> symTable;

//extern long long offsetNext[100];
//extern int offsetNo;
extern long int blockSize[100];
extern int blockNo;
extern long long offsetG[100];
extern int offsetGNo;

extern symTable GST;
extern symTable *curr;
extern int is_next;

extern map<string , string> funcArgumentMap;
extern map<symTable *, symTable*> tParent;
extern map<symTable *, int > symTable_type;
extern map<string ,int> switchItem;
extern map<int, string> statusMap;


class symbol_table{
public:   
    static void paramTable();
    static ull getSize (char* id);
    static string returnSymType(string key);
    static void switchItemMap();
    static void fprintStruct(sEntry *a, FILE *file);
    static void stInitialize();
    static void addKeywords();
    static void update_isInit(string key);
    static void makeSymTable(string name,int type,string funcType);
    static void insertFuncArguments(string a,string b);
    //void updateKey(string key,void *val);
    static void updateSymTable(string key);
    static sEntry* lookup(string a);
    static sEntry* scopeLookup(string a);
    static sEntry* makeEntry(string type, ull size, ll offset,int isInit);
    static void insertSymbol(symTable& table,string key,string type,ull size,ll offset,int isInit);
    static void printSymTables(symTable *a, string filename);
    static void printFuncArguments();
    static string funcArgList(string key);
    static void updateSymtableSize(string key);
    static void updateOffset(string key1,string key2);
};
