D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*
WS			[ \t\v\n\f]
SP  		(u8|u|U|L)
ES  		(\\(['\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "nodes.h"
#include "parser.tab.h"


void yyerror (char *,...);
void get_int_info();
void get_real_info();
void count();
static int check_type();
static void comment();
 
using namespace std;
%}
%option yylineno
%%

"/*"[^*/]*"*/"			{}
"//".*			{}
"auto"			{yylval.str = strdup(yytext); return(AUTO); }
"break"			{yylval.str = strdup(yytext); return(BREAK); }
"case"			{yylval.str = strdup(yytext); return(CASE); }
"char"			{yylval.str = strdup(yytext); return(CHAR); }
"const"			{yylval.str = strdup(yytext); return(CONST); }
"continue"		{yylval.str = strdup(yytext); return(CONTINUE); }
"default"		{yylval.str = strdup(yytext); return(DEFAULT); }
"do"			{yylval.str = strdup(yytext); return(DO); }
"double"		{yylval.str = strdup(yytext); return(DOUBLE); }
"else"			{yylval.str = strdup(yytext); return(ELSE); }
"enum"			{yylval.str = strdup(yytext); return(ENUM); }
"extern"		{yylval.str = strdup(yytext); return(EXTERN); }
"float"			{yylval.str = strdup(yytext); return(FLOAT); }
"for"			{yylval.str = strdup(yytext); return(FOR); }
"goto"			{yylval.str = strdup(yytext); return(GOTO); }
"if"			{yylval.str = strdup(yytext); return(IF); }
"int"			{yylval.str = strdup(yytext); return(INT); }
"long"			{yylval.str = strdup(yytext); return(LONG); }
"register"		{yylval.str = strdup(yytext); return(REGISTER); }
"return"		{yylval.str = strdup(yytext); return(RETURN); }
"short"			{yylval.str = strdup(yytext); return(SHORT); }
"signed"		{yylval.str = strdup(yytext); return(SIGNED); }
"sizeof"		{yylval.str = strdup(yytext); return(SIZEOF); }
"static"		{yylval.str = strdup(yytext); return(STATIC); }
"struct"		{yylval.str = strdup(yytext); return(STRUCT); }
"switch"		{yylval.str = strdup(yytext); return(SWITCH); }
"typedef"		{yylval.str = strdup(yytext); return(TYPEDEF); }
"union"			{yylval.str = strdup(yytext); return(UNION); }
"unsigned"		{yylval.str = strdup(yytext); return(UNSIGNED); }
"void"			{yylval.str = strdup(yytext); return(VOID); }
"volatile"		{yylval.str = strdup(yytext); return(VOLATILE); }
"while"			{yylval.str = strdup(yytext); return(WHILE); }

{L}({L}|{D})*		{ yylval.str = strdup(yytext); return IDENTIFIER; }

0[xX]{H}+{IS}?		{sscanf(yytext+2,"%llx",&yylval.num->iVal);get_int_info();yylval.num->str = strdup(yytext);  return(CONSTANT); }
0{D}+{IS}?		{sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info();yylval.num->str = strdup(yytext);  return(CONSTANT); }
{D}+{IS}?		{sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info();yylval.num->str = strdup(yytext);  return(CONSTANT); }
L?'(\\.|[^\\'])+'	{get_int_info();yylval.num->str = strdup(yytext);  return(CONSTANT); }

{D}+{E}{FS}?		{yylval.num->str = strdup(yytext);get_real_info();  return(CONSTANT); }
{D}*"."{D}+({E})?{FS}?	{yylval.num->str = strdup(yytext);get_real_info(); return(CONSTANT); }
{D}+"."{D}*({E})?{FS}?	{yylval.num->str = strdup(yytext);get_real_info(); return(CONSTANT); }

L?\"(\\.|[^\\"])*\"	{ yylval.str = "STRING_LITERAL"; return(STRING_LITERAL); }

