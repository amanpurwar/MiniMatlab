%{
#include "y.tab.h"
#include <stdio.h>
%}
%option noyywrap
identifier			[a-zA-Z_][a-zA-Z_0-9]*
INTEGER_CONSTANT	[1-9][0-9]*
ZERO_CONSTANT 		[0]
DIGIT_SEQUENCE 		[0-9]+
SIGN 				[+-]
EXPONENT_PART 		[e|E]{SIGN}?{DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT	{DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}"."
FLOATING_CONSTANT	{FRACTIONAL_CONSTANT}{EXPONENT_PART}?|{DIGIT_SEQUENCE}{EXPONENT_PART} 	
ESCAPE_SEQUENCE		[\\'\\"\\?\\\\\a\\b\\f\\n\\r\\t\\v]
C_CHAR				[^'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE		{C_CHAR}+
CHAR_CONSTANT		\'{C_CHAR_SEQUENCE}\'
constant			{INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{ZERO_CONSTANT}|{CHAR_CONSTANT}
string_literal		\"{C_CHAR_SEQUENCE}*?\"
comment				"//".*|[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] 

%%
"unsigned" 				{return UNSIGNED;}
"break"					{return BREAK;}
"case"					{return CASE;}
"char"					{return CHAR;}
"continue"				{return CONTINUE;}
"default"				{return DEFAULT;}
"do"					{return DO;}
"double"				{return DOUBLE;}
"else"					{return ELSE;}
"float"					{return FLOAT;}
"for"					{return FOR;}
"goto"					{return GOTO;}
"if"					{return IF;}
"int"					{return INT;}
"long"					{return LONG;}
"return"				{return RETURN;}
"short"					{return SHORT;}
"signed"				{return SIGNED;}
"switch"				{return SWITCH;}
"void"					{return VOID;}
"while"					{return WHILE;}
"Bool"					{return BOOL;}
"Matrix"  				{return MATRIX;}
"["						{return '[';}
"++"					{return INCREMENT;}
"!="					{return NE;}
"&="					{return BITAND;}
"^"						{return '^';}
"|"						{return '|';}
"^="					{return POWER;}
"&&"					{return AND;}
"||"					{return OR;}
"|="					{return OREQUAL;}
".'" 					{return DOTCOMMA;} 
"/"						{return '/';}
"?"						{return '?';}
":"						{return ':';}
"="						{return '=';}
","						{return ',';}
"]"						{return ']';}
"("						{return '(';}
"{"						{return '{';}
"}"						{return '}';}
"."						{return '.';}
"->"					{return ARROW;}
">>"					{return RIGHTSHIFT;}
"<"						{return '<';}
">"						{return '>';}
"<="					{return LTE;}
">="					{return GTE;}
";"						{return ';';}
"*="					{return MULTIPLY;}
"*"						{return '*';}
"+"						{return '+';}
"-"						{return '-';}
"~"						{return '~';}
"!"						{return '!';}
"%"						{return '%';}
"<<"					{return LEFTSHIFT;}
"/="					{return DIVIDE;}
"%="					{return REMAINDER;}
"+="					{return ADD;}
"-="					{return SUBTRACT;}
"<<="					{return LEFTSHIFTEQUAL;}
"#"						{return '#';}
"--"					{return DECREMENT;}
")"						{return ')';}
"&"						{return '&';}
"=="					{return EQUALITY;}
">>="					{return RIGHTSHIFTEQUAL;}
{identifier}			{return IDENTIFIER;}
{constant} 				{return CONSTANT;}
{string_literal}		{return STRING_LITERAL;}
{comment}				{}
[ \t\n\v\r\f] 			{}
. 						{return -1;}
%%