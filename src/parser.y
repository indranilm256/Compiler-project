%{
#include <iostream>
#include <cstring>
#include <string>
#include <list>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdarg.h>
using namespace std;
#define MAX_STR_LEN 1024

#include "nodes.h"
#include "symbol_table.h"
#include "type_check.h"
extern FILE *yyin, *yyout; 
int yylex(void);
void yyerror(char *s,...);

int scope;
int symNumber = 0;
int funcSym=0;
int isFunc;
int blockSym=0;
string symFileName;
string funcName;
string funcType;
string funcArguments;
string currArguments;
string type = "";
FILE* digraph;
FILE *duplicate;
char filename[1000];
extern int yylineno;
%}

%union {
	int number; 
  	char *str;
  	node *ptr;
	exprNode* expr;
  	numb* num;
};


%token <str> IDENTIFIER STRING_LITERAL SIZEOF
%token <num> CONSTANT
%token <str> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token <str> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <str> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token <str> XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token <str> TYPEDEF EXTERN STATIC AUTO REGISTER
%token <str> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token <str> STRUCT UNION ENUM ELLIPSIS PRINTF
%type <str> assignment_operator
%token <str> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit

%left <str> ',' '^' '|' ';' '{' '}' '[' ']' '(' ')' '+' '-' '%' '/' '*' '.' '>' '<' 
%right <str> '&' '=' '!' '~' ':' '?'


//%type<str>VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED struct_or_union_specifier enum_specifier TYPE_NAME
%type <ptr> primary_expression postfix_expression unary_expression cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression conditional_expression constant_expression expression assignment_expression
%type <ptr> argument_expression_list type_name initializer_list
%type <ptr> unary_operator
%type <ptr> declaration declaration_specifiers
%type <ptr> init_declarator_list type_specifier type_qualifier storage_class_specifier
%type <ptr> init_declarator  declarator struct_or_union_specifier struct_or_union enum_specifier initializer struct_declaration_list
%type <ptr> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enumerator_list enumerator pointer 
%type <ptr> direct_declarator type_qualifier_list parameter_type_list  parameter_list parameter_declaration identifier_list
%type <ptr> abstract_declarator direct_abstract_declarator labeled_statement compound_statement expression_statement declaration_list statement_list
%type <ptr> selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition statement
%type <str> M1 M2 M3
%%

primary_expression
	: IDENTIFIER			{$$ = mkleaf($1);
							
							char* a = primaryExpr($1);
				    		if(a){
									string s = a;
                                    $$->is_init = lookup($1)->is_init;
                                    $$->node_type = s;
                                    string key($1);
                                    $$->node_key = key;
                                    $$->expr_type = 3; 
								}
				    		else{
								 	yyerror("Error: %s is not declared in this scope", $1);
									string empty = "";
                                    $$->node_type = empty;
								}
							}
	| CONSTANT				{
							
							long long int val = $1->iVal;
							
							
							$$ = mkleaf($1->str);
							char *a = constant($1->nType);
							
							string s = a;							
							$$->node_type = s;
							$$->is_init = 1;
							$$->iVal = val;
							$$->expr_type = 5;	
							}	
	| STRING_LITERAL		{$$ = mkleaf($1);
							string type = "char*";
							$$->node_type = type;
							$$->is_init = 1;
							}	
	| '(' expression ')'	{$$ = $2;}	
	;

