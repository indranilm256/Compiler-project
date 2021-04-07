#include "type_check.h"
#include "symbol_table.h"

char *primaryExpr(char *identifier)
{
    sEntry *n = lookup(identifier);
    if (n)
    {
        char *s = new char();
        strcpy(s, (n->type).c_str());
        return s;
    }
    return NULL;
}

char *constant(int nType)
{
    if (nType == 1)
        return "int";
    if (nType == 2)
        return "long";
    if (nType == 3)
        return "long long";
    if (nType == 4)
        return "float";
    if (nType == 5)
        return "double";
    if (nType == 6)
        return "long double";
    return "default";
}

char *postfixExpr(string type, int prodNum)
{
    char *newtype = new char();
    strcpy(newtype, type.c_str());
    if (prodNum == 1)
    { // postfix_expression '[' expression ']'
        if (type[type.size() - 1] == '*')
        {
            newtype[type.size() - 1] = '\0';
            return newtype;
        }
        else
        {
            return NULL;
        }
    }
    if (prodNum == 2 || prodNum == 3)
    { // postfix_expression '(' argument_expression_list ')'
        string tmp = type.substr(0, 5);
        if (tmp == string("FUNC_"))
        {
            newtype += 5;
            return newtype;
        }
        else
            return NULL;
    }
    if (prodNum == 6 || prodNum == 7)
    { // postfix_expression INC_OP/DEC_OP
        if (isInt(type))
        {
            return newtype;
        }
        else
            return NULL;
    }
    if (prodNum == 8 || prodNum == 9)
    { //'(' type_name ')' '{' initializer_list ',' '}'
        return newtype;
    }
}

char *argumentExpr(string type1, string type2)
{
    char *a = new char();
    a = "void";
    /*  if(prodNum==1){ //assignment_expression
	if(type1==string("void"))//good string
	     return a;
	else {
	    a = "error";
	    return a;
	}	
    }*/
    //argument_expression_list ',' assignment_expression"
    if (type1 == string("void") && type2 == string("void"))
        return a;
    else
    {
        a = "error";
        return a;
    }
}

bool isInt(string type)
{
    if (type == string("int") || type == string("long") || type == string("long long") || type == string("long int") || type == string("long long int") ||
        type == string("unsigned int") || type == string("unsigned long") || type == string("unsigned long long") || type == string("unsigned long int") ||
        type == string("unsigned long long int") || type == string("signed int") || type == string("signed long") || type == string("signed long long") ||
        type == string("signed long int") || type == string("signed long long int") || type == string("short") || type == string("short int") ||
        type == string("signed short") || type == string("unsigned short") || type == string("unsigned short int") || type == string("signed short int"))
        return true;
    return false;
}

bool isSignedInt(string type)
{
    if ((type == string("int")) || (type == string("long")) || (type == string("long long")) || (type == string("long int")) || (type == string("long long int")) || (type == string("signed int")) || (type == string("signed long")) || (type == string("signed long long")) || (type == string("signed long int")) || (type == string("signed long long int")) ||
        (type == string("short")) || (type == string("short int")) || (type == string("signed short")) || (type == string("signed short int")))
    {
        return true;
    }

    return false;
}

bool isFloat(string type)
{
    if (type == string("float") || type == string("double") || type == string("long double") || type == string("unsigned float") || type == string("unsigned double") || type == string("unsigned long double") ||
        type == string("signed float") || type == string("signed double") || type == string("signed long double"))
    {
        return true;
    }

    return false;
}

bool isSignedFloat(string type)
{
    if (type == string("float") || type == string("signed double") || type == string("double") || type == string("long double") || type == string("signed float") ||
        type == string("signed long double"))
        return true;
    return false;
}

