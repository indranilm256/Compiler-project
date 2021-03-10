%{
#include <iostream>
#include <cstring>
#include <list>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdarg.h>
using namespace std;
#define MAX_STR_LEN 1024
#include "nodes.h"

extern FILE *yyin, *yyout; 
int yylex(void);
void yyerror(char *s,...);

FILE* digraph;
char filename[1000];
extern int yylineno;
%}

%union {
  char *str;
  node *ptr;
};


%token <str> IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token <str> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token <str> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <str> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token <str> XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token <str> TYPEDEF EXTERN STATIC AUTO REGISTER
%token <str> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token <str> STRUCT UNION ENUM ELLIPSIS
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

%%

primary_expression
	: IDENTIFIER			{$$ = terminal($1);}
	| CONSTANT				{$$ = terminal($1);}	
	| STRING_LITERAL		{$$ = terminal($1);}	
	| '(' expression ')'	{$$ = $2;}	
	;

postfix_expression
	: primary_expression	{$$ = $1;}
	| postfix_expression '[' expression ']'		{$$ = non_terminal_symbol_type1("postfix_expression[expression]", NULL, $1, $3);}
	| postfix_expression '(' ')'		{$$ = $1;} 			
	| postfix_expression '(' argument_expression_list ')'		{$$ = non_terminal_symbol_type1("postfix_expression", NULL, $1, $3);}
	| postfix_expression PTR_OP IDENTIFIER	{$$ = non_terminal_symbol_type1("postfix_expression",$2,$1,terminal($3));}
	| postfix_expression INC_OP				{$$ = non_terminal_symbol_type1("postfix_expression",$2,$1,NULL);}
	| postfix_expression DEC_OP				{$$ = non_terminal_symbol_type1("postfix_expression",$2,$1,NULL);}
	;

argument_expression_list
	: assignment_expression		{$$ = non_terminal_symbol_type1("assignment_expression_list",NULL,$1,NULL);}
	| argument_expression_list ',' assignment_expression		{$$ = non_terminal_symbol_type1("assignment_expression_list",$2,$1,$3);}
	;

unary_expression
	: postfix_expression		{$$ = $1;} 
	| INC_OP unary_expression	{$$=  non_terminal_symbol_type1($1, NULL, NULL, $2); }
	| DEC_OP unary_expression	{$$=  non_terminal_symbol_type1($1, NULL, NULL, $2); }
	| unary_operator cast_expression	{$$ = non_terminal_symbol_type1("unary_expression", NULL, $1, $2);}
	| SIZEOF unary_expression		{$$=  non_terminal_symbol_type1($1, NULL, NULL, $2); }
	| SIZEOF '(' type_name ')'		{$$ = non_terminal_symbol_type1($1, NULL, NULL, $3);}
	;

unary_operator
	: '&'		{$$ = terminal($1);}
	| '*'		{$$ = terminal($1);}
	| '+'		{$$ = terminal($1);}
	| '-'		{$$ = terminal($1);}
	| '~'		{$$ = terminal($1);}
	| '!'		{$$ = terminal($1);}
	;

cast_expression
	: unary_expression		{$$ = $1;}
	| '(' type_name ')' cast_expression		{$$ = $4;}
	;

multiplicative_expression
	: cast_expression		{$$ = $1;}
	| multiplicative_expression '*' cast_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| multiplicative_expression '/' cast_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| multiplicative_expression '%' cast_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

additive_expression
	: multiplicative_expression		{$$ = $1;}
	| additive_expression '+' multiplicative_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| additive_expression '-' multiplicative_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

shift_expression
	: additive_expression		{$$ = $1;}
	| shift_expression LEFT_OP additive_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| shift_expression RIGHT_OP additive_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

relational_expression
	: shift_expression			{$$ = $1;}
	| relational_expression '<' shift_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| relational_expression '>' shift_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| relational_expression LE_OP shift_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| relational_expression GE_OP shift_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

equality_expression
	: relational_expression		{$$ = $1;}
	| equality_expression EQ_OP relational_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	| equality_expression NE_OP relational_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

and_expression
	: equality_expression		{$$ = $1;}
	| and_expression '&' equality_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

exclusive_or_expression
	: and_expression			{$$ = $1;}
	| exclusive_or_expression '^' and_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

inclusive_or_expression
	: exclusive_or_expression		{$$ = $1;}
	| inclusive_or_expression '|' exclusive_or_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