postfix_expression
	: primary_expression	{$$ = $1;}
	| postfix_expression '[' expression ']'		{$$ = mknode("postfix_expression[expression]",(char*) NULL, $1, $3);
												if($1->is_init && $3->is_init){$$->is_init = 1;}
												char* a = postfixExpr($1->node_type, 1);
												if(a){
													string s = a;
													$$->node_type = s;
												}else{
													yyerror("Error: Array indexing with indices more than its dimension");
												}						
												}
	| postfix_expression '(' ')'		{	$$ = $1;
											$$->is_init = 1;
											char* a = postfixExpr($1->node_type,2);
										 	if(a){
												string s = a;
												$$->node_type = s;
												if($1->expr_type == 3){
													string funcArgs = funcArgList($1->node_key);
													if(funcArgs != string("")){
														yyerror("Error:%s function call requires arguments to be passed \n \'%s %s %s \'",($1->node_key).c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
													}
												}
											}else{
												yyerror("Error: Invalid function call");
											}
											string empty = "";
										 	currArguments = empty;
										} 			
	| postfix_expression '(' argument_expression_list ')'		{
																$$ = mknode("postfix_expression",(char*) NULL, $1, $3);
																if($3->is_init) $$->is_init = 1;
																char* a = postfixExpr($1->node_type, 3);
																if(a){
																	string s = a;
																	$$->node_type = s;
																	if($1->expr_type==3){
																		string funcArgs = funcArgList($1->node_key);
																		char* b = new char();
																		string tmp1 = currArguments;
																		string tmp2 = funcArgs;
																		string A,B;
																		unsigned f1 = 1;
																		unsigned f2 = 1;
																		int argnum = 0;
																		while(f1 != -1 && f2 != -1){
																			f1 = tmp1.find_first_of(",");
																			f2 = tmp2.find_first_of(",");
																			argnum += 1;
																			A = (f1 == -1) ? tmp1 : tmp1.substr(0,f1);																			
																			B = (f2 == -1) ?  tmp2 : tmp2.substr(0,f2);
																			if(f1 != -1) tmp1 = tmp1.substr(f1+1);
																			if(f2 != -1) tmp2 = tmp2.substr(f2+1);
																			if(B == "...") break;
																			b = validAssign(A,B);
																			if(b && !strcmp(b,"warning")){yyerror("Warning: Passing argumnet %d of \'%s\' from incompatible pointer type.\n Note : expected \'%s\' but argument is of type \'%s\'\n     \'%s %s %s \'",argnum,($1->node_key).c_str(),B.c_str(),A.c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());}
																			else{yyerror("Error: Incompatible type for argument %d of \'%s\'.\n Note: expected \'%s\' but argument is of type \'%s\' \n        \'%s %s %s \'",argnum,($1->node_key).c_str(),B.c_str(),A.c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());} 
																			if(f1 != -1 && f2 != -1){continue;}
																			else if(f2 != -1){
																				if(!(tmp2==string("..."))) yyerror("Error: Too few arguments for the function %s\n    %s %s %s ",($1->node_key).c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
                                 												break;
																			}else if(f1 != -1){
																				yyerror("Error: Too many arguments for the function %s\n    %s %s %s ",($1->node_key).c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
                                   												break;
																			}else{break;}
																		}
																	}
																}else{
																	yyerror("Error: Invalid Function call");
																}
																string empty = "";
										 						currArguments = empty;
															}
															
	| postfix_expression PTR_OP IDENTIFIER	{$$ = mknode("postfix_expression",$2,$1,mkleaf($3));}
	| postfix_expression INC_OP				{$$ = mknode("postfix_expression",$2,$1,(node*)NULL);
											if($1->is_init) $$->is_init = 1;
	  										char* a = postfixExpr($1->node_type, 6);
											if(a){
												string s = a; 
												$$->node_type = s;
											}
											else {
												yyerror("Error: Increment not defined for this type");
											}
	  										}
	| postfix_expression DEC_OP				{$$ = mknode("postfix_expression",$2,$1,(node*)NULL);
											if($1->is_init==1) $$->is_init =1;
											char *a = postfixExpr($1->node_type, 7);
											if(a){
												string s = a;
												$$->node_type = s;
											}else{
												yyerror("Error: Decrement not defined for this type");
											}
											}
	;

argument_expression_list
	: assignment_expression		{$$ = $1;
								if($1->is_init) $$->is_init = 1;
								currArguments = $1->node_type;
								}
	| argument_expression_list ',' assignment_expression		{$$ = mknode("assignment_expression_list",$2,$1,$3);
																char* a = argumentExpr($1->node_type, $3->node_type);
																string s = a;
																$$->node_type = s;	
																
																currArguments = currArguments + "," + $3->node_type;
																}
	;

unary_expression
	: postfix_expression		{$$ = $1;} 
	| INC_OP unary_expression	{$$=  mknode($1,(char*) NULL, (node*)NULL, $2);
								if($2->is_init) $$->is_init = 1;
								char* a = postfixExpr($2->node_type, 6);
								string s = a;
								if(a){$$->node_type = s;}else{yyerror("Error: Increment not defined for this type");}
								}
	| DEC_OP unary_expression	{$$=  mknode($1,(char*) NULL, (node*)NULL, $2); 
								if($2->is_init) $$->is_init = 1;
								char* a = postfixExpr($2->node_type, 6);
								string s = a;
								if(a){$$->node_type = s;}else{yyerror("Error: Increment not defined for this type");}
								}
	| unary_operator cast_expression	{$$ = mknode("unary_expression", (char*)NULL, $1, $2);
										if($2->is_init) $$->is_init = 1;
										char* a = unaryExpr($1->node_name, $2->node_type);
										string s = a;
										if(a)$$->node_type = s;
										else  yyerror("Error: Type inconsistent with operator %s", $1->node_name.c_str());
										}
	| SIZEOF unary_expression		{$$=  mknode($1, (char*)NULL, (node*)NULL, $2); 
									$$->node_type = "int";
									$$->is_init = 1;
									}
	| SIZEOF '(' type_name ')'		{$$ = mknode($1, (char*)NULL, (node*)NULL, $3);
									$$->node_type = "int";
									$$->is_init = 1;
									}
	;

unary_operator
	: '&'		{$$ = mkleaf($1);}
	| '*'		{$$ = mkleaf($1);}
	| '+'		{$$ = mkleaf($1);}
	| '-'		{$$ = mkleaf($1);}
	| '~'		{$$ = mkleaf($1);}
	| '!'		{$$ = mkleaf($1);}
	;

cast_expression
	: unary_expression		{$$ = $1;}
	| '(' type_name ')' cast_expression		{$$ = mknode("cast_expression", (char*)NULL, $2, $4);
											$$->node_type = $2->node_type;
											if($4->is_init) $$->is_init = 1;
											}
	;

multiplicative_expression
	: cast_expression		{$$ = $1;}
	| multiplicative_expression '*' cast_expression		{
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '*');
														if(a && !strcmp(a,"int")){$$ = mknode("*int",(char*)NULL,$1,$3); $$->node_type = "long long";}
														else if(a && !strcmp(a,"float")){$$ = mknode("*float",(char*)NULL,$1,$3); $$->node_type = "long double";}
														else{$$ = mknode($2,(char*)NULL,$1,$3); yyerror("Error: Incompatible type of * operator");}
														if($1->is_init && $3->is_init) $$->is_init = 1;
														}
	| multiplicative_expression '/' cast_expression		{
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '/');
														if(a && !strcmp(a,"int")){$$ = mknode("/int",(char*)NULL,$1,$3); $$->node_type = "long long";}
														else if(a && !strcmp(a,"float")){$$ = mknode("/float",(char*)NULL,$1,$3); $$->node_type = "long double";}
														else{$$ = mknode($2,(char*)NULL,$1,$3); yyerror("Error: Incompatible type of / operator");}
														if($1->is_init && $3->is_init) $$->is_init = 1;
														}
	| multiplicative_expression '%' cast_expression		{
														$$ = mknode($2,(char*)NULL,$1,$3);
														if($1->is_init && $3->is_init) $$->is_init = 1;
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '%');
														if(a){$$->node_type = "long long";}
														else{ yyerror("Error: Incompatible type of % operator");}
														}
	;