char *unaryExpr(string op, string type)
{

    //printf("in unaryExpr function\n");
    char *a = new char();
    //unary_operator cast_expression
    if (op == string("&"))
    { //&x return pointer* ------- int a = 5; int* p; p = &a;
        type = type + string("*");
    }
    if (op == string("*"))
    { //*x return x type pointer* -> pointer
        return postfixExpr(type, 1);
    }
    if (op == string("+") || op == string("-"))
    { //
        if (!(isFloat(type) || isInt(type) || type == string("_Complex") || type == string("_Imaginary")))
        {
            return NULL;
        }
    }
    if (op == string("~"))
    {
        if (!(isInt(type) || type == "bool"))
            return NULL;
    }
    if (op == string("!"))
    {
        if (type != "bool")
            return NULL;
    }
    strcpy(a, type.c_str());
    return a;
}

char *multiplicativeExpr(string type1, string type2, char op)
{ // multiplicative_expression '*' cast_expression   | multiplicative_expression '/' cast_expression  |  multiplicative_expression '%' cast_expression
    char *a = new char();
    if ((isInt(type1) || isFloat(type1)) && (isInt(type2) || isFloat(type2)))
    {
        {
            if (op == '%')
            {
                if (isInt(type1) && isInt(type2))
                {
                    a = "int";
                    return a;
                }
            }
            if (op == '*' || op == '/')
            {
                if (isInt(type1) && isInt(type2))
                {
                    a = "int";
                }
                else
                {
                    a = "float";
                }
                return a;
            }
        }
    }
    return NULL;
}

char *additiveExpr(string type1, string type2, char op)
{ // additive_expression '+' multiplicative_expression  | additive_expression '-' multiplicative_expression
    char *a = new char();
    if ((isInt(type1) || isFloat(type1)) && (isInt(type2) || isFloat(type2)))
    {
        if (isInt(type1) && isInt(type2))
        {
            a = "int";
        }
        else
        {
            a = "float";
        }
        return a;
    }

    if (type1 == string("_Complex") || type2 == string("_Complex"))
    {
        a = "_Complex";
        return a;
    }
    else if (type1 == string("_Imaginary") && type2 == string("_Imaginary"))
    {
        a = "_Imaginary";
        return a;
    }
    else if (type1 == string("char") && isInt(type2) || (type2 == string("char") && isInt(type1)))
    {
        a = "char";
        return a;
    }
    else if ((type1[type1.size() - 1] == '*') && isInt(type2) || (type2[type2.size() - 1] == '*') && isInt(type1)) // type1 int* return pointer
    {
        strcpy(a, type1.c_str());
        return a;
    }
    return NULL;
}

char *shiftExpr(string type1, string type2) //shift_expression LEFT_OP|RIGHT_OP additive_expression 
{
    char *a = new char();
    a = "True";
    if (isInt(type1) && isInt(type2))
        return a;
    else
        return NULL;
}
char *relationalExpr(string type1, string type2, char *op) //relational_expression '<'|'>'|LE|GE shift_expression
{
    char *a = new char();
    if (isInt(type1) || isFloat(type1) || type1 == string("char"))
    {
        if (type2[type2.size() - 1] == '*')
        {
            if (isInt(type1) || (type1 == string("char"))) //warning
            {
                a = "Bool";
                return a;
            }
            else
                return NULL;
        }
        else{
            a = "bool";
            return a;
        }
        
    }
    if (type1[type1.size() - 1] == '*')
    {
        if (isInt(type2) || (type2 == string("char"))) //Warning
        {
            a = "Bool";
            return a;
        }
        else
            return NULL;
    }
    return NULL;
}
char *equalityExpr(string type1, string type2) //equality_expression EQ_OP|NE_OP relational_expression
{
    char *a = new char();
    if (isInt(type1) || isFloat(type1) || (type1 == "char"))
    {
        if (isInt(type2) || isFloat(type2) || (type2 == "char"))
        {
            a = "True";
            return a;
        }
    }
    else if (type1[type1.size() - 1] == '*' && isInt(type2)||(type2[type2.size() - 1] == '*' && isInt(type1))) //warning
    {
        a = "true";
        return a;
    }
    else if (!strcmp(type1.c_str(), type2.c_str())) //both pointer
    {
        a = "True";
        return a;
    }
    return NULL;
}

