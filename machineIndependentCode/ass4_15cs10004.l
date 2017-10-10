%{
#include "ass4_15cs10004_translator.h"
#include "y.tab.h"
#include <math.h>
void yyerror (char *);  /* prints grammar violation message */
%}
%option noyywrap
/* Regular Expression Definitions */
_IDENTIFIER 		[a-zA-Z_][a-zA-Z_0-9]*
NON__ZERO_CONSTANT_DIGIT		[1-9]
DIGIT_SEQUENCE 		[0-9]+
SIGN 				[+-]
EXPONENT_PART		([Ee]{SIGN}?{DIGIT_SEQUENCE})
_ZERO_CONSTANT 		[0]
INTEGER_CONST 		{NON__ZERO_CONSTANT_DIGIT}{DIGIT_SEQUENCE}*
FLOATING_CONST		({FRACTIONAL_CONST}{EXPONENT_PART}?)|({DIGIT_SEQUENCE}{EXPONENT_PART})
FRACTIONAL_CONST 	(({DIGIT_SEQUENCE})?\.{DIGIT_SEQUENCE})|(({DIGIT_SEQUENCE})\.)
ESCAPE_SEQUENCE		\\['"?\\abfnrtv]
C_CHAR				[^'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE		{C_CHAR}+
CHAR_CONSTANT		\'{C_CHAR_SEQUENCE}\'
STRINGLITERAL		\"{C_CHAR_SEQUENCE}*?\"
COMMENT				"//".*|[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/] 
WHITESPACE  		[ \t\v\n\f]
%%
"break"         { return BREAK; }
"case"          { return CASE; }
"char"          { return CHAR; }
"const"         { return CONST; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"do"            { return DO; }
"double"        { return DOUBLE; }
"else"          { return ELSE; }
"float"         { return FLOAT; }
"for"           { return FOR; }
"goto"          { return GOTO; }
"if"            { return IF; }
"int"           { return INT; }
"long"          { return LONG; }
"return"        { return RETURN; }
"short"         { return SHORT; }
"signed"        { return SIGNED; }
"sizeof"        { return SIZEOF; }
"switch"        { return SWITCH; }
"unsigned"      { return UNSIGNED; }
"void"          { return VOID; }
"volatile"      { return VOLATILE; }
"while"         { return WHILE; }
"Bool"          { return BOOL; }
"Matrix" 		{ return MATRIX;}
"["				{ return '['; }
"]"				{ return ']'; }
"("				{ return '('; }
")"				{ return ')'; }
"{"				{ return '{'; }
"}"				{ return '}'; }
"."				{ return '.'; }
"->"			{ return PTR_OP; }
"++"			{ return INC_OP; }
"--"			{ return DEC_OP; }
"&"				{ return '&'; }
"*"				{ return '*'; }
"+"				{ return '+'; }
"-"				{ return '-'; }
"~"				{ return '~'; }
"!"				{ return '!'; }
"/"				{ return '/'; }
"%"				{ return '%'; }
"<<"			{ return LEFT_OP; }
">>"			{ return RIGHT_OP; }
"<"				{ return '<'; }
">"				{ return '>'; }
"<="			{ return LE_OP; }
">="			{ return GE_OP; }
"=="			{ return EQ_OP; }
"!="			{ return NE_OP; }
"^"				{ return '^'; }
"|"				{ return '|'; }
"&&"			{ return AND_OP; }
"||"			{ return OR_OP; }
"?"				{ return '?'; }
":"				{ return ':'; }
";"				{ return ';'; }
".'"			{ return DOTCOMMA;} // the transpose opn
"="				{ return '='; }
"*="			{ return MUL_ASSIGN; }
"/="			{ return DIV_ASSIGN; }
"%="			{ return MOD_ASSIGN; }
"+="			{ return ADD_ASSIGN; }
"-="			{ return SUB_ASSIGN; }
"<<="			{ return LEFT_ASSIGN; }
">>="			{ return RIGHT_ASSIGN; }
"&="			{ return AND_ASSIGN; }
"^="			{ return XOR_ASSIGN; }
"|="			{ return OR_ASSIGN; }
","				{ return ','; }
"#"				{ return '#'; }
{STRINGLITERAL} { 	yylval.stringValue = yytext;
					return STRING_LITERAL; }
{CHAR_CONSTANT}	{  yylval.charValue = yytext;
					return CHAR_CONSTANT; }
{_IDENTIFIER}			{	yylval.symp = symbolTable->lookup(yytext);
					return IDENTIFIER;  }
{INTEGER_CONST} { 	yylval.integerValue = atoi(yytext);
					return INT_CONSTANT; }
{_ZERO_CONSTANT} { 	yylval.integerValue = 0;
					return ZERO_CONSTANT; }
{FLOATING_CONST} { 	yylval.stringValue = yytext;
					return FLOAT_CONSTANT; }
{COMMENT}		{/* comment to be ignored */}
{WHITESPACE}	{ /* whitespace separates tokens */ }
%%