additive_expression
	: multiplicative_expression		{$$ = $1;}
	| additive_expression '+' multiplicative_expression		{
															char* a = additiveExpr($1->node_type,$3->node_type,'+');
															char* q = new char();
															if(a){string s = a;
															string p = string("+ ") + s;
															strcpy(q,p.c_str());
															}else{ q = "+";}
															$$ = mknode(q,(char*)NULL,$1,$3);
															if(a){ 
																string  s = a;
																if(!strcmp(a,"int")) {$$->node_type=string("long long");}
																else if(!strcmp(a,"float")) {$$->node_type=string("long double");}
																else{$$->node_type = s;}
															}else {
																yyerror("Error: Incompatible type for + operator");
															} 
															if($1->is_init && $3->is_init) $$->is_init = 1;
															}			
	| additive_expression '-' multiplicative_expression		{
															char* a = additiveExpr($1->node_type,$3->node_type,'-');
															char* q = new char();
															if(a){string s = a;
															string p = string("- ") + s;
															strcpy(q,p.c_str());
															}else{ q = "-";}
															$$ = mknode(q,(char*)NULL,$1,$3);
															if(a){ 
																string  s = a;
																if(!strcmp(a,"int")) {$$->node_type=string("long long");}
																else if(!strcmp(a,"float")) {$$->node_type=string("long double");}
																else{$$->node_type = s;}
															}else {
																yyerror("Error: Incompatible type for + operator");
															}
															if($1->is_init && $3->is_init) $$->is_init = 1;
															}
	;

shift_expression
	: additive_expression		{$$ = $1;}
	| shift_expression LEFT_OP additive_expression		{$$ = mknode($2,(char*)NULL,$1,$3);
                          								char* a = shiftExpr($1->node_type,$3->node_type);                        
														if(a){$$->node_type = $1->node_type;}else{yyerror("Error: Invalid operands to binary <<");}
                           								}
	| shift_expression RIGHT_OP additive_expression		{$$ = mknode($2,(char*)NULL,$1,$3);
														char* a = shiftExpr($1->node_type,$3->node_type);                        
														if(a){$$->node_type = $1->node_type;}else{yyerror("Error: Invalid operands to binary <<");}
														}
	;

relational_expression
	: shift_expression			{$$ = $1;}
	| relational_expression '<' shift_expression		{ 
														$$ = mknode($2,(char*)NULL,$1,$3);
														
														char* a = relationalExpr($1->node_type,$3->node_type,"<");
                										if(a){
															if(!strcmp(a,"bool")) $$->node_type = string("bool");
                    										else if(!strcmp(a,"Bool")){
																$$->node_type = string("bool");
																yyerror("Warning: comparison between pointer and integer");
                    										}
														}else {
                        									yyerror("Error: invalid operands to binary <");
                    									}
														if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
                  										}
	| relational_expression '>' shift_expression		
	{                
			$$ = mknode($2,(char*)NULL,$1,$3);
			char* a=relationalExpr($1->node_type,$3->node_type,">");                 
			if(a){ 
				if(!strcmp(a,"bool")) $$->node_type = string("bool");
				else if(!strcmp(a,"Bool")){
					$$->node_type = string("bool");
					yyerror("Warning: comparison between pointer and integer");
				}
			} else {
				yyerror("Error: invalid operands to binary >");
			}
			if($1->is_init==1 && $3->is_init==3) $$->is_init=1;

  	}
	| relational_expression LE_OP shift_expression		
	{
            $$ = mknode($2,(char*)NULL,$1,$3);
            char* a = relationalExpr($1->node_type,$3->node_type,"<=");               
			if(a){
				if(!strcmp(a,"bool")) $$->node_type = string("bool");
                else if(!strcmp(a,"Bool")){
                    $$->node_type = string("bool");
                    yyerror("Warning: comparison between pointer and integer");}
            }else {
                yyerror("Error: invalid operands to binary <=");
            }
            if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
      }
	| relational_expression GE_OP shift_expression		
	{
			$$ = mknode($2,(char*)NULL,$1,$3);
			char* a = relationalExpr($1->node_type,$3->node_type,">=");            
			if(a){  
				if(!strcmp(a,"bool")) $$->node_type = string("bool");
				else if(!strcmp(a,"Bool")){
					$$->node_type = string("bool");
					yyerror("Warning: comparison between pointer and integer");
					}
			}else {
				yyerror("Error: invalid operands to binary >=");
			}
			if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
     }
	;

