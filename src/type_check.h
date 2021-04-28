#include <iostream>
#include <string>
#include <cstring>
#include <unordered_map>
#include <map>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;
bool isInt (string type);
bool isSignedInt (string type);
bool isFloat (string type);
bool isSignedFloat (string type);
class type_check
{
    public:
    static char* primaryExpr(char* identifier);
    static char* constant(int nType);
    static char* postfixExpr(string type, int prodNum);
    static char* argumentExpr(string type1, string type2);
    static char* unaryExpr(string op, string type);
    static char* multiplicativeExpr(string type1, string type2, char op);
    static char* additiveExpr(string type1, string type2, char op);
    static char* shiftExpr(string type1,string type2);
    static char* relationalExpr(string type1,string type2,char * op);
    static char * equalityExpr(string type1,string type2);
    static char * bitwiseExpr(string type1,string type2);
    static char* conditionalExpr(string type1,string type2);
    static char* validAssign(string type1,string type2);
    static char* assignmentExpr(string type1,string type2,char* op);
    static int typedecide(string type1, string type2);
        
};
