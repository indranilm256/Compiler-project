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

#include "type_check.h"
#include "nodes.h"

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
int tempodd, tempeven;
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

%type <ptr> primary_expression postfix_expression unary_expression cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression conditional_expression constant_expression expression assignment_expression
%type <ptr> argument_expression_list type_name initializer_list
%type <ptr> unary_operator
%type <ptr> declaration declaration_specifiers
%type <ptr> init_declarator_list type_specifier type_qualifier storage_class_specifier
%type <ptr> init_declarator  declarator struct_or_union_specifier struct_or_union enum_specifier initializer struct_block_item_list
%type <ptr> struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator enumerator_list enumerator pointer 
%type <ptr> direct_declarator type_qualifier_list parameter_type_list  parameter_list parameter_declaration identifier_list
%type <ptr> abstract_declarator direct_abstract_declarator labeled_statement compound_statement expression_statement block_item_list declaration_list
%type <ptr> selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition statement block_item 
%type <str> M1 M2 M3
%type <number> M N GOTO_emit
%type <ptr> M11 M21 M31 M4 M5 M6 M7
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
									//-----------3AC----------------------//
                                         $$->place = pair<string,sEntry*>(key,lookup(key));
                                         $$->nextlist= {};
                                    //----------------3AC--------------------//
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
							 //-----------3AC----------------------//
                                $$->place = pair<string,sEntry*>($1->str,NULL);
                                $$->nextlist={};
                             //----------------3AC--------------------//
							
							}	
	| STRING_LITERAL		{
							$$ = mkleaf($1);
							string type = "char*";
							$$->node_type = type;
							$$->is_init = 1;
							//---------------3AC-------------------------------//
                                  $$->place = pair<string,sEntry*>($1,NULL);
                                    $$->nextlist={};
                            //--------------3AC------------------------------------//
							}	
	| '(' expression ')'	{$$ = $2;}	
	;

postfix_expression
	: primary_expression	{$$ = $1;}
	| postfix_expression '[' expression ']'		{$$ = mknode("postfix_expression[expression]",(char*) NULL, $1, $3);
												if($1->is_init && $3->is_init){$$->is_init = 1;}
												char* a = postfixExpr($1->node_type, 1);
												if(!isInt($3->node_type)){yyerror("Error: Array Index should be of type 'int' not '%s' ",$3->node_type.c_str());}
												if(a){
													string s = a;
													$$->node_type = s;
													//---------------3AC-------------------------------//
                                                 $$->place = getTmpSym($$->node_type);
                                                 //qid opT  = pair<string,sEntry*>("[]",NULL);
                                                 // int k = emit(opT, $1->place, $3->place, $$->place, -1);
                                                 $$->place.second->size = $3->place.second->offset;
                                                 $$->place.second->offset = $1->place.second->offset;
                                                 $$->place.second->is_init = -5;

                                                 $$->nextlist = {};
                                                 //backPatch($3->truelist, k);
                                                 //backPatch($3->falselist, k);
                                               //----------------3AC------------------------------------//
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
													  //----------------------------3AC-------------------------------------------------//
													qid t = getTmpSym($$->node_type);
													int k=emit(pair<string, sEntry*>("refParam", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), t, -1);
													int k1=emit(pair<string, sEntry*>("CALL", NULL), $1->place, pair<string, sEntry*>("1", NULL), t, -1);
													$$->nextlist ={};
													$$->place = t;
                    								 //-------------------------3AC---------------------------------------//
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
																		int f=1;
																		if($1->node_key == "printf"){f = 0;}
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
																			if(b){
																				if(!strcmp(b,"warning")){
																					yyerror("Warning: Passing argument %d of \'%s\' from incompatible pointer type.\n Note : expected \'%s\' but argument is of type \'%s\'\n     \'%s %s %s \'",argnum,($1->node_key).c_str(),B.c_str(),A.c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
																					}
																				}
																			else{
																				yyerror("Error: Incompatible type for argument %d of \'%s\'.\n Note: expected \'%s\' but argument is of type \'%s\' \n        \'%s %s %s \'",argnum,($1->node_key).c_str(),B.c_str(),A.c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
																				} 
																			if(f1 != -1 && f2 != -1){continue;}
																			else if(f2 != -1){
																				if(!(tmp2==string("..."))) yyerror("Error: Too few arguments for the function %s\n    %s %s %s ",($1->node_key).c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
                                 												break;
																			}else if(f1 != -1){
																				yyerror("Error: Too many arguments for the function %s\n    %s %s %s ",($1->node_key).c_str(),($$->node_type).c_str(),($1->node_key).c_str(),funcArgs.c_str());
                                   												break;
																			}else{break;}
																			}
																			//--------------------------3AC----------------------------------//
																			unsigned fT=1;
																			unsigned carg=1;
																			while(fT!=-1){
																					carg++;
																					fT = currArguments.find_first_of(string(","));
																					if(fT==-1) A= currArguments; else{ A= currArguments.substr(0,fT); currArguments = currArguments.substr(fT+1);}

																			}
																			qid t = getTmpSym($$->node_type);
																			emit(pair<string, sEntry*>("refParam", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), t, -1);
																			int k=emit(pair<string, sEntry*>("CALL", NULL), $1->place, pair<string, sEntry*>(to_string(carg), NULL), t, -1);
																			$$->place = t;
																			$$->nextlist ={};
																			//----------------------------3AC-----------------------------------------//
																		
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
												 //------------------3AC------------//
												qid t1 = getTmpSym($$->node_type);
												int k=  emit(pair<string, sEntry*>("++S", lookup("++")), $1->place, pair<string, sEntry*>("", NULL), t1, -1);
												$$->place = t1;
												$$->nextlist = {};
												//-----------------3AC-----------------//
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
												//-----------------3AC-------------//
												qid t1 = getTmpSym($$->node_type);
												int k=emit(pair<string, sEntry*>("--S", lookup("--")), $1->place, pair<string, sEntry*>("", NULL), t1, -1);
												$$->place = t1;
												$$->nextlist={};
                  								//--------------3AC-------------//
											}else{
												yyerror("Error: Decrement not defined for this type");
											}
											}
	;

argument_expression_list
	: assignment_expression		{$$ = $1;
								if($1->is_init) $$->is_init = 1;
								currArguments = $1->node_type;
								 //----------------3AC------------//
								if($$->place.second == NULL && $$->node_type == "char*"){
								int k=emit(pair<string, sEntry*>("param", NULL), $$->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -4);
								}
								else int k=emit(pair<string, sEntry*>("param", NULL), $$->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
								$$->nextlist={};
                				//---------------3AC------------//
								}
	| argument_expression_list ',' assignment_expression		{$$ = mknode("assignment_expression_list",$2,$1,$3);
																char* a = argumentExpr($1->node_type, $3->node_type);
																string s = a;
																$$->node_type = s;	
																
																currArguments = currArguments + "," + $3->node_type;
																//-------3AC-------------//
																if($3->place.second == NULL && $3->node_type == "char*"){
																	int k=emit(pair<string, sEntry*>("param", NULL), $3->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -4);
																}
																else int k=emit(pair<string, sEntry*>("param", NULL), $3->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
																$$->nextlist={};
																//------3AC--------------//
																}
	;

unary_expression
	: postfix_expression		{$$ = $1;} 
	| INC_OP unary_expression	{$$=  mknode($1,(char*) NULL, (node*)NULL, $2);
								if($2->is_init) $$->is_init = 1;
								char* a = postfixExpr($2->node_type, 6);
								string s = a;
								if(a){
									$$->node_type = s;
									 //===========3AC======================//
									qid t1 = getTmpSym($$->node_type);
									int k = emit(pair<string, sEntry*>("++P", lookup("++")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
									$$->place = t1;
									$$->nextlist = {};
								    //$$->code =  $2->code + '\n' +\
									//$$->node_key + string("= ") + "INC_OP" + string(" ") + $2->node_key;
                  					//====================================//
								}else{yyerror("Error: Increment not defined for this type");}
								}
	| DEC_OP unary_expression	{$$=  mknode($1,(char*) NULL, (node*)NULL, $2); 
								if($2->is_init) $$->is_init = 1;
								char* a = postfixExpr($2->node_type, 6);
								string s = a;
								if(a){
									$$->node_type = s;
									 //===========3AC======================//
									qid t1 = getTmpSym($$->node_type);
									int k = emit(pair<string, sEntry*>("--P", lookup("--")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
									$$->place = t1;
									$$->nextlist={};
                  					//====================================//
								}else{yyerror("Error: Increment not defined for this type");}
								}
	| unary_operator cast_expression	{$$ = mknode("unary_expression", (char*)NULL, $1, $2);
										if($2->is_init) $$->is_init = 1;
										char* a = unaryExpr($1->node_name, $2->node_type);
										string s = a;
										if(a){
											$$->node_type = s;
											//===========3AC======================//
											qid t1 = getTmpSym($$->node_type);
											int k = emit($1->place, $2->place, pair<string, sEntry*>("", NULL), t1, -1);
											$$->place = t1;
											$$->nextlist={};

                  							//====================================//
										}
										else  yyerror("Error: Type inconsistent with operator %s", $1->node_name.c_str());
										}
	| SIZEOF unary_expression		{$$=  mknode($1, (char*)NULL, (node*)NULL, $2); 
									$$->node_type = "int";
									$$->is_init = 1;
									//===========3AC======================//
									qid t1 = getTmpSym($$->node_type);
									int k = emit(pair<string, sEntry*>("SIZEOF", lookup("sizeof")), $2->place, pair<string, sEntry*>("", NULL), t1, -1);
									$$->place = t1;
									$$->nextlist={};
                					//====================================//
									}
	| SIZEOF '(' type_name ')'		{$$ = mknode($1, (char*)NULL, (node*)NULL, $3);
									$$->node_type = "int";
									$$->is_init = 1;
									//===========3AC======================//
									qid t1 = getTmpSym($$->node_type);
									int k = emit(pair<string, sEntry*>("SIZEOF", lookup("sizeof")), $3->place, pair<string, sEntry*>("", NULL), t1, -1);
									$$->place = t1;
									$$->nextlist={};
                					//====================================//
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
											//=============3AC====================//
											qid t1 = getTmpSym($$->node_type);
											string t = $4->node_type+ "to" + $$->node_type ;
											int k = emit(pair<string, sEntry*>(t, NULL), $4->place, pair<string, sEntry*>(",", NULL), t1, -1);
											$$->nextlist={};
											$$->place = t1;
                       						//====================================//
											}
	;

multiplicative_expression
	: cast_expression		{$$ = $1;}
	| multiplicative_expression '*' cast_expression		{
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '*');
														if(a){
																int k;
																if(!strcmp(a,"int")){
																	$$ = mknode("*int",(char*)NULL,$1,$3); $$->node_type = "long long";
																	//---------------3AC----------------//
																	qid t1 = getTmpSym($$->node_type);
																	k=emit(pair<string, sEntry*>("*int", lookup("*")), $1->place, $3->place, t1, -1);
																	$$->place = t1;
																	$$->nextlist={};
                												//--------------3AC--------------------//
																}
																else if(!strcmp(a,"float")){
																	$$ = mknode("*float",(char*)NULL,$1,$3); $$->node_type = "long double";
																	//-------------3AC---------------------//
																	qid t1 = getTmpSym($$->node_type);

																	if(isInt($1->node_type)){
																			qid t2 = getTmpSym($$->node_type);
																			emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
																			k=emit(pair<string, sEntry*>("*real", lookup("*")), t2, $3->place, t1, -1);
																	}
																	else if(isInt($3->node_type)){
																			qid t2 = getTmpSym($$->node_type);
																			emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
																			k=emit(pair<string, sEntry*>("*real", lookup("*")), $1->place, t2, t1, -1);
																	}
																	else {

																			k=emit(pair<string, sEntry*>("*real", lookup("*")), $1->place, $3->place, t1, -1);
																	}
																	$$->place = t1;
																	$$->nextlist={};
                													//------------3AC-----------------------------//
																}
																
															}
														else{
															$$ = mknode($2,(char*)NULL,$1,$3);
															yyerror("Error: Incompatible type of * operator");
														}
														if($1->is_init && $3->is_init) $$->is_init = 1;
														}
	| multiplicative_expression '/' cast_expression		{
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '/');
														if(a){
																int k;
																if(!strcmp(a,"int")){
																	$$ = mknode("*int",(char*)NULL,$1,$3); $$->node_type = "long long";
																	//---------------3AC----------------------//
																	qid t1 = getTmpSym($$->node_type);
																	k = emit(pair<string, sEntry*>("/int", lookup("/")), $1->place, $3->place, t1, -1);
																	$$->place = t1;
																	$$->nextlist= {};
                 													//--------------3AC------------------------//
																}
																else if(!strcmp(a,"float")){
																	$$ = mknode("*float",(char*)NULL,$1,$3); $$->node_type = "long double";
																	//-------------3AC---------------------//
																	qid t1 = getTmpSym($$->node_type);

																	if(isInt($1->node_type)){
																			qid t2 = getTmpSym($$->node_type);
																			emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
																			k=emit(pair<string, sEntry*>("/real", lookup("/")), t2, $3->place, t1, -1);
																	}
																	else if(isInt($3->node_type)){
																			qid t2 = getTmpSym($$->node_type);
																			emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
																			k=emit(pair<string, sEntry*>("/real", lookup("/")), $1->place, t2, t1, -1);
																	}
																	else {
																			k=emit(pair<string, sEntry*>("/real", lookup("/")), $1->place, $3->place, t1, -1);
																	}
																	$$->place =t1;
																	$$->nextlist={};
																	//-------------------------------------------//
																}
															}
														else{
															$$ = mknode($2,(char*)NULL,$1,$3);
															yyerror("Error: Incompatible type of * operator");
														}
														if($1->is_init && $3->is_init) $$->is_init = 1;
														}
	| multiplicative_expression '%' cast_expression		{
														$$ = mknode($2,(char*)NULL,$1,$3);
														if($1->is_init && $3->is_init) $$->is_init = 1;
														char* a = multiplicativeExpr($1->node_type, $3->node_type, '%');
														if(a){
															$$->node_type = "long long";
															//===========3AC======================//
															qid t1 = getTmpSym($$->node_type);
															int k =emit(pair<string, sEntry*>("%", lookup("%")), $1->place, $3->place, t1, -1);
															$$->nextlist={};
															$$->place = t1;

                 											 //====================================//
														}
														else{ 
															yyerror("Error: Incompatible type of % operator");
														}
														}
	;

additive_expression
	: multiplicative_expression		{$$ = $1;}
	| additive_expression '+' multiplicative_expression		{
															char* a = additiveExpr($1->node_type,$3->node_type,'+');
															char* q = new char();
															string p;
															if(a){
																string s = a;
																 p = string("+ ") + s;
																strcpy(q,p.c_str());
															}else{ q = "+";}
															$$ = mknode(q,(char*)NULL,$1,$3);
															if(a){ 
																string  s = a;
																if(!strcmp(a,"int")) {$$->node_type=string("long long");}
																else if(!strcmp(a,"float")) {$$->node_type=string("long double");}
																else{$$->node_type = s;}
																//===========3AC======================//
																qid t1 = getTmpSym($$->node_type);
																if(isInt($1->node_type) && isFloat($3->node_type)){
																		qid t2 = getTmpSym($$->node_type);
																		emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
																		emit(pair<string, sEntry*>(p, lookup("+")), t2, $3->place, t1, -1);
																}
																else if(isInt($3->node_type) && isFloat($1->node_type)){
																		qid t2 = getTmpSym($$->node_type);
																		emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
																		emit(pair<string, sEntry*>(p, lookup("+")), $1->place, t2, t1, -1);
																}
																else {
																		emit(pair<string, sEntry*>(p, lookup("+")), $1->place, $3->place, t1, -1);
																}
																$$->place = t1;
																$$->nextlist = {};
                  												//====================================//
															}else {
																yyerror("Error: Incompatible type for + operator");
															} 
															if($1->is_init && $3->is_init) $$->is_init = 1;
															}			
	| additive_expression '-' multiplicative_expression		{
															char* a = additiveExpr($1->node_type,$3->node_type,'-');
															char* q = new char();
															string p;
															if(a){string s = a;
															p = string("- ") + s;
															strcpy(q,p.c_str());
															}else{ q = "-";}
															$$ = mknode(q,(char*)NULL,$1,$3);
															if(a){ 
																string s = a;
																if(!strcmp(a,"int")) {$$->node_type=string("long long");}
																else if(!strcmp(a,"float")) {$$->node_type=string("long double");}
																else{$$->node_type = s;}
																//===========3AC======================//
																qid t1 = getTmpSym($$->node_type);
																if(isInt($1->node_type) && isFloat($3->node_type)){
																		qid t2 = getTmpSym($$->node_type);
																		emit(pair<string, sEntry*>("inttoreal",NULL),$1->place,pair<string, sEntry*>("",NULL),t2,-1);
																		emit(pair<string, sEntry*>(p, lookup("-")), t2, $3->place, t1, -1);
																}
																else if(isInt($3->node_type) && isFloat($1->node_type)){
																		qid t2 = getTmpSym($$->node_type);
																		emit(pair<string, sEntry*>("inttoreal",NULL),$3->place,pair<string, sEntry*>("",NULL),t2,-1);
																		emit(pair<string, sEntry*>(p, lookup("-")), $1->place, t2, t1, -1);
																}
																else {
																		emit(pair<string, sEntry*>(p, lookup("-")), $1->place, $3->place, t1, -1);
																}
																$$->place = t1;
																$$->nextlist = {};
																//====================================//
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
														if(a){
															$$->node_type = $1->node_type;
															 //===========3AC======================//
															qid t1 = getTmpSym($$->node_type);
															int k = emit(pair<string, sEntry*>("LEFT_OP", lookup("<<")), $1->place, $3->place, t1, -1);
															$$->place = t1;
															$$->nextlist={};
                        									//====================================//
														}
														else{yyerror("Error: Invalid operands to binary <<");}
                           								}
	| shift_expression RIGHT_OP additive_expression		{$$ = mknode($2,(char*)NULL,$1,$3);
														char* a = shiftExpr($1->node_type,$3->node_type);                        
														if(a){
															$$->node_type = $1->node_type;
															//===========3AC======================//
															qid t1 = getTmpSym($$->node_type);
															int k = emit(pair<string, sEntry*>("RIGHT_OP", lookup(">>")), $1->place, $3->place, t1, -1);
															$$->place = t1;
															$$->nextlist={};
															//====================================//
														}else{yyerror("Error: Invalid operands to binary <<");}
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
															//===========3AC======================//
																qid t1 = getTmpSym($$->node_type);
																int k =  emit(pair<string, sEntry*>("<", lookup("<")), $1->place, $3->place, t1, -1);
																$$->place = t1;
																$$->nextlist={};
															//====================================//
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
				 //===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k = emit(pair<string, sEntry*>(">", lookup(">")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                //====================================//
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
					  //===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                          int k= emit(pair<string, sEntry*>("LE_OP", lookup("<=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                     //====================================//
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
					//===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k = emit(pair<string, sEntry*>("GE_OP", lookup(">=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist ={};
                    //====================================//
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
				 //===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k = emit(pair<string, sEntry*>("EQ_OP", lookup("\=\=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist = {};
                //====================================//
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
				//===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k = emit(pair<string, sEntry*>("NE_OP", lookup("!=")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist ={};
                //====================================//
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
			  //===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k= emit(pair<string, sEntry*>("&", lookup("&")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
             //====================================//
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
			//===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k = emit(pair<string, sEntry*>("^", lookup("^")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
            //====================================//
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
				 //===========3AC======================//
                           qid t1 = getTmpSym($$->node_type);
                           int k =  emit(pair<string, sEntry*>("|", lookup("|")), $1->place, $3->place, t1, -1);
                           $$->place = t1;
                           $$->nextlist={};
                //====================================//
            }
        	else {
                yyerror("Error:Invalid operands to the binary |");
            }
        	if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
	}
	;
	
M11
  : logical_and_expression AND_OP {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;



logical_and_expression
	: inclusive_or_expression		{$$ = $1;}
	| M11 M inclusive_or_expression			
	{
        $$ = mknode("&&",(char*)NULL,$1,$3);
		$$->node_type == string("bool");
		 //===========3AC======================//
		if($3->truelist.begin()==$3->truelist.end()){
			int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $3->place, pair<string, sEntry*>("", NULL ),0);
			int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
			$3->truelist.push_back(k);
			$3->falselist.push_back(k1);
	}
		backPatch($1->truelist,$2);
		$$->truelist = $3->truelist;
		$1->falselist.merge($3->falselist);
		$$->falselist = $1->falselist;
		$$->nextlist ={};
	//====================================//
    	if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
    }
	;
	M21
  : logical_or_expression OR_OP {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

logical_or_expression
	: logical_and_expression		{$$ = $1;}
	| M21 M logical_and_expression		
	{
        $$ = mknode("||",(char*)NULL,$1,$3);                        
        if($1->is_init==1 && $3->is_init==3) $$->is_init=1;
        $$->node_type == string("bool");
    }
	;
M31
  : logical_or_expression '?' {
                        if($1->truelist.begin()==$1->truelist.end()){
                            int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
                            int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                            $1->truelist.push_back(k);
                            $1->falselist.push_back(k1);

                        }
                        $$ = $1;
  }
  ;

N
 : %empty {
                emit(pair<string, sEntry*>("=", lookup("=")), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), -1);
                $$ = emit(pair<string, sEntry*>("GOTO", lookup("goto")), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), 0);
 }
 ;

conditional_expression
	: logical_or_expression			{$$ = $1;}
	| M31 M expression':' N conditional_expression		
	{
		//printf("line 526");
		$$ = mknode("?",(char*)NULL,$3,$6);
		char* c = conditionalExpr($3->node_type,$6->node_type);
		if(c){
			string str = c;
			$$->node_type = str;
		}
		else{
			yyerror("Error:Type mismatch in conditional expression");
		}
		if($1->is_init==1 && $3->is_init==3 && $6->is_init) $$->is_init=1;
    }
	;

assignment_expression
	: conditional_expression		{$$ = $1;}
	| unary_expression assignment_operator assignment_expression		
	{ 
		
		$$ = mknode($2,(char*)NULL,$1,$3);
		

    	char* c = assignmentExpr($1->node_type,$3->node_type,$2);
	
        if(c){

            if(!strcmp(c,"true")){ $$->node_type = $1->node_type; }
			if(!strcmp(c,"Warning")){
			
				 yyerror("Warning: Incompatible types when assigning type \'%s\' to \'%s\' ",($3->node_type).c_str(),($1->node_type).c_str());
			}
            if(!strcmp(c,"warning")){ 
				$$->node_type = $1->node_type;
                yyerror("Warning: Assignment with incompatible pointer type"); 
            }
			//-------------3AC------------------------------------//
                      int k;
		     if(!strcmp($2,"=") || !strcmp($2,"+=") || !strcmp($2,"-=") || !strcmp($2,"*=") || !strcmp($2,"/=")) k= assignmentExpression($2, $$->node_type,$1->node_type, $3->node_type, $1->place, $3->place)	;
		     else assignment2($2, $$->node_type,$1->node_type, $3->node_type, $1->place, $3->place);
                       $$->place = $1->place;

                      backPatch($3->nextlist, k);
                       
                      
            //-------------------------------------------------------//
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
	| expression ',' M assignment_expression		{
		$$ = mknode("expression",(char*) NULL, $1, $4);
		$$->node_type = string("void");
		//--------------3AC--------------------//
                 backPatch($1->nextlist,$3);
                 $$->nextlist = $4->nextlist;
        //-------------------------------------//
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
	| init_declarator_list ',' M init_declarator	{
													$$ = mknode("init_declarator_list",(char*) NULL, $1, $4);
													//-----------3AC------------------//
													backPatch($1->nextlist, $3);
													$$->nextlist = $4->nextlist;
													//--------------------------------//
												}
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
	| declarator '=' M initializer		{
		char * k = NULL;
		$$ = mknode("=",k, $1, $4);
		
		if($1->expr_type==1){ 
			char *t=new char();
            strcpy(t,($1->node_type).c_str());
            char *key =new char();
            strcpy(key,($1->node_key).c_str());
			
			//cout << flag<<endl;
            if(scopeLookup($1->node_key)){ 
                yyerror("Error: redeclaration of \'%s\'",key);
            }else if($1->node_type==string("void")){
				yyerror("Error: Variable or field \'%s\' declared void",key);
            }else if((($1->node_type) == "char*" && ($4->node_type)!= "char*") || (($1->node_type) != "char*" && ($4->node_type) == "char*") ){
				yyerror("Error: Type Mismatch: %s is  being assigned to %s", ($1->node_type).c_str(), ($4->node_type).c_str());	
			}
			else { 
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
					if(type==string(""))type = "void";
                	else type = type+string(" ")+"void";
                	$$=mkleaf($1);
              	}
				  
  	| CHAR     {    
		  			if(type==string(""))type = "char";
                   	else type = type+string(" ")+"char";
                  	$$=mkleaf($1);
				    
					 
              	}
  	| SHORT     {     
		  			if(type==string(""))type = "short";
                   	else type = type+string(" ")+"short";
                  	$$=mkleaf($1);
              	}
  	| INT       {    // printf("ddsd");
		  			if(type==string(""))type = "int";
                   	else type = type+string(" ")+"int";
                  	$$=mkleaf($1);
					  
              	}
  	| LONG      {     
		  			if(type==string(""))type = "long";
                   	else type = type+string(" ")+"long";
                  	$$=mkleaf($1);
              	}
  	| FLOAT     {     
		  			if(type==string(""))type = "float";
                   	else type = type+string(" ")+"float";
                  	$$=mkleaf($1);
              	}
  	| DOUBLE    {     
		  			if(type==string(""))type = "double";
                   	else type = type+string(" ")+"double";
                  	$$=mkleaf($1);
              	}
  	| SIGNED    {     
		  			if(type==string(""))type = "signed";
                   	else type = type+string(" ")+"signed";
                  	$$=mkleaf($1);
              	}
  	| UNSIGNED  {     
		  			if(type==string(""))type = "unsigned";
                   	else type = type+string(" ")+"unsigned";
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
	: struct_or_union IDENTIFIER '{' struct_block_item_list '}'		{$$ = mknode($2,(char*) NULL, $1, $4);}
	| struct_or_union '{' struct_block_item_list '}'		{$$ = mknode("struct_or_union_specifier",(char*) NULL, $1, $3);}
	| struct_or_union IDENTIFIER		{$$ = mknode($2,(char*) NULL,$1, NULL);}
	;
	
struct_or_union
	: STRUCT 	{$$ = mkleaf($1);}
	| UNION		{$$ = mkleaf($1);}
	;

struct_block_item_list
	: struct_declaration		{$$ = $1;}
	| struct_block_item_list struct_declaration		{$$ = mknode("struct_block_item_list",(char*) NULL, $1, $2);}
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
									 //------------------3AC---------------------------------//
                       				 $$->place = pair<string, sEntry*>($$->node_key, NULL);
                        			//-------------------------------------------------------//
									}
	| direct_declarator			{$$ = $1;
								if($1->expr_type==2){funcName=$1->node_key; funcType = $1->node_type; } 
								  //------------------3AC---------------------------------//
									$$->place = pair<string, sEntry*>($$->node_key, NULL);
								  //-------------------------------------------------------//
								}
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
		//------------------3AC---------------------------------//
		$$->place = pair<string, sEntry*>($$->node_key, NULL);
		//-------------------------------------------------------//
	}
	| '(' declarator ')'		{
		$$ = $2;
		if($2->expr_type==1){ 
			$$->expr_type=1;
            $$->node_key=$2->node_key;
			 //------------------3AC---------------------------------//
			$$->place = pair<string, sEntry*>($$->node_key, NULL);
		    //-------------------------------------------------------//
            $$->node_type=$2->node_type;
		}
	}
	| direct_declarator '[' constant_expression ']'			{/////////////////huuuuuuuuuuuuuuuuuu////////////////////
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
			 //------------------3AC---------------------------------//
			$$->place = pair<string, sEntry*>($$->node_key, NULL);
			//-------------------------------------------------------//      
    }
	| direct_declarator '(' M3 parameter_type_list ')' M		
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
			//------------------3AC---------------------------------//
			$$->place = pair<string, sEntry*>($$->node_key, NULL);
			backPatch($4->nextlist, $6);
			if( !(($$->node_key == "odd" && tempodd == 0) || ($$->node_key == "even" && tempeven == 0)) ){string em =  "func " + $$->node_key+ " begin:";
			emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);}
			if($$->node_key == "odd" ){
				tempodd = 1;
			}
			if($$->node_key == "even" ){
				tempeven = 1;
			}
            //-------------------------------------------------------//
            
    }
	| direct_declarator '(' M3 identifier_list ')'		{
		$$ = mknode("direct_declarator",(char*) NULL, $1, $4);
		char* c = new char();
        strcpy(c,($$->node_type).c_str());
        $$->size = getSize(c);
			//------------------3AC---------------------------------//
			$$->place = pair<string, sEntry*>($$->node_key, NULL);
			string em =  "func " + $$->node_key+ " begin:";
			emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);
			//-------------------------------------------------------//
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
			 //------------------3AC---------------------------------//
			$$->place = pair<string, sEntry*>($$->node_key, NULL);
			string em =  "func " + $$->node_key+ " begin:";
			emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-2);
			//-------------------------------------------------------//
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
	| parameter_list ',' M parameter_declaration 	{$$=mknode("parameter_list",(char*)NULL,$1,$4);
													//----------------3AC--------------//
                                                       backPatch($1->nextlist,$3);
                                                       $$->nextlist=$4->nextlist;
                                                      //---------------------------------//
                                              }
							
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
	| '{' initializer_list ',' '}' 		{ $$ = mknode( $3,(char*)NULL, $2 ,NULL);$$->node_type = $2->node_type+string("*"); $$->expr_type =$2->expr_type;
										//--------------3AC--------------------//
										$$->place = $2->place;
										$$->nextlist = $2->nextlist;
										//-------------------------------------//
										}
	;


initializer_list
	: initializer 	{$$ = $1; $$->expr_type=1;}
	| initializer_list ',' M initializer 	
	{
			$$ = mknode("initializer_list",(char*) NULL, $1 ,$4);          
			$$->node_type = $1->node_type;
           	char* a =validAssign($1->node_type,$4->node_type);
               if(a){
                    if(!strcmp(a,"true")){ ; }
                    if(!strcmp(a,"warning")){ ;
                         yyerror("Warning: Assignment with incompatible pointer type"); 
                         }
                     }  
                else{ yyerror("Error: Incompatible types when initializing type \'%s\' to \'%s\' ",($1->node_type).c_str(),($4->node_type).c_str()); }
            $$->expr_type = $1->expr_type+1;
			//--------------3AC--------------------//
			backPatch($1->nextlist, $3);
			$$->nextlist = $4->nextlist;
			//-------------------------------------//
    }       
	;

statement
	: labeled_statement 	{$$ = $1;}
	| compound_statement 	{$$ = $1;}
	| expression_statement 	{$$ = $1;}
	| selection_statement 	{$$ = $1;}
	| iteration_statement 	{$$ = $1;}
	| jump_statement 	{$$ = $1;}
	//| block_item_list {$$ = $1;}
	;

labeled_statement
	: IDENTIFIER ':' M statement 	{
			$$ = mknode("labeled_statement",(char*) NULL, mkleaf($1), $4); 

									//===========3AC======================//

									if(!gotoIndexStorage($1, $3)){
										yyerror("ERROR:\'%s\' is already defined", $1);

									} 
									 $$->nextlist = $4->nextlist;
									$$->caselist = $4->caselist;
									$$->continuelist = $4->continuelist;
									$$->breaklist = $4->breaklist;
									//=====================================//
									
									}
	| M5 M statement 	 { $$ = mknode("labeled_statement", mkleaf("case"), $1, $3); 
							//-----------3AC--------------------//
                                  backPatch($1->truelist, $2);
                                  $3->nextlist.merge($1->falselist);
                                  $$->breaklist = $3->breaklist;
                                  $$->nextlist = $3->nextlist;
                                  $$->caselist = $1->caselist;
                                  $$->continuelist=$3->continuelist;
                               //-----------------------------------//
							} 
	| DEFAULT ':' statement	 { $$ = mknode("labeled_statement",(char*) NULL, mkleaf($1), $3); 
								//---------3AC-----------------------//
                                 $$->breaklist= $3->breaklist;
                                 $$->nextlist = $3->nextlist;
                                 $$->continuelist=$3->continuelist;
                               //----------------------------------//
							}
	;





compound_statement
	: '{' '}'   {isFunc=0;$$ = mkleaf("{ }"); $$->rVal = -5;}
	| M1  block_item_list '}'  {if(blockSym){ string s($1);
                                    s=s+string(".csv");
                                    string u($1);
                                    printSymTables(curr,s);
                                    updateSymTable(u); blockSym--;
                                 } $$ = $2;
                               }
	;


block_item_list
	: block_item  {$$ = $1;}
	| block_item_list M block_item  {$$ = mknode("block_item_list", (char*)NULL, $1, $3);
									//---------------3AC--------------------//
									backPatch($1->nextlist, $2);
									$$->nextlist = $3->nextlist;
									$1->caselist.merge($3->caselist);
									$$->caselist = $1->caselist;
									$1->continuelist.merge($3->continuelist);
									$1->breaklist.merge($3->breaklist);
									$$->continuelist = $1->continuelist;
									$$->breaklist = $1->breaklist;
									//----------------------------------------//
									}
	;

block_item
	: declaration {$$ = $1;}
	| statement {$$ = $1;}
	;

declaration_list
	: declaration 	{$$ = $1;}
	| declaration_list declaration 	{ $$ = mknode("declaration_list", (char*)NULL, $1, $2);}
	;


expression_statement
	: ';' 	{$$ = mkleaf(";");}
	| expression ';' 	{$$ = $1;}
	;

selection_statement
	: M4 M statement 	{$$ = mknode("IF (expr) stmt", (node*)NULL, $1, $3, (node*)NULL,(node*) NULL);
						//---------------3AC-------------------//
							backPatch($1->truelist, $2);
							$3->nextlist.merge($1->falselist);
							$$->nextlist= $3->nextlist;
							$$->continuelist = $3->continuelist;
							$$->breaklist = $3->breaklist;
						//------------------------------------//
						}
	| M4 M statement GOTO_emit ELSE M statement 	{$$ = mknode("IF (expr) stmt ELSE stmt",(node*) NULL, $1, $3, (node*)NULL, $7); 
													//----------3AC---------------------//
													backPatch($1->truelist, $2);
													backPatch($1->falselist, $6);
													$3->nextlist.push_back($4);
													$3->nextlist.merge($7->nextlist);
													$$->nextlist=$3->nextlist;
													$3->breaklist.merge($7->breaklist);
													$$->breaklist = $3->breaklist;
													$3->continuelist.merge($7->continuelist);
													$$->continuelist = $3->continuelist;
													//-----------------------------------//
													}
	| SWITCH '(' expression ')' statement 	{$$ = mknode("SWITCH (expr) stmt",(node*) NULL, $3, $5,(node*) NULL,(node*) NULL);
											//--------------3AC---------------------------//
                                              setListId1($5->caselist, $3->place);
                                              $5->nextlist.merge($5->breaklist);
                                              $$->nextlist= $5->nextlist;
                                              $$->continuelist= $5->continuelist;
                                          //---------------------------------------------//
	}
	;

iteration_statement
	: WHILE '(' M M6 ')' M statement GOTO_emit	{$$ = mknode("WHILE (expr) stmt", (node*)NULL, $4, $7, (node*)NULL, (node*)NULL);
												//-----------3AC------------------//
												backPatch($4->truelist, $6);
												$7->continuelist.push_back($8);
												backPatch($7->continuelist, $3);
												backPatch($7->nextlist, $3);
												$$->nextlist = $4->falselist;
												$$->nextlist.merge($7->breaklist);
												//--------------------------------//
												}
	| DO M statement WHILE '(' M M6 ')' ';' 	{$$ = mknode("DO stmt WHILE (expr)", (node*)NULL, $3, (node*)NULL, $7, (node*)NULL);
												//--------3AC-------------------------//
												backPatch($7->truelist, $2);
												backPatch($3->continuelist, $6);
												backPatch($3->nextlist, $6);
												$7->falselist.merge($3->breaklist);
												$$->nextlist = $7->falselist;
												//-----------------------------------//
												}
	| FOR '(' expression_statement M M7 ')' M statement GOTO_emit	{$$ = mknode("FOR (expr_stmt expr_stmt) stmt",(node*) NULL, $3, $5, $8, (node*)NULL);
												//-------------3AC-------------------//
												backPatch($3->nextlist, $4);
												backPatch($5->truelist, $7);
												$5->falselist.merge($8->breaklist);
												$$->nextlist = $5->falselist;
												$8->nextlist.merge($8->continuelist);
												$8->nextlist.push_back($9);
												backPatch($8->nextlist, $4 );
												//------------------------------------//
											}
	| FOR '(' expression_statement M M7 M expression GOTO_emit')' M statement GOTO_emit	{$$ = mknode("FOR (expr_stmt expr_stmt expr) stmt",(node*) NULL, $3, $5, $7, $11);
												//-------------3AC-------------------//
												backPatch($3->nextlist, $4);
												backPatch($5->truelist, $10);
												$5->falselist.merge($11->breaklist);
												$$->nextlist = $5->falselist;
												$11->nextlist.merge($11->continuelist);
												$11->nextlist.push_back($12);
												backPatch($11->nextlist, $6 );
												$7->nextlist.push_back($8);
												backPatch($7->nextlist, $4);
												//------------------------------------//
											}
	;

jump_statement
	: GOTO IDENTIFIER ';' 	
	{ 	
		$$ = mknode("jump_statement",(char*) NULL, mkleaf($1),mkleaf($2)); 
								//-----------3AC---------------------//
                                 int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 gotoIndexPatchListStorage($2, k);
                                //-----------------------------------//
	}
	| CONTINUE ';' 	{ $$ = mkleaf("continue");
							//-----------3AC---------------------//
                                 int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
                                 $$->continuelist.push_back(k);
                               //-----------------------------------//
					}
	| BREAK ';' 	{ $$ = mkleaf("break");
					//-----------3AC---------------------//
					int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
					$$->breaklist.push_back(k);
					//-----------------------------------//
					}
	| RETURN ';' 	{ $$ = mkleaf("return");
					//------------3AC----------------//
					emit(pair<string, sEntry*>("RETURN", lookup("return")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),-1);
					//------------------------------//
					}
	| RETURN expression ';' 	{$$ = mknode("jump_statement",(char*) NULL, mkleaf("return"),$2);
								//------------3AC----------------//
								emit(pair<string, sEntry*>("RETURN", lookup("return")), $2->place, pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),-1);
								//------------------------------//
								}
	;

translation_unit
	: external_declaration 	{$$ = $1;}
	| translation_unit M external_declaration 	{$$ = mknode("translation_unit", (char*)NULL, $1, $3);
												//----------3Ac----------------//
													backPatch($1->nextlist, $2);
													$$->nextlist = $3->nextlist;
												//------------------------------//
												}
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
			//--------------------3AC--------------------------------//
				if($5->rVal != -5){ string em =  "func end";
				emit(pair<string , sTableEntry*>(em, NULL), pair<string , sTableEntry*>("", NULL),pair<string , sTableEntry*>("", NULL),pair<string , sTableEntry*>("", NULL),-3);}
            //------------------------------------------------------//
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
			//--------------------3AC--------------------------------//
                if($4->rVal != -5){string em =  "func end";
                emit(pair<string , sEntry*>(em, NULL), pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),pair<string , sEntry*>("", NULL),-3); }
            //------------------------------------------------------//
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

GOTO_emit
	: %empty {

							$$ = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
	}
	;

M
	: %empty {
			$$ = getNextIndex();
	}
	;

M1
    :  '{'       { if(isFunc==0) {symNumber++;
                        symFileName = /*string("symTableFunc")+to_string(funcSym)*/funcName+string("Block")+to_string(symNumber);
                         scope=S_BLOCK;
                         makeSymTable(symFileName,scope,string("12345"));
                        char * y=new char();
                        strcpy(y,symFileName.c_str());
                        $$ = y;
                         blockSym++;
                        }
                       isFunc=0;
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
                makeSymTable(symFileName,scope,funcType);
                char* c= new char();
                strcpy(c,symFileName.c_str());
                $$ = c;
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

M4
	:  IF '(' expression ')' {
		if($3->truelist.begin()==$3->truelist.end()){
			int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $3->place, pair<string, sEntry*>("", NULL ),0);
			int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
			$3->truelist.push_back(k);
			$3->falselist.push_back(k1);

		}
		$$ = $3;
	}
	;

M5
	: CASE constant_expression ':' {
									$$=$2;
									//-----------3AC--------------------//
									qid t = getTmpSym("bool");
									int k = emit(pair<string, sEntry*>("EQ_OP", lookup("\=\=")),pair<string, sEntry*>("", NULL), $2->place, t, -1);
									int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), t, pair<string, sEntry*>("", NULL ),0);
									int k2 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
									$$->caselist.push_back(k);
									$$->truelist.push_back(k1);
									$$->falselist.push_back(k2);
								//-----------------------------------//


	}
	;

M6
	:   expression  {
							if($1->truelist.begin()==$1->truelist.end()){
								int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
								int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
								$1->truelist.push_back(k);
								$1->falselist.push_back(k1);

							}
							$$ = $1;
	}
	;

M7
	:   expression_statement  {
							if($1->truelist.begin()==$1->truelist.end()){
								int k = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("IF", lookup("if")), $1->place, pair<string, sEntry*>("", NULL ),0);
								int k1 = emit(pair<string, sEntry*>("GOTO", lookup("goto")),pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL), pair<string, sEntry*>("", NULL ),0);
								$1->truelist.push_back(k);
								$1->falselist.push_back(k1);

							}
							$$ = $1;
	}
	;

%%
#include <stdio.h>

extern char yytext[];
extern int column;

extern FILE *yyin;
int k;
int  main(int argc,char **argv){
	int val;
	int tempeven =0;
	int tempodd =0;
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
		yyparse();
		if(k==0) graphEnd();
		display3ac();
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

  char sub[5];
  memcpy(sub,s, 6 );
  sub[5] = '\0';
  if(!strcmp(sub,"Error")){k = 1;}
  
  int count = 1;
  if(s=="syntax error") count = 2;
  fprintf(stderr,"%s :: Line no. %d :: %s\n",filename,yylineno,buffer);
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