equality_expression
	: relational_expression		{$$ = $1;}
	| equality_expression EQ_OP relational_expression		
	{
			$$ = mknode($2,(char*)NULL,$1,$3);
            char* a = equalityExpr($1->node_type,$3->node_type);
            if(a){ 
				if(!strcmp(a,"true")){
                	yyerror("Warning: Comparision between pointer and Integer");
            	} 
            	$$->node_type = "bool";
            }
            else{ yyerror("Error:Invalid operands to binary =="); }
            if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
    }
	| equality_expression NE_OP relational_expression	
	{
			$$ = mknode($2,(char*)NULL,$1,$3);
			char* a = equalityExpr($1->node_type,$3->node_type);
			if(a){   
				if(!strcmp(a,"true")){
					yyerror("Warning: Comparision between pointer and Integer");
				} 
				$$->node_type = "bool";
			}
			else{ yyerror("Error:Invalid operands to binary !="); }
			if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
    }
	;

and_expression
	: equality_expression		{$$ = $1;}
	| and_expression '&' equality_expression		
	{
        $$ = mknode($2,(char*)NULL,$1,$3);
        char* a = bitwiseExpr($1->node_type,$3->node_type);
        if(a){
            if(!strcmp(a,"true")) { $$->node_type = string("bool"); }
            else{   $$->node_type = string("long long");}
        }
        else {
            yyerror("Error:Invalid operands to the binary &");       
        }
        if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
    }
	;

exclusive_or_expression
	: and_expression			{$$ = $1;}
	| exclusive_or_expression '^' and_expression		
	{
        $$ = mknode($2,(char*)NULL,$1,$3);
        char* a = bitwiseExpr($1->node_type,$3->node_type);
        if(a){
            if(!strcmp(a,"true")) { $$->node_type = string("bool"); }
            else{   $$->node_type = string("long long");}
        }
        else {
            yyerror("Error:Invalid operands to the binary ^");
        }
        if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
	}
	;

inclusive_or_expression
	: exclusive_or_expression		{$$ = $1;}
	| inclusive_or_expression '|' exclusive_or_expression		
	{
            $$ = mknode($2,(char*)NULL,$1,$3);
            char* c = bitwiseExpr($1->node_type,$3->node_type);
            if(c){
                if(!strcmp(c,"true")) { $$->node_type = string("bool"); }
                else{   $$->node_type = string("long long");}
            }
        	else {
                yyerror("Error:Invalid operands to the binary |");
            }
        	if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
	}
	;

logical_and_expression
	: inclusive_or_expression		{$$ = $1;}
	| logical_and_expression AND_OP inclusive_or_expression			
	{
        $$ = mknode($2,(char*)NULL,$1,$3);
		$$->node_type == string("bool");
    	if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
    }
	;

logical_or_expression
	: logical_and_expression		{$$ = $1;}
	| logical_or_expression OR_OP logical_and_expression		
	{
        $$ = mknode($2,(char*)NULL,$1,$3);                        
        if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
        $$->node_type == string("bool");
    }
	;

conditional_expression
	: logical_or_expression			{$$ = $1;}
	| logical_or_expression '?' expression ':' conditional_expression		
	{
		//printf("line 526");
		$$ = mknode($2,(char*)NULL,$3,$5);
		char* c = conditionalExpr($3->node_type,$5->node_type);
		if(c){
			string str = c;
			$$->node_type = str;
		}
		else{
			yyerror("Error:Type mismatch in conditional expression");
		}
		if($1->is_init==1 && $3->is_init==3 && $5->is_init) $$->is_init=1;
    }
	;

assignment_expression
	: conditional_expression		{$$ = $1;}
	| unary_expression assignment_operator assignment_expression		
	{ 
		//printf("line 543");
		$$ = mknode($2,(char*)NULL,$1,$3);
    	char* c = assignmentExpr($1->node_type,$3->node_type,$2);
        if(c){
            if(!strcmp(c,"true")){ $$->node_type = $1->node_type; }
            if(!strcmp(c,"warning")){ 
				$$->node_type = $1->node_type;
                yyerror("Warning: Assignment with incompatible pointer type"); 
            }
        }
        else{ yyerror("Error: Incompatible types when assigning type \'%s\' to \'%s\' ",($1->node_type).c_str(),($3->node_type).c_str()); }
     	if($1->expr_type==3 && $3->is_init==1){ 
			update_isInit($1->node_key);
		} 
    }
	
	;

assignment_operator
	: '=' {$$ = "=";}
	| MUL_ASSIGN		{$$ = "*=";}
	| DIV_ASSIGN		{$$ = "/=";}
	| MOD_ASSIGN		{$$ = "%=";}
	| ADD_ASSIGN		{$$ = "+=";}
	| SUB_ASSIGN		{$$ = "-=";}
	| LEFT_ASSIGN		{$$ = "<<=";}
	| RIGHT_ASSIGN		{$$ = ">>=";}
	| AND_ASSIGN		{$$ = "&=";}
	| XOR_ASSIGN		{$$ = "^=";}
	| OR_ASSIGN			{$$ = "|=";}
	;


expression
	: assignment_expression			{$$ = $1;}
	| expression ',' assignment_expression		{
		$$ = mknode("expression",(char*) NULL, $1, $3);
		$$->node_type = string("void");
	}
	;

constant_expression
	: conditional_expression		{$$ = $1;}
	;

declaration
	: declaration_specifiers ';'	{ 
				string empty = ""; 
				type = empty; 
				$$ = $1;
		}	
	| declaration_specifiers init_declarator_list ';'   {
				string empty = ""; 
				type = empty;
				$$ = mknode("declaration",(char*) NULL, $1, $2);
		}
	;