char *bitwiseExpr(string type1, string type2) //and_expression '&'| '^' | '|' equality_expression | 
{ // ^,&,|
    char *a = new char();
    if ((type1 == string("bool")) && (type2 == string("bool")))
    {
        a = "true";
        return a;
    }
    if ((isInt(type1) || type1 == string("bool"))&&(isInt(type2) || type2 == string("bool"))) //warning
    {
        a = "True";
        return a;
    }
    return NULL;
}

char *conditionalExpr(string type1, string type2)//logical_or ?  expression ':' \epsilon  conditional_expression  $3, $6
{ // ???????????????????
    char *a = new char();
    // if (type1 == string("char"))
    //     type1 = string("long long");
    // if (isInt(type1))
    //     type1 = string("long double");
    // if (type2 == string("char"))
    //     type2 = string("long long");
    // if (isInt(type2))
    //     type2 = string("long double");
    
    if (isFloat(type1) && isFloat(type2))
    {
        a = "long double";
        return a;
    }
    if (type1 == type2)
    {
        strcpy(a, type1.c_str());
        return a;
    }
    if ((type1[type1.size() - 1] == '*') && type2[type2.size() - 1] == '*')
    {
        a = "void*";
        return a;
    }

    return NULL;
}

char *validAssign(string type1, string type2) //postfix_expression '(' argument_expression_list ')' | designation M initializer | initializer_list ',' M designation initializer | initializer_list ',' M  initializer 
{
    //printf("in validAssign function\n");
    char *a = new char();
    if (isInt(type2) && (type1[type1.size() - 1] == '*')){
        a = "warning";
        return a;
    }
    if (isInt(type1) && (type2[type2.size() - 1] == '*'))
    {
        a = "warning";
        return a;
    }
    // if (type1 == string("char"))
    //     type1 = string("long long");
    // if (isInt(type1))
    //     type1 = string("long double");
    // if (type2 == string("char"))
    //     type2 = string("long long");
    // if (isInt(type2))
    //     type2 = string("long double");

    if(isFloat(type2) && type1==string("char"))return NULL;

    if((isInt(type1)||type1==string("char"))&&(isFloat(type2) ||isInt(type2)))
    {
        a = "true";
        return a;
    }
    
    if((isInt(type1)||isFloat(type1))&&(isFloat(type2) ||isFloat(type1)))
    {
        a = "true";
        return a;
    }
    // if (isFloat(type1) && isFloat(type2))
    // {
    //     a = "true";
    //     return a;
    // }
    if (type1 == string("void*") && (type2[type2.size() - 1] == '*'))
    {
        a = "true";
        return a;
    }
    if (type2 == string("void*") && (type1[type1.size() - 1] == '*'))
    {
        a = "true";
        return a;
    }
    if (type1 == type2)
    {
        a = "true";
        return a;
    }
    if ((type2[type2.size() - 1] == '*') && (type1[type1.size() - 1] == '*')) //pointer but not similar type
    {
        a = "warning";
        return a;
    }
    return NULL;
}

char *assignmentExpr(string type1, string type2, char *op) // assignment expression valid or not
{
    char *a = new char();
    if (!strcmp(op, "=")) // op = '='
    {
        a = validAssign(type1, type2);
        if (a)
            return a;
        else
            return NULL;
    }
    else if ((!strcmp(op, "*=")) || (!strcmp(op, "/=")) || (!strcmp(op, "%=")))
    {
        a = multiplicativeExpr(type1, type2, op[0]);
        if (a)
        {
            a = "true";
            return a;
        }
    }
    else if ((!strcmp(op, "+=")) || (!strcmp(op, "-=")))
    {
        a = additiveExpr(type1, type2, op[0]);
        if (a)
        {
            a = "true";
            return a;
        }
    }
    else if ((!strcmp(op, ">>=")) || (!strcmp(op, "<<=")))
    {
        a = shiftExpr(type1, type2);
        if (a)
        {
            a = "true";
            return a;
        }
    }
    else if ((!strcmp(op, "&=")) || (!strcmp(op, "^=")) || (!strcmp(op, "|=")))
    {
        a = bitwiseExpr(type1, type2);
        if (a)
        {
            a = "true";
            return a;
        }
    }
    return NULL;
}
