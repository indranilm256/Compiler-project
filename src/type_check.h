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
    static char* primary(char* identifier);
    static char* constant(int nType);
    static char* postfix(string type, int prodNum);
    static char* argument(string type1, string type2);
    static char* unary(string op, string type);
    static char* multiplicative(string type1, string type2, char op);
    static char* additive(string type1, string type2, char op);
    static char* shift(string type1,string type2);
    static char* relational(string type1,string type2,char * op);
    static char * equality(string type1,string type2);
    static char * bitwise(string type1,string type2);
    static char* conditional(string type1,string type2);
    static char* valid_assignment(string type1,string type2);
    static char* assignment(string type1,string type2,char* op);   
};