declaration_specifiers
	: storage_class_specifier		{$$ = $1;}
	| storage_class_specifier declaration_specifiers		{$$ = mknode("declaration_specifiers",(char*) NULL, $1, $2);}
	| type_specifier				{$$ = $1;}
	| type_specifier declaration_specifiers					{$$ = mknode("declaration_specifiers", (char*)NULL, $1, $2);}
	| type_qualifier				{$$ = $1;}
	| type_qualifier declaration_specifiers					{$$ = mknode("declaration_specifiers", (char*)NULL, $1, $2);}
	;

init_declarator_list

	: init_declarator		{$$ = $1;}
	| init_declarator_list ',' init_declarator		{$$ = mknode("init_declarator_list",(char*) NULL, $1, $3);}
	;

init_declarator
	: declarator		
	{  
		$$= $1;
		if($1->expr_type==1){ char *t=new char();
			strcpy(t,($1->node_type).c_str());
			char *key =new char();
			strcpy(key,($1->node_key).c_str());
			if(scopeLookup($1->node_key)){ 
				yyerror("Error: redeclaration of \'%s\'",key);
			}else if($1->node_type==string("void")){
					yyerror("Error: Variable or field \'%s\' declared void",key);
				}else {  
					insertSymbol(*curr,key,t,$1->size,0,0);
				}
		} 
    }
	| declarator '=' initializer		{
		//printf("inside line 633");
		char * k = NULL;
		$$ = mknode("=",k, $1, $3);
		if($1->expr_type==1){ 
			char *t=new char();
            strcpy(t,($1->node_type).c_str());
            char *key =new char();
            strcpy(key,($1->node_key).c_str());
            if(scopeLookup($1->node_key)){ 
                yyerror("Error: redeclaration of \'%s\'",key);
            }else if($1->node_type==string("void")){
                    yyerror("Error: Variable or field \'%s\' declared void",key);
                   }else { 
					    insertSymbol(*curr,key,t,$1->size,0,0);
					}
        } 
	}
	;

storage_class_specifier
	: TYPEDEF 	{$$ = mkleaf($1);}
	| EXTERN	{$$ = mkleaf($1);}
	| STATIC	{$$ = mkleaf($1);}
	| AUTO		{$$ = mkleaf($1);}
	| REGISTER		{$$ = mkleaf($1);}
	;