"..."					{ yylval.str=strdup(yytext);return ELLIPSIS; }
">>="					{ yylval.str=strdup(yytext);return RIGHT_ASSIGN; }
"<<="					{ yylval.str=strdup(yytext);return LEFT_ASSIGN; }
"+="					{ yylval.str=strdup(yytext);return ADD_ASSIGN; }
"-="					{ yylval.str=strdup(yytext);return SUB_ASSIGN; }
"*="					{ yylval.str=strdup(yytext);return MUL_ASSIGN; }
"/="					{ yylval.str=strdup(yytext);return DIV_ASSIGN; }
"%="					{ yylval.str=strdup(yytext);return MOD_ASSIGN; }
"&="					{ yylval.str=strdup(yytext);return AND_ASSIGN; }
"^="					{ yylval.str=strdup(yytext);return XOR_ASSIGN; }
"|="					{ yylval.str=strdup(yytext);return OR_ASSIGN; }
">>"					{ yylval.str=strdup(yytext);return RIGHT_OP; }
"<<"					{ yylval.str=strdup(yytext);return LEFT_OP; }
"++"					{ yylval.str=strdup(yytext);return INC_OP; }
"--"					{ yylval.str=strdup(yytext);return DEC_OP; }
"->"					{ yylval.str=strdup(yytext);return PTR_OP; }
"&&"					{ yylval.str=strdup(yytext);return AND_OP; }
"||"					{ yylval.str=strdup(yytext);return OR_OP; }
"<="					{ yylval.str=strdup(yytext);return LE_OP; }
">="					{ yylval.str=strdup(yytext);return GE_OP; }
"=="					{ yylval.str=strdup(yytext);return EQ_OP; }
"!="					{ yylval.str=strdup(yytext);return NE_OP; }
";"					{ yylval.str=strdup(yytext);return ';'; }
("{"|"<%")				{ yylval.str=strdup(yytext);return '{'; }
("}"|"%>")				{ yylval.str=strdup(yytext);return '}'; }
","					{ yylval.str=strdup(yytext);return ','; }
":"					{ yylval.str=strdup(yytext);return ':'; }
"="					{ yylval.str=strdup(yytext);return '='; }
"("					{ yylval.str=strdup(yytext);return '('; }
")"					{ yylval.str=strdup(yytext);return ')'; }
("["|"<:")				{ yylval.str=strdup(yytext);return '['; }
("]"|":>")				{ yylval.str=strdup(yytext);return ']'; }
"."					{ yylval.str=strdup(yytext);return '.'; }
"&"					{ yylval.str=strdup(yytext);return '&'; }
"!"					{ yylval.str=strdup(yytext);return '!'; }
"~"					{ yylval.str=strdup(yytext);return '~'; }
"-"					{ yylval.str=strdup(yytext);return '-'; }
"+"					{ yylval.str=strdup(yytext);return '+'; }
"*"					{ yylval.str=strdup(yytext);return '*'; }
"/"					{ yylval.str=strdup(yytext);return '/'; }
"%"					{ yylval.str=strdup(yytext);return '%'; }
"<"					{ yylval.str=strdup(yytext);return '<'; }
">"					{ yylval.str=strdup(yytext);return '>'; }
"^"					{ yylval.str=strdup(yytext);return '^'; }
"|"					{ yylval.str=strdup(yytext);return '|'; }
"?"					{ yylval.str=strdup(yytext);return '?'; }
\n                                    {}
" "                                        {}
{WS}                                       {}
.                                  {yyerror("Undefined pattern");}
({SP}?\"([^"\\\n]|{ES})*)        { yyerror("Incomplete String");} 
%%

int yywrap(void)
{
	return(1);
}


void get_int_info(){
   int i;
   yylval.num->nType = yylval.num->is_unsigned=1;
   for(i=yyleng-1;;i--){
       if(yytext[i]=='u'||yytext[i]=='U')
                yylval.num->is_unsigned =1;
       else if (yytext[i]=='l'||yytext[i] == 'L')
                yylval.num->nType++;
       else
             break;
    }
}
void get_real_info(){
   int i=yyleng-1;
   sscanf(yytext,"%Lf",&yylval.num->rVal);
       if(yytext[i]=='f'||yytext[i]=='F')
                yylval.num->nType =N_FLOAT;
       else if (yytext[i]=='l'||yytext[i] == 'L')
                yylval.num->nType = N_LONGDOUBLE;
       else
               yylval.num->nType =N_DOUBLE;
    }

static int returnType(void)
{

            return IDENTIFIER;

}
   