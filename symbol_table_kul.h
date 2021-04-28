
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


class symbol_table{
public:
    long long offsetNext[100];
    int offsetNo;
    long int blockSize[100];
    int blockNo;
    long long offsetG[100];
    int offsetGNo;

    symTable GST;
    symTable *curr;
    int is_next;

    map<string , string> funcArgumentMap;
    map<symTable *, symTable*> tParent;
    map<symTable *, int > symTable_type;
    map<string ,int> switchItem;
    map<int, string> statusMap;

    symbol_table();
    

    void paramTable();
    ull getSize (char* id);
    string returnSymType(string key);
    void switchItemMap();
    void fprintStruct(sEntry *a, FILE *file);
    void stInitialize();
    void addKeywords();
    void update_isInit(string key);
    void makeSymTable(string name,int type,string funcType);
    void insertFuncArguments(string a,string b);
    //void updateKey(string key,void *val);
    void updateSymTable(string key);
    sEntry* lookup(string a);
    sEntry* scopeLookup(string a);
    sEntry* makeEntry(string type, ull size, ll offset,int isInit);
    void insertSymbol(symTable& table,string key,string type,ull size,ll offset,int isInit);
    void printSymTables(symTable *a, string filename);
    void printFuncArguments();
    string funcArgList(string key);
    void updateSymtableSize(string key);
    void updateOffset(string key1,string key2);

};