type_specifier
	: VOID     {     
					if(type==string(""))type = string($1);
                	else type = type+string(" ")+string($1);
                	$$=mkleaf($1);
              	}
				  
  	| CHAR     {    
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
				    
					 
              	}
  	| SHORT     {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
  	| INT       {    // printf("ddsd");
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
					  
              	}
  	| LONG      {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
  	| FLOAT     {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
  	| DOUBLE    {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
  	| SIGNED    {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
  	| UNSIGNED  {     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
	| struct_or_union_specifier		{$$ = $1;}
	| enum_specifier		{$$ = $1;}
	| TYPE_NAME	{     
		  			if(type==string(""))type = string($1);
                   	else type = type+string(" ")+string($1);
                  	$$=mkleaf($1);
              	}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'		{$$ = mknode($2,(char*) NULL, $1, $4);}
	| struct_or_union '{' struct_declaration_list '}'		{$$ = mknode("struct_or_union_specifier",(char*) NULL, $1, $3);}
	| struct_or_union IDENTIFIER		{$$ = mknode($2,(char*) NULL,$1, NULL);}
	;
	
struct_or_union
	: STRUCT 	{$$ = mkleaf($1);}
	| UNION		{$$ = mkleaf($1);}
	;

struct_declaration_list
	: struct_declaration		{$$ = $1;}
	| struct_declaration_list struct_declaration		{$$ = mknode("struct_declaration_list",(char*) NULL, $1, $2);}
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'		{$$ = mknode("struct_declaration",(char*) NULL, $1, $2);}	
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list		{$$ = mknode("specifier_qualifier_list",(char*) NULL, $1, $2);}
	| type_specifier		{$$ = $1;}
	| type_qualifier specifier_qualifier_list		{$$ = mknode("specifier_qualifier_list",(char*) NULL, $1, $2);}
	| type_qualifier		{$$ = $1;}
	;

struct_declarator_list
	: struct_declarator		{$$ = $1;}
	| struct_declarator_list ',' struct_declarator		{$$ = mknode("struct_declarator_list",(char*)NULL, $1, $3);}
	;

struct_declarator
	: declarator		{$$ = $1;}
	| ':' constant_expression		{$$ = $2;}
	| declarator ':' constant_expression		{$$ = mknode("struct_declarator",(char*) NULL, $1, $3);}
	;

enum_specifier
	: ENUM '{' enumerator_list '}'		{$$ = mknode( $1, (char*)NULL, NULL, $3);}
	| ENUM IDENTIFIER '{' enumerator_list '}'	{$$ = mknode($1,(char*) NULL,$2, $4,(char*)NULL);}
	| ENUM IDENTIFIER		{$$ = mknode($1, (char*)NULL, $2,(node*)NULL, (char*)NULL);}
	;

enumerator_list
	: enumerator		{$$ = $1;}
	| enumerator_list ',' enumerator		{$$ = mknode("enumerator_list",(char*) NULL, $1, $3);}
	;

enumerator
	: IDENTIFIER	{$$ = mkleaf($1);}
	| IDENTIFIER '=' constant_expression		{$$ = mknode("=",(char*)NULL, mkleaf($1),  $3);}
	;

type_qualifier
	: CONST		{$$ = mkleaf($1);}
	| VOLATILE		{$$ = mkleaf($1);}
	;

declarator
	: pointer direct_declarator		{$$ = mknode("declarator",(char*) NULL, $1, $2);
									if($2->expr_type==1){$$->node_type=$2->node_type+$1->node_type;
               						$$->node_key = $2->node_key;
               						$$->expr_type=1;}
               						if($2->expr_type==2){ funcName = $2->node_key; funcType = $2->node_type; }   
                					char* a = new char();
                					strcpy(a,($$->node_type).c_str());$$->size = getSize(a);
									}
	| direct_declarator			{$$ = $1;
								if($1->expr_type==2){funcName=$1->node_key; funcType = $1->node_type; } }
	;

direct_declarator
	: IDENTIFIER		{
		$$ = mkleaf($1);
		$$->expr_type=1;
		string str = $1;
		$$->node_key = str;
		$$->node_type=type; 
		char* c = new char();
        strcpy(c,type.c_str()); 
		$$->size = getSize(c);
	}
	| '(' declarator ')'		{
		$$ = $2;
		if($2->expr_type==1){ 
			$$->expr_type=1;
            $$->node_key=$2->node_key;
            $$->node_type=$2->node_type;
		}
	}
	| direct_declarator '[' constant_expression ']'			{
		$$ = mknode("direct_declarator",(char*) NULL, $1, $3);
		if($1->expr_type==1){ 
			$$->expr_type=1;
            $$->node_key=$1->node_key;
            $$->node_type=$1->node_type+string("*");
		}
        if($3->iVal){ 
			$$->size = $1->size * $3->iVal;
		}
        else { 
			char* c = new char();
            strcpy(c,($$->node_type).c_str());
            $$->size = getSize(c); 
		}
	}	
	| direct_declarator '[' ']'		{
		$$ = mknode("direct_declarator", $1,1);
		if($1->expr_type==1){ 
			$$->expr_type=1;
            $$->node_key=$1->node_key;
            $$->node_type=$1->node_type+string("*");
		}   
            char* c = new char();
            strcpy(c,($$->node_type).c_str());
            $$->size = getSize(c);
            strcpy(c,($1->node_type).c_str());
            $$->expr_type=15;
            $$->iVal=getSize(c);
    }
	| direct_declarator '(' M3 parameter_type_list ')'		
	{ 
            $$ = mknode("direct_declarator",(char*) NULL, $1, $4);
          	if($1->expr_type==1){ 
				$$->node_key=$1->node_key;
                $$->expr_type=2;
                $$->node_type=$1->node_type;
                insertFuncArguments($1->node_key,funcArguments);
				string empty = "";
                funcArguments=empty;
			}
            char* c = new char();
            strcpy(c,($$->node_type).c_str());
            $$->size = getSize(c);
            
    }
	| direct_declarator '(' identifier_list ')'		{
		$$ = mknode("direct_declarator",(char*) NULL, $1, $3);
		char* c = new char();
        strcpy(c,($$->node_type).c_str());
        $$->size = getSize(c);
	}
	| direct_declarator '(' M3 ')'		
	{
			$$ = mknode("direct_declarator", $1,0);
          	if($1->expr_type==1){ 
                $$->node_key=$1->node_key;
                insertFuncArguments($1->node_key,string(""));
                $$->expr_type=2;
                string empty = "";
                funcArguments=empty;
            }  
            $$->node_type=$1->node_type;
            char* c = new char();
            strcpy(c,($$->node_type).c_str());
            $$->size = getSize(c);
    } 
	;

M3 
   : %empty                 {   
	   		string empty = "";
	   		type = empty; 
            funcArguments = empty; 
            paramTable();  
		}
    ;
pointer
	: '*'		{$$ = mkleaf($1); $$->node_type="*";}
	| '*' type_qualifier_list		{$$ = mknode("pointer",(char*) NULL, $2, NULL);$$->node_type="*";}
	| '*' pointer		{$$ = mknode("pointer",(char*) NULL, $2, NULL); $$->node_type="*"+$2->node_type;}
	| '*' type_qualifier_list pointer		{$$ = mknode("pointer", (char*)NULL, $2, $3);$$->node_type="*"+$3->node_type;}
	;


type_qualifier_list
	: type_qualifier 	{$$=$1;}
	| type_qualifier_list type_qualifier 	{$$=mknode("type_qualifier_list",(char*)NULL,$1,$2);}
	;


parameter_type_list
	: parameter_list 	{$$=$1;}
	| parameter_list ',' ELLIPSIS 	{
		funcArguments = funcArguments+string(",...");
		$$=mknode("parameter_type_list",(char*)NULL,$1,mkleaf($3));
	}
	;

parameter_list
	: parameter_declaration 	{$$=$1;}
	| parameter_list ',' parameter_declaration 	{$$=mknode("parameter_list",(char*)NULL,$1,$3);}
	;

parameter_declaration
	: declaration_specifiers declarator 	
	 {
		 	string empty = "";
        	type=empty;
         	if($2->expr_type==1){ 
				char *c=new char();
                strcpy(c,($2->node_type).c_str());
                char *key =new char();
                strcpy(key,($2->node_key).c_str());
                if(scopeLookup($2->node_key)){ 
					yyerror("Error: redeclaration of %s",key);
				}
                else {  
					insertSymbol(*curr,key,c,$2->size,0,1);
				}
                if(funcArguments==string(""))
					funcArguments=($2->node_type);
               	else funcArguments= funcArguments+string(",")+($2->node_type);
            } 
            $$=mknode("parameter_declaration",(char*)NULL,$1,$2);
    }
	| declaration_specifiers abstract_declarator 	{$$=mknode("parameter_declaration",(char*)NULL,$1,$2);}
	| declaration_specifiers {$$=$1;}
	;

identifier_list
	: IDENTIFIER 	{$$=mkleaf($1);}
	| identifier_list ',' IDENTIFIER 	{$$=mknode("identifier_list",(char*)NULL,$1,mkleaf($3));}
	;

type_name
	: specifier_qualifier_list 	{$$=$1;}
	| specifier_qualifier_list abstract_declarator 	{$$=mknode("type_name",(char*)NULL,$1,$2);}
	;

abstract_declarator 
	: pointer {$$ = $1;}
	| direct_abstract_declarator 	{$$ = $1;}
	| pointer direct_abstract_declarator 	{$$ = mknode("abstract_declarator", (char*)NULL, $1, $2);}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'   {$$ = $2;}
	| '[' ']'  						{$$ = mkleaf("[ ]");}
	| '[' constant_expression ']' 	{$$ = $2;}
	| direct_abstract_declarator '[' ']'	{$$ = mknode("[ ]",(char*)NULL,$1,NULL);}
	| direct_abstract_declarator '[' constant_expression ']' 	{$$ = mknode("direct_abstract_declarator",(char*)NULL, $1, $3);}
	| '(' ')'	{$$ = mkleaf("( )");}		
	| '(' parameter_type_list ')'	{$$ = $2;}
	| direct_abstract_declarator '(' ')' 	{$$ = mknode("( )",(char*)NULL,$1,NULL);}
	| direct_abstract_declarator '(' parameter_type_list ')'	 {$$ = mknode("direct_abstract_declarator", (char*)NULL, $1, $3);}
	;

initializer
	: assignment_expression 		{$$ = $1;}
	| '{' initializer_list '}' 		{$$ = $2; $$->node_type = $2->node_type+string("*");}
	| '{' initializer_list ',' '}' 		{$$ = mknode( $3,(char*)NULL, $2 ,NULL);$$->node_type = $2->node_type+string("*"); $$->expr_type =$2->expr_type;}
	;


initializer_list
	: initializer 	{$$ = $1; $$->expr_type=1;}
	| initializer_list ',' initializer 	
	{
			$$ = mknode("initializer_list",(char*) NULL, $1 ,$3);          
			$$->node_type = $1->node_type;
           	char* a =validAssign($1->node_type,$3->node_type);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){ ;
                         yyerror("Warning: Assignment with incompatible pointer type"); 
                         }
                     }  
                else{ yyerror("Error: Incompatible types when initializing type \'%s\' to \'%s\' ",($1->node_type).c_str(),($3->node_type).c_str()); }
            $$->expr_type = $1->expr_type+1;
    }       
	;

statement
	: labeled_statement 	{$$ = $1;}
	| compound_statement 	{$$ = $1;}
	| expression_statement 	{$$ = $1;}
	| selection_statement 	{$$ = $1;}
	| iteration_statement 	{$$ = $1;}
	| jump_statement 	{$$ = $1;}
	| declaration_list {$$ = $1;}
	;

labeled_statement
	: IDENTIFIER ':' statement 	{ $$ = mknode("labeled_statement",(char*) NULL, mkleaf($1), $3); }
	| CASE constant_expression ':' statement 	 { $$ = mknode("labeled_statement", mkleaf($1), $2, $4); } 
	| DEFAULT ':' statement	 { $$ = mknode("labeled_statement",(char*) NULL, mkleaf($1), $3); }
	;

compound_statement
	: '{' '}'	 
	{	isFunc=0;	
		$$ = mkleaf("{ }");
	} 
	| M1 statement_list '}'	 
	{	
		if(blockSym){ 
			string str1 = $1;
        	string str2 = str1 + string(".csv");   
            printSymTables(curr,str2);
            updateSymTable(str1); 
			blockSym--; 
        }
		$$ = $2;
	}
	| M1 declaration_list '}'
	{	
		if(blockSym){ 
			string str1 = $1;
        	string str2=str1+string(".csv");   
            printSymTables(curr,str2);
            updateSymTable(str1); 
			blockSym--; 
        }
		$$ = $2;
	}
	| M1 declaration_list statement_list '}'
	{ 
		if(blockSym){ 
			string str1 = $1;
        	string str2=str1+string(".csv");   
            printSymTables(curr,str2);
            updateSymTable(str1); 
			blockSym--; 
        }	
		$$ = mknode("compound_statement", (char*)NULL, $2 , $3);
	}
	;

M1 
    :  '{'       { 		
						if(isFunc==0) {symNumber++;
                        symFileName = funcName+string("Block")+to_string(symNumber);
                        //scope=S_BLOCK;
                        // makeSymTable(symFileName,scope,string("12345"));//change 12345 to flag
                        char* c = new char();
                        strcpy(c,symFileName.c_str());
                        $$ = c;
                        blockSym++;
                        }
                       isFunc=0;
              } 
   
    ;
declaration_list
	: declaration 	{$$ = $1;}
	| declaration_list declaration 	{$$ = mknode("declaration_list", (char*)NULL, $1, $2);}
	;

statement_list
	: statement 	{$$ = $1;}
	| statement_list statement 	{$$ = mknode("statement_list",(char*) NULL, $1, $2);}
	;

expression_statement
	: ';' 	{$$ = mkleaf(";");}
	| expression ';' 	{$$ = $1;}
	;

selection_statement
	: IF '(' expression ')' statement 	{$$ = mknode("IF (expr) stmt", (node*)NULL, $3, $5, (node*)NULL,(node*) NULL);}
	| IF '(' expression ')' statement ELSE statement 	{$$ = mknode("IF (expr) stmt ELSE stmt",(node*) NULL, $3, $5, (node*)NULL, $7); }
	| SWITCH '(' expression ')' statement 	{$$ = mknode("SWITCH (expr) stmt",(node*) NULL, $3, $5,(node*) NULL,(node*) NULL);}
	;

iteration_statement
	: WHILE '(' expression ')' statement 	{$$ = mknode("WHILE (expr) stmt", (node*)NULL, $3, $5, (node*)NULL, (node*)NULL);}
	| DO statement WHILE '(' expression ')' ';' 	{$$ = mknode("DO stmt WHILE (expr)", (node*)NULL, $2, (node*)NULL, $5, (node*)NULL);}
	| FOR '(' expression_statement expression_statement ')' statement 	{$$ = mknode("FOR (expr_stmt expr_stmt) stmt",(node*) NULL, $3, $4, $6, (node*)NULL);}
	| FOR '(' expression_statement expression_statement expression ')' statement 	{$$ = mknode("FOR (expr_stmt expr_stmt expr) stmt",(node*) NULL, $3, $4, $5, $7); }
	;

jump_statement
	: GOTO IDENTIFIER ';' 	
	{ 	
		$$ = mknode("jump_statement",(char*) NULL, mkleaf($1),mkleaf($2)); 
	}
	| CONTINUE ';' 	{ $$ = mkleaf("continue");}
	| BREAK ';' 	{ $$ = mkleaf("break");}
	| RETURN ';' 	{ $$ = mkleaf("return");}
	| RETURN expression ';' 	{ $$ = mknode("jump_statement",(char*) NULL, mkleaf($1),$2);}
	;

translation_unit
	: external_declaration 	{$$ = $1;}
	| translation_unit external_declaration 	{$$ = mknode("translation_unit", (char*)NULL, $1, $2);}
	;

external_declaration
	: function_definition 	
	{
		string empty = "";
		type = empty;
		$$ = $1;
	}
	| declaration 	
	{
		string empty = "";
		type = empty;
		$$ = $1;
	}
	;

function_definition
	: declaration_specifiers declarator M2 declaration_list compound_statement 	
	{		
			string empty = "";
			type = empty;
        	string str1 = $3;
        	string str2 = str1 + string(".csv");
            printSymTables(curr,str2); 
            symNumber=0;
            updateSymTable(str1);
			$$ = mknode("function_definition", $1, $2, $4, $5,(char*) NULL);
	}
	| declaration_specifiers declarator M2 compound_statement 	
	{
			string empty = "";
			type = empty;
        	string str1 = $3;
        	string str2 = str1 + string(".csv");
            printSymTables(curr,str2); 
            symNumber=0;
            updateSymTable(str1);
			$$ = mknode("function_definition", $1, $2, $4);
	}
	| declarator M2 declaration_list compound_statement 	
	{
			string empty = "";
			type = empty;
        	string str1 = $2;
        	string str2 = str1 + string(".csv");
            printSymTables(curr,str2); 
            symNumber=0;
            updateSymTable(str1);
			$$ = mknode("function_definition", (node*)NULL, $1, $3, $4,(char*) NULL);
	}
	| declarator M2 compound_statement			
	{
			string empty = "";
			type = empty;
        	string str1 = $2;
        	string str2 = str1 + string(".csv");
            printSymTables(curr,str2); 
            symNumber=0;
            updateSymTable(str1);
			$$ = mknode("function_definition",(node*)NULL, $1, $3);
	}
	;


M2 
    : %empty                
	{ 
				string empty = "";
				type = empty;
				scope = S_FUNC;
                isFunc = 1;
                funcSym++;
            	symFileName = funcName;
				cout<<funcName<<endl;
				cout<<funcType<<endl;
                makeSymTable(symFileName,scope,funcType);
                char* c= new char();
                strcpy(c,symFileName.c_str());
                $$ = c;
       }
    ;

%%
#include <stdio.h>

extern char yytext[];
extern int column;

extern FILE *yyin;

int  main(int argc,char **argv){
	int val;
	if(argc <= 2){
		printf("Usage : ./bin/parser ./test/test1.c -o graph.gv \n");
	}else{
		if(!strcmp(argv[argc-2],"-o")){ 
			if (!(digraph = fopen(argv[argc-1], "w"))){
				perror("Error: ");
				return -1;
			}
		}
		if (!(yyin = fopen(argv[1], "r"))){
			perror("Error: ");
			return -1;
		}
		funcName = string("GST");
		stInitialize();
		graphStart();
		int k = yyparse();
		if(k==0) graphEnd();
		symFileName = "GST.csv";
		printSymTables(curr,symFileName);
		printFuncArguments();
	}
	return 0;
}



void yyerror(char *s,...){
  va_list args;
  char buffer[MAX_STR_LEN];

  va_start(args,s);
  vsnprintf(buffer,MAX_STR_LEN-1,s,args);
  va_end(args);

  
  int count = 1;
  if(s=="syntax error") count = 2;
  fprintf(stderr,"%s : %d :: %s\n",filename,yylineno,buffer);
  duplicate=fopen("duplicate.txt","r");
  if ( duplicate != NULL )
  {
    char line[256]; /* or other suitable maximum line size */
    while (fgets(line, sizeof line, duplicate) != NULL) /* read a line */
    {
        if (count == yylineno)
        {
            fprintf(stderr,"\t%s\n",line);
            break;
        }
        else
        {
            count++;
        }
    }
    fclose(duplicate);
  }
  
}

