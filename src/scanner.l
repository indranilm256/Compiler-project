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
#include <stdio.h>
#include <iostream>
#include <string.h>
#include <iomanip>
#include "parser.tab.h"
using namespace std;
void yyerror (char *,...);

void count();
static int check_type();
static void comment();

%}

%%
"/*"			{ comment(); }
"auto"			{ count(); yylval.str = "AUTO"; return(AUTO); }
"break"			{ count(); yylval.str = "BREAK"; return(BREAK); }
"case"			{ count(); yylval.str = "CASE"; return(CASE); }
"char"			{ count(); yylval.str = "CHAR"; return(CHAR); }
"const"			{ count(); yylval.str = "CONST"; return(CONST); }
"continue"		{ count(); yylval.str = "CONTINUE"; return(CONTINUE); }
"default"		{ count(); yylval.str = "DEFAULT"; return(DEFAULT); }
"do"			{ count(); yylval.str = "DO"; return(DO); }
"double"		{ count(); yylval.str = "DOUBLE"; return(DOUBLE); }
"else"			{ count(); yylval.str = "ELSE"; return(ELSE); }
"enum"			{ count(); yylval.str = "ENUM"; return(ENUM); }
"extern"		{ count(); yylval.str = "EXTERN"; return(EXTERN); }
"float"			{ count(); yylval.str = "FLOAT"; return(FLOAT); }
"for"			{ count(); yylval.str = "FOR"; return(FOR); }
"goto"			{ count(); yylval.str = "GOTO"; return(GOTO); }
"if"			{ count(); yylval.str = "IF"; return(IF); }
"int"			{ count(); yylval.str = "INT"; return(INT); }
"long"			{ count(); yylval.str = "LONG"; return(LONG); }
"register"		{ count(); yylval.str = "REGISTER"; return(REGISTER); }
"return"		{ count(); yylval.str = "RETURN"; return(RETURN); }
"short"			{ count(); yylval.str = "SHORT"; return(SHORT); }
"signed"		{ count(); yylval.str = "SIGNED"; return(SIGNED); }
"sizeof"		{ count(); yylval.str = "SIZEOF"; return(SIZEOF); }
"static"		{ count(); yylval.str = "STATIC"; return(STATIC); }
"struct"		{ count(); yylval.str = "STRUCT"; return(STRUCT); }
"switch"		{ count(); yylval.str = "SWITCH"; return(SWITCH); }
"typedef"		{ count(); yylval.str = "TYPEDEF"; return(TYPEDEF); }
"union"			{ count(); yylval.str = "UNION"; return(UNION); }
"unsigned"		{ count(); yylval.str = "UNSIGNED"; return(UNSIGNED); }
"void"			{ count(); yylval.str = "VOID"; return(VOID); }
"volatile"		{ count(); yylval.str = "VOLATILE"; return(VOLATILE); }
"while"			{ count(); yylval.str = "WHILE"; return(WHILE); }

{L}({L}|{D})*		{ count(); yylval.str = "ID"; return(check_type()); }

0[xX]{H}+{IS}?		{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }
0{D}+{IS}?		{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }
{D}+{IS}?		{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }
L?'(\\.|[^\\'])+'	{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }

{D}+{E}{FS}?		{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }
{D}*"."{D}+({E})?{FS}?	{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }
{D}+"."{D}*({E})?{FS}?	{ count(); yylval.str = "CONSTANT"; return(CONSTANT); }

L?\"(\\.|[^\\"])*\"	{ count(); yylval.str = "STRING_LITERAL"; return(STRING_LITERAL); }

"..."			{ count(); yylval.str = "ELLIPSIS"; return(ELLIPSIS); }
">>="			{ count(); yylval.str = "RIGHT_ASSIGN"; return(RIGHT_ASSIGN); }
"<<="			{ count(); yylval.str = "LEFT_ASSIGN"; return(LEFT_ASSIGN); }
"+="			{ count(); yylval.str = "ADD_ASSIGN"; return(ADD_ASSIGN); }
"-="			{ count(); yylval.str = "SUB_ASSIGN"; return(SUB_ASSIGN); }
"*="			{ count(); yylval.str = "MUL_ASSIGN"; return(MUL_ASSIGN); }
"/="			{ count(); yylval.str = "DIV_ASSIGN"; return(DIV_ASSIGN); }
"%="			{ count(); yylval.str = "MOD_ASSIGN"; return(MOD_ASSIGN); }
"&="			{ count(); yylval.str = "AND_ASSIGN"; return(AND_ASSIGN); }
"^="			{ count(); yylval.str = "XOR_ASSIGN"; return(XOR_ASSIGN); }
"|="			{ count(); yylval.str = "OR_ASSIGN"; return(OR_ASSIGN); }
">>"			{ count(); yylval.str = "RIGHT_OP"; return(RIGHT_OP); }
"<<"			{ count(); yylval.str = "LEFT_OP"; return(LEFT_OP); }
"++"			{ count(); yylval.str = "INC_OP"; return(INC_OP); }
"--"			{ count(); yylval.str = "DEC_OP"; return(DEC_OP); }
"->"			{ count(); yylval.str = "PTR_OP"; return(PTR_OP); }
"&&"			{ count(); yylval.str = "AND_OP"; return(AND_OP); }
"||"			{ count(); yylval.str = "OR_OP"; return(OR_OP); }
"<="			{ count(); yylval.str = "LE_OP"; return(LE_OP); }
">="			{ count(); yylval.str = "GE_OP"; return(GE_OP); }
"=="			{ count(); yylval.str = "EQ_OP"; return(EQ_OP); }
"!="			{ count(); yylval.str = "NE_OP"; return(NE_OP); }
";"			{ count(); yylval.str = ";"; return(';'); }
("{"|"<%")		{ count(); yylval.str = "{"; return('{'); }
("}"|"%>")		{ count(); yylval.str = "}"; return('}'); }
","			{ count(); yylval.str = ","; return(','); }
":"			{ count(); yylval.str = ":"; return(':'); }
"="			{ count(); yylval.str = "="; return('='); }
"("			{ count(); yylval.str = "("; return('('); }
")"			{ count(); yylval.str = ")"; return(')'); }
("["|"<:")		{ count(); yylval.str = "["; return('['); }
("]"|":>")		{ count(); yylval.str = "]"; return(']'); }
"."			{ count(); yylval.str = "."; return('.'); }
"&"			{ count(); yylval.str = "&"; return('&'); }
"!"			{ count(); yylval.str = "!"; return('!'); }
"-"			{ count(); yylval.str = "-"; return('-'); }
"+"			{ count(); yylval.str = "+"; return('+'); }
"*"			{ count(); yylval.str = "*"; return('*'); }
"/"			{ count(); yylval.str = "/"; return('/'); }
"%"			{ count(); yylval.str = "%"; return('%'); }
"<"			{ count(); yylval.str = "<"; return('<'); }
">"			{ count(); yylval.str = ">"; return('>'); }
"^"			{ count(); yylval.str = "^"; return('^'); }
"|"			{ count(); yylval.str = "|"; return('|'); }
"?"			{ count(); yylval.str = "?"; return('?'); }

