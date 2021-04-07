%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include "nodes.h"
#include "parser.tab.h"
void yyerror (char *,...);
void get_int_info();
void get_real_info();

static int returnType(void);
static void startComment(void);
%}
%e 1019
%p 2807
%n 371
%a 1213
%o 1117
%option yylineno

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])    
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]
%%

"/*"[^*/]*"*/"			{}
"//".*			{}
"auto"			{yylval.str = "AUTO"; return(AUTO); }
"break"			{yylval.str = "BREAK"; return(BREAK); }
"case"			{yylval.str = "CASE"; return(CASE); }
"char"			{yylval.str = "CHAR"; return(CHAR); }
"const"			{yylval.str = "CONST"; return(CONST); }
"continue"		{yylval.str = "CONTINUE"; return(CONTINUE); }
"default"		{yylval.str = "DEFAULT"; return(DEFAULT); }
"do"			{yylval.str = "DO"; return(DO); }
"double"		{yylval.str = "DOUBLE"; return(DOUBLE); }
"else"			{yylval.str = "ELSE"; return(ELSE); }
"enum"			{yylval.str = "ENUM"; return(ENUM); }
"extern"		{yylval.str = "EXTERN"; return(EXTERN); }
"float"			{yylval.str = "FLOAT"; return(FLOAT); }
"for"			{yylval.str = "FOR"; return(FOR); }
"goto"			{yylval.str = "GOTO"; return(GOTO); }
"if"			{yylval.str = "IF"; return(IF); }
"int"			{yylval.str = "INT"; return(INT); }
"long"			{yylval.str = "LONG"; return(LONG); }
"register"		{yylval.str = "REGISTER"; return(REGISTER); }
"return"		{yylval.str = "RETURN"; return(RETURN); }
"short"			{yylval.str = "SHORT"; return(SHORT); }
"signed"		{yylval.str = "SIGNED"; return(SIGNED); }
"sizeof"		{yylval.str = "SIZEOF"; return(SIZEOF); }
"static"		{yylval.str = "STATIC"; return(STATIC); }
"struct"		{yylval.str = "STRUCT"; return(STRUCT); }
"switch"		{yylval.str = "SWITCH"; return(SWITCH); }
"typedef"		{yylval.str = "TYPEDEF"; return(TYPEDEF); }
"union"			{yylval.str = "UNION"; return(UNION); }
"unsigned"		{yylval.str = "UNSIGNED"; return(UNSIGNED); }
"void"			{yylval.str = "VOID"; return(VOID); }
"volatile"		{yylval.str = "VOLATILE"; return(VOLATILE); }
"while"			{yylval.str = "WHILE"; return(WHILE); }

{L}{A}*                                 {yylval.str = strdup(yytext); return returnType(); }

{HP}{H}+{IS}?                           {sscanf(yytext+2,"%llx",&yylval.num->iVal);get_int_info();yylval.num->str = strdup(yytext);
                                        return CONSTANT;}
{NZ}{D}*{IS}?                           {sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info(); yylval.num->str = strdup(yytext);return CONSTANT;}
"0"{O}*{IS}?                            {sscanf(yytext,"%lld",&yylval.num->iVal);get_int_info(); yylval.num->str = strdup(yytext); return CONSTANT;}
{CP}?"'"([^'\\\n]|{ES})+"'"             {get_int_info(); yylval.num->str = strdup(yytext); ;return CONSTANT;}

{D}+{E}{FS}?                            {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}
{D}*"."{D}+{E}?{FS}?                    {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}
{D}+"."{E}?{FS}?                        {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}
{HP}{H}+{P}{FS}?                        {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}
{HP}{H}*"."{H}+{P}{FS}?                 {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}
{HP}{H}+"."{P}{FS}?                     {yylval.num->str = strdup(yytext);get_real_info(); return CONSTANT;}

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+       {yylval.str=strdup(yytext); return STRING_LITERAL;} 

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

int yywrap(void) {
  return 1;
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

static void startComment(void)
{
    int c;

    while ((c = yyinput()) != EOF){
        if (c == '*')
        {
            while ((c = yyinput()) == '*') ;


            if (c == '/')
                return;

            if (c == -1)
                break;
        }
    }
    yyerror("unterminated comment");
}
static int returnType(void)
{

            return IDENTIFIER;

}
   