logical_and_expression
	: inclusive_or_expression		{$$ = $1;}
	| logical_and_expression AND_OP inclusive_or_expression			{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

logical_or_expression
	: logical_and_expression		{$$ = $1;}
	| logical_or_expression OR_OP logical_and_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
	;

conditional_expression
	: logical_or_expression			{$$ = $1;}
	| logical_or_expression '?' expression ':' conditional_expression		{$$ = non_terminal_symbol_type1($2,NULL,$3,$5);}
	;

assignment_expression
	: conditional_expression		{$$ = $1;}
	| unary_expression assignment_operator assignment_expression		{$$ = non_terminal_symbol_type1($2,NULL,$1,$3);}
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
	| expression ',' assignment_expression		{$$ = non_terminal_symbol_type1("expression", NULL, $1, $3);}
	;

constant_expression
	: conditional_expression		{$$ = $1;}
	;

declaration
	: declaration_specifiers ';'		
	| declaration_specifiers init_declarator_list ';'   {$$ = non_terminal_symbol_type1("declaration", NULL, $1, $2);}
	;

declaration_specifiers
	: storage_class_specifier		{$$ = $1;}
	| storage_class_specifier declaration_specifiers		{$$ = non_terminal_symbol_type1("declaration_specifiers", NULL, $1, $2);}
	| type_specifier				{$$ = $1;}
	| type_specifier declaration_specifiers					{$$ = non_terminal_symbol_type1("declaration_specifiers", NULL, $1, $2);}
	| type_qualifier				{$$ = $1;}
	| type_qualifier declaration_specifiers					{$$ = non_terminal_symbol_type1("declaration_specifiers", NULL, $1, $2);}
	;

init_declarator_list
	: init_declarator		{$$ = $1;}
	| init_declarator_list ',' init_declarator		{$$ = non_terminal_symbol_type1("init_declarator_list", NULL, $1, $3);}
	;

init_declarator
	: declarator		{$$ = $1;}
	| declarator '=' initializer		{$$ = non_terminal_symbol_type1("=", NULL, $1, $3);}
	;

storage_class_specifier
	: TYPEDEF 	{$$ = terminal($1);}
	| EXTERN	{$$ = terminal($1);}
	| STATIC	{$$ = terminal($1);}
	| AUTO		{$$ = terminal($1);}
	| REGISTER		{$$ = terminal($1);}
	;

type_specifier
	: VOID			{$$ = terminal($1);}
	| CHAR			{$$ = terminal($1);}
	| SHORT			{$$ = terminal($1);}
	| INT			{$$ = terminal($1);}
	| LONG			{$$ = terminal($1);}
	| FLOAT			{$$ = terminal($1);}
	| DOUBLE		{$$ = terminal($1);}	
	| SIGNED		{$$ = terminal($1);}
	| UNSIGNED		{$$ = terminal($1);}
	| struct_or_union_specifier		{$$ = $1;}
	| enum_specifier		{$$ = $1;}
	| TYPE_NAME		{$$ = terminal($1);}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'		{$$ = non_terminal_symbol_type1($2, NULL, $1, $4);}
	| struct_or_union '{' struct_declaration_list '}'		{$$ = non_terminal_symbol_type1("struct_or_union_specifier", NULL, $1, $3);}
	| struct_or_union IDENTIFIER		{$$ = non_terminal_symbol_type1($2, NULL,$1, NULL);}
	;
	
struct_or_union
	: STRUCT 	{$$ = terminal($1);}
	| UNION		{$$ = terminal($1);}
	;

struct_declaration_list
	: struct_declaration		{$$ = $1;}
	| struct_declaration_list struct_declaration		{$$ = non_terminal_symbol_type1("struct_declaration_list", NULL, $1, $2);}
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'		{$$ = non_terminal_symbol_type1("struct_declaration", NULL, $1, $2);}	
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list		{$$ = non_terminal_symbol_type1("specifier_qualifier_list", NULL, $1, $2);}
	| type_specifier		{$$ = $1;}
	| type_qualifier specifier_qualifier_list		{$$ = non_terminal_symbol_type1("specifier_qualifier_list", NULL, $1, $2);}
	| type_qualifier		{$$ = $1;}
	;

struct_declarator_list
	: struct_declarator		{$$ = $1;}
	| struct_declarator_list ',' struct_declarator		{$$ = non_terminal_symbol_type1("struct_declarator_list",NULL, $1, $3);}
	;

struct_declarator
	: declarator		{$$ = $1;}
	| ':' constant_expression		{$$ = $2;}
	| declarator ':' constant_expression		{$$ = non_terminal_symbol_type1("struct_declarator", NULL, $1, $3);}
	;

enum_specifier
	: ENUM '{' enumerator_list '}'		{$$ = non_terminal_symbol_type1( $1, NULL, NULL, $3);}
	| ENUM IDENTIFIER '{' enumerator_list '}'	{$$ = non_terminal_symbol_type3($1, NULL,$2, $4,NULL);}
	| ENUM IDENTIFIER		{$$ = non_terminal_symbol_type3($1, NULL, $2,NULL, NULL);}
	;

enumerator_list
	: enumerator		{$$ = $1;}
	| enumerator_list ',' enumerator		{$$ = non_terminal_symbol_type1("enumerator_list", NULL, $1, $3);}
	;

enumerator
	: IDENTIFIER	{$$ = terminal($1);}
	| IDENTIFIER '=' constant_expression		{$$ = non_terminal_symbol_type1("=",NULL, terminal($1),  $3);}
	;

type_qualifier
	: CONST		{$$ = terminal($1);}
	| VOLATILE		{$$ = terminal($1);}
	;

declarator
	: pointer direct_declarator		{$$ = non_terminal_symbol_type1("declarator", NULL, $1, $2);}
	| direct_declarator			{$$ = $1;}
	;

direct_declarator
	: IDENTIFIER		{$$ = terminal($1);}
	| '(' declarator ')'		{$$ = $2;}
	| direct_declarator '[' constant_expression ']'			{$$ = non_terminal_symbol_type1("direct_declarator", NULL, $1, $3);}	
	| direct_declarator '[' ']'		{$$ = square_non_terminal("direct_declarator", $1);}
	| direct_declarator '(' parameter_type_list ')'		{$$ = non_terminal_symbol_type1("direct_declarator", NULL, $1, $3);}
	| direct_declarator '(' identifier_list ')'		{$$ = non_terminal_symbol_type1("direct_declarator", NULL, $1, $3);}
	| direct_declarator '(' ')'		{$$ = paranthesis_non_terminal("direct_declarator", $1);}
	;

pointer
	: '*'		{$$ = terminal($1);}
	| '*' type_qualifier_list		{$$ = non_terminal_symbol_type1("pointer", NULL, $2, NULL);}
	| '*' pointer		{$$ = non_terminal_symbol_type1("pointer", NULL, $2, NULL);}
	| '*' type_qualifier_list pointer		{$$ = non_terminal_symbol_type1("pointer", NULL, $2, $3);}
	;


type_qualifier_list
	: type_qualifier 	{$$=$1;}
	| type_qualifier_list type_qualifier 	{$$=non_terminal_symbol_type1("type_qualifier_list",NULL,$1,$2);}
	;


parameter_type_list
	: parameter_list 	{$$=$1;}
	| parameter_list ',' ELLIPSIS 	{$$=non_terminal_symbol_type1("parameter_type_list",NULL,$1,terminal($3));}
	;

parameter_list
	: parameter_declaration 	{$$=$1;}
	| parameter_list ',' parameter_declaration 	{$$=non_terminal_symbol_type1("parameter_list",NULL,$1,$3);}
	;

parameter_declaration
	: declaration_specifiers declarator 	{$$=non_terminal_symbol_type1("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers abstract_declarator 	{$$=non_terminal_symbol_type1("parameter_declaration",NULL,$1,$2);}
	| declaration_specifiers {$$=$1;}
	;

identifier_list
	: IDENTIFIER 	{$$=terminal($1);}
	| identifier_list ',' IDENTIFIER 	{$$=non_terminal_symbol_type1("identifier_list",NULL,$1,terminal($3));}
	;

type_name
	: specifier_qualifier_list 	{$$=$1;}
	| specifier_qualifier_list abstract_declarator 	{$$=non_terminal_symbol_type1("type_name",NULL,$1,$2);}
	;

abstract_declarator 
	: pointer {$$ = $1;}
	| direct_abstract_declarator 	{$$ = $1;}
	| pointer direct_abstract_declarator 	{$$ = non_terminal_symbol_type1("abstract_declarator", NULL, $1, $2);}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'   {$$ = $2;}
	| '[' ']'  						{$$ = terminal("[ ]");}
	| '[' constant_expression ']' 	{$$ = $2;}
	| direct_abstract_declarator '[' ']'	{$$ = non_terminal_symbol_type1("[ ]",NULL,$1,NULL);}
	| direct_abstract_declarator '[' constant_expression ']' 	{$$ = non_terminal_symbol_type1("direct_abstract_declarator",NULL, $1, $3);}
	| '(' ')'	{$$ = terminal("( )");}		
	| '(' parameter_type_list ')'	{$$ = $2;}
	| direct_abstract_declarator '(' ')' 	{$$ = non_terminal_symbol_type1("( )",NULL,$1,NULL);}
	| direct_abstract_declarator '(' parameter_type_list ')'	 {$$ = non_terminal_symbol_type1("direct_abstract_declarator", NULL, $1, $3);}
	;

initializer
	: assignment_expression 		{$$ = $1;}
	| '{' initializer_list '}' 		{$$ = $2;}
	| '{' initializer_list ',' '}' 		{$$ = non_terminal_symbol_type1( $3,NULL, $2 ,NULL);}
	;

initializer_list
	: initializer 	{$$ = $1;}
	| initializer_list ',' initializer 	{$$ = non_terminal_symbol_type1("initializer_list", NULL, $1 ,$3);}
	;

statement
	: labeled_statement 	{$$ = $1;}
	| compound_statement 	{$$ = $1;}
	| expression_statement 	{$$ = $1;}
	| selection_statement 	{$$ = $1;}
	| iteration_statement 	{$$ = $1;}
	| jump_statement 	{$$ = $1;}
	;

labeled_statement
	: IDENTIFIER ':' statement 	{ $$ = non_terminal_symbol_type1("labeled_statement", NULL, terminal($1), $3); }
	| CASE constant_expression ':' statement 	 { $$ = non_terminal_symbol_type2("labeled_statement", terminal($1), $2, $4); } 
	| DEFAULT ':' statement	 { $$ = non_terminal_symbol_type1("labeled_statement", NULL, terminal($1), $3); }
	;

compound_statement
	: '{' '}'	 {$$ = terminal("{ }");} 
	| '{' statement_list '}'	 {$$ = $2;}
	| '{' declaration_list '}' 	{$$ = $2;}
	| '{' declaration_list statement_list '}' 	{ $$ = non_terminal_symbol_type1("compound_statement", NULL, $2 , $3); }
	;

declaration_list
	: declaration 	{$$ = $1;}
	| declaration_list declaration 	{$$ = non_terminal_symbol_type1("declaration_list", NULL, $1, $2);}
	;

statement_list
	: statement 	{$$ = $1;}
	| statement_list statement 	{$$ = non_terminal_symbol_type1("statement_list", NULL, $1, $2);}
	;

expression_statement
	: ';' 	{$$ = terminal(";");}
	| expression ';' 	{$$ = $1;}
	;

selection_statement
	: IF '(' expression ')' statement 	{$$ = non_terminal_symbol_type5("IF (expr) stmt", NULL, $3, $5, NULL, NULL);}
	| IF '(' expression ')' statement ELSE statement 	{$$ = non_terminal_symbol_type5("IF (expr) stmt ELSE stmt", NULL, $3, $5, NULL, $7); }
	| SWITCH '(' expression ')' statement 	{$$ = non_terminal_symbol_type5("SWITCH (expr) stmt", NULL, $3, $5, NULL, NULL);}
	;

iteration_statement
	: WHILE '(' expression ')' statement 	{$$ = non_terminal_symbol_type5("WHILE (expr) stmt", NULL, $3, $5, NULL, NULL);}
	| DO statement WHILE '(' expression ')' ';' 	{$$ = non_terminal_symbol_type5("DO stmt WHILE (expr)", NULL, $2, NULL, $5, NULL);}
	| FOR '(' expression_statement expression_statement ')' statement 	{$$ = non_terminal_symbol_type5("FOR (expr_stmt expr_stmt) stmt", NULL, $3, $4, $6, NULL);}
	| FOR '(' expression_statement expression_statement expression ')' statement 	{$$ = non_terminal_symbol_type5("FOR (expr_stmt expr_stmt expr) stmt", NULL, $3, $4, $5, $7); }
	;

jump_statement
	: GOTO IDENTIFIER ';' 	{ $$ = non_terminal_symbol_type1("jump_statement", NULL, terminal($1),terminal($2)); }
	| CONTINUE ';' 	{ $$ = terminal($1);}
	| BREAK ';' 	{ $$ = terminal($1);}
	| RETURN ';' 	{ $$ = terminal($1);}
	| RETURN expression ';' 	{ $$ = non_terminal_symbol_type1("jump_statement", NULL, terminal($1),$2);}
	;

translation_unit
	: external_declaration 	{$$ = $1;}
	| translation_unit external_declaration 	{$$ = non_terminal_symbol_type1("translation_unit", NULL, $1, $2);}
	;

external_declaration
	: function_definition 	{$$ = $1;}
	| declaration 	{$$ = $1;}
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement 	{$$ = non_terminal_symbol_type4("function_definition", $1, $2, $3, $4, NULL);}
	| declaration_specifiers declarator compound_statement 	{$$ = non_terminal_symbol_type2("function_definition", $1, $2, $3);}
	| declarator declaration_list compound_statement 	{$$ = non_terminal_symbol_type1("function_definition", NULL, $2, $3);}
	| declarator compound_statement			{$$ = non_terminal_symbol_type1("function_definition", NULL, NULL, $2);}
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
		
			graphStart();
			int k= yyparse();
			if(k==0)graphEnd();
		
	}
	return 0;
}



void yyerror (char *s,...)
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}