{WS}		{ count(); }
({L}|{D}|{WS})*"*/"			{ count(); yyerror("Illegal Comment");}
.			{ yyerror("Undefined pattern");/* ignore bad characters */ }
({SP}?\"([^"\\\n]|{ES})*)        { yyerror("Incomplete String");} 


%%

int yywrap(void)
{
	return(1);
}


static void comment()
{
	char c, c1;

loop:
	while ((c = yyinput()) != '*' && c != 0)
		// putchar(c);

	if ((c1 = yyinput()) != '/' && c != 0)
	{
		unput(c1);
		goto loop;
	}

	// if (c != 0)
		// putchar(c1);
}


int column = 1, row = 1;

void count()
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++){
		if (yytext[i] == '\n'){
			column = 1;
			row++;
		}
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else 
			column++;
	}
}


static int check_type(void)
{

//  pseudo code --- this is what it should check

	// if (yytext == type_name)
	// 	return(TYPE_NAME);

	// return(IDENTIFIER);


/*
*	it actually will only return IDENTIFIER
*/

	return(IDENTIFIER);
}

int  main(int argc,char **argv){
	int val;
	int n =  argc;
	if(argc <= 2){
		printf("Usage : ./bin/mycompiler -i ./test/input.txt -o output.txt\n -o tag and output file optional\n");
	}else{
		if(strcmp(argv[1], "-i")){
			cout << "Invalid Format. Use -h flag for help\n";
			return -1;
		}else{
			if(strcmp(argv[n-2],"-o")){ 
				for(int i=2;i<n;i++){
					if (!(yyin = fopen(argv[i], "r"))){
							perror("Error: ");
							return -1;
					}
					printf("%20s\t%20s\t%7s\t%7s\n", "TOKEN", "LEXEME", "ROW", "COLUMN");
					while ( (val = yylex()) > 0 ) { 
						if(yylval.str == "CONSTANT"){
							printf("%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
						}else if(yylval.str == "STRING_LITERAL"){
							for(int i=0;yytext[i] != '\0';i++){
								if(yytext[i] == '\n'){
									printf("error at line %d: bad character \"%s\"\n", row-1, yytext );
									exit(-1);
								}else{
									continue;
								}
							}
							printf("%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
						}
						else{ 
							printf("%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
						}
					}
					printf("\n\n*****************************************************************\n\n");
				}
			}else{
				for(int i=2;i<n-2;i++){
					if (!(yyout = fopen(argv[n-1], "w"))){
							perror("Error: ");
							return -1;
					}else{
						if (!(yyin = fopen(argv[i], "r"))){
							perror("Error: ");
							return -1;
						}
						fprintf(yyout, "%20s\t%20s\t%7s\t%7s\n", "TOKEN", "LEXEME", "ROW", "COLUMN");
						while ( (val = yylex()) > 0 ) { 
							if(yylval.str == "CONSTANT"){
								fprintf(yyout, "%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
							}else if(yylval.str == "STRING_LITERAL"){
								for(int i=0;yytext[i] != '\0';i++){
									if(yytext[i] == '\n'){
										fprintf(yyout,"error at line %d: bad character \"%s\"\n", row-1, yytext );
										exit(-1);
									}else{
										continue;
									}
								}
								fprintf(yyout, "%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
							}
							else{ 
								fprintf(yyout, "%20s\t%20s\t%7d\t%7d\n", yylval.str, yytext, row, column - yyleng);
							}
						}
						fprintf(yyout,"\n\n*****************************************************************\n\n");
					}
				}
			}
		}
	}
	return 0;
}
