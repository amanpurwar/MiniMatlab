%{	
	#include "y.tab.h"
	#include <stdio.h>
	extern int yylex();
	extern FILE *yyin;
	extern char *yytext;
	void yyerror(const char *s);
%}
%start	start
%define parse.error verbose
%define parse.lac full
%token	BREAK
%token	CASE
%token	CHAR
%token	CONTINUE
%token	DEFAULT
%token 	DO
%token 	DOUBLE
%token 	ELSE
%token	FLOAT
%token 	FOR
%token 	GOTO
%token 	IF
%token 	INT
%token 	LONG
%token 	RETURN
%token 	SHORT
%token 	SIGNED
%token 	SWITCH
%token  UNSIGNED
%token  VOID
%token  WHILE
%token  BOOL
%token 	MATRIX
%token 	IDENTIFIER
%token 	CONSTANT
%token 	STRING_LITERAL
%token 	COMMENT
%token 	INCREMENT
%token	ARROW
%token	LTE
%token 	GTE
%token	LEFTSHIFT
%token 	RIGHTSHIFT
%token	MULTIPLY
%token 	DIVIDE
%token 	REMAINDER
%token 	ADD
%token 	SUBTRACT
%token  LEFTSHIFTEQUAL
%token	DECREMENT
%token  EQUALITY
%token  RIGHTSHIFTEQUAL
%token	NE
%token  BITAND
%token 	POWER
%token	AND
%token 	OR
%token	OREQUAL
%token 	DOTCOMMA
%nonassoc "then"
%nonassoc ELSE

%%
start:	translation_unit
		;

primary_expression:	 IDENTIFIER
						{printf("primary_expresiion: IDENTIFIER\n");}
					| STRING_LITERAL
						{printf("primary_expresiion: STRING_LITERAL\n");}
					| CONSTANT
						{printf("primary_expresiion: INTEGER_CONSTANT\n");}
					| '(' expression ')'
						{printf("primary_expresiion: ( expression )\n");}
					;
postfix_expression:	 primary_expression
						{printf("postfix_expression:	 primary_expression\n");}
					| postfix_expression '[' expression ']'
						{printf("postfix_expression:	 postfix_expression [ expression ]\n");}
                    | postfix_expression '(' argument_expression_list ')'
						{printf("postfix_expression:	 postfix_expression ( argument_expression_list )\n");}
					| postfix_expression '('  ')'
						{printf("postfix_expression:	 postfix_expression (  )\n");}
					| postfix_expression '.' IDENTIFIER
						{printf("postfix_expression:	 postfix_expression . IDENTIFIER\n");}
					| postfix_expression ARROW IDENTIFIER
						{printf("postfix_expression:	 postfix_expression -> IDENTIFIER\n");}
					| postfix_expression INCREMENT
						{printf("postfix_expression:	 postfix_expression ++\n");}
					| postfix_expression DECREMENT
						{printf("postfix_expression:	 postfix_expression --\n");}
					| postfix_expression DOTCOMMA
						{printf("postfix_expression:	 postfix_expression .'\n");}
					;
argument_expression_list:	assignment_expression
								{printf("argument_expression_list:	assignment_expression\n");}
							| argument_expression_list ',' assignment_expression
								{printf("argument_expression_list:	argument_expression_list , assignment_expression\n");}
							;
unary_expression:	postfix_expression
						{printf("unary_expression:	postfix_expression\n");}
					| INCREMENT unary_expression
						{printf("unary_expression:	++ unary_expression\n");}
                    | DECREMENT unary_expression
                        {printf("unary_expression:	-- unary_expression\n");}
					| unary_operator cast_expression
						{printf("unary_expression:	unary_operator cast_expression\n");}
					;
unary_operator: 	'&'
						{printf("unary_operator:	&\n");}
					| '*'
						{	printf("unary_operator:	*\n");}
					| '+'
						{printf("unary_operator:	+\n");}
					| '-' 
						{printf("unary_operator:	-\n");}
					;
cast_expression:	unary_expression
						{printf("cast_expression:	unary_expression\n");}
					;
multiplicative_expression:	cast_expression
								{printf("multiplicative_expression:	cast_expression\n");}
							| multiplicative_expression '*' cast_expression
								{printf("multiplicative_expression:	multiplicative_expression * cast_expression\n");}
							| multiplicative_expression '/' cast_expression
								{printf("multiplicative_expression:	multiplicative_expression / cast_expression\n");}
							| multiplicative_expression '%' cast_expression
								{printf("multiplicative_expression:	multiplicative_expression % cast_expression\n");}
							;
additive_expression:	multiplicative_expression
							{printf("additive_expression:	multiplicative_expression\n");}
						| additive_expression '+' multiplicative_expression
							{printf("additive_expression:	additive_expression + multiplicative_expression\n");}
						| additive_expression '-' multiplicative_expression
							{printf("additive_expression:	additive_expression - multiplicative_expression\n");}
						;
shift_expression:	additive_expression
						{printf("shift_expression:	additive_expression\n");}
					| shift_expression LEFTSHIFT additive_expression
						{printf("shift_expression:	shift_expression << additive_expression\n");}
					| shift_expression RIGHTSHIFT additive_expression
						{printf("shift_expression:	shift_expression >> additive_expression\n");}
					;
relational_expression:	shift_expression
							{printf("relational_expression:	shift_expression\n");}
						| relational_expression '<' shift_expression
							{printf("relational_expression:	relational_expression < shift_expression\n");}
						| relational_expression '>' shift_expression
							{printf("relational_expression:	relational_expression > shift_expression\n");}
						| relational_expression LTE shift_expression
							{printf("relational_expression:	relational_expression <= shift_expression\n");}
						| relational_expression GTE shift_expression
							{printf("relational_expression:	relational_expression >= shift_expression\n");}
						;
equality_expression:	relational_expression
							{printf("equality_expression:	relational_expression\n");}
						| equality_expression EQUALITY relational_expression
							{printf("equality_expression:	equality_expression == relational_expression\n");}
						| equality_expression NE relational_expression
							{printf("equality_expression:	equality_expression != relational_expression\n");}
						;
AND_expression:	equality_expression
					{printf("AND_expression:	equality_expression\n");}
				| AND_expression '&' equality_expression
					{printf("AND_expression:	AND_expression & equality_expression\n");}
				;

exclusive_OR_expression:	AND_expression
								{printf("exclusive_OR_expression:	AND_expression\n");}
							| exclusive_OR_expression '^' AND_expression
								{printf("exclusive_OR_expression:	exclusive_OR_expression ^ AND_expression\n");}
							;
inclusive_OR_expression:	exclusive_OR_expression
								{printf("inclusive_OR_expression:	exclusive_OR_expression\n");}
							| inclusive_OR_expression '|' exclusive_OR_expression
								{printf("inclusive_OR_expression:	inclusive_OR_expression | exclusive_OR_expression\n");}
							;
logical_AND_expression:	inclusive_OR_expression
								{printf("logical_AND_expression:	inclusive_OR_expression\n");}
						| logical_AND_expression AND inclusive_OR_expression
								{printf("logical_AND_expression:	logical_AND_expression && inclusive_OR_expression\n");}
						;
logical_OR_expression:	logical_AND_expression
								{printf("logical_OR_expression:	logical_AND_expression\n");}
						| logical_OR_expression OR logical_AND_expression
								{printf("logical_OR_expression:	logical_OR_expression || logical_AND_expression\n");}
						;
conditional_expression:	logical_OR_expression
								{printf("conditional_expression:	logical_OR_expression\n");}
						| logical_OR_expression '?' expression ':' conditional_expression
								{printf("conditional_expression:	logical_OR_expression ? expression : conditional_expression\n");}
						;
assignment_expression:	conditional_expression
							{printf("assignment_expression:	conditional_expression\n");}
						| unary_expression assignment_operator assignment_expression
							{printf("assignment_expression:	unary_expression assignment_operator assignment_expression\n");}
						;
assignment_operator: '='
						{printf("assignment_operator: =\n");}
					| MULTIPLY 
						{printf("assignment_operator: *=\n");}
					| DIVIDE 
						{printf("assignment_operator: /=\n");}
					| REMAINDER 
						{printf("assignment_operator: %=\n");}
					| ADD
						{printf("assignment_operator: +=\n");} 
					| SUBTRACT 
						{printf("assignment_operator: -=\n");}
					| LEFTSHIFTEQUAL 
						{printf("assignment_operator: <<=\n");}
					| RIGHTSHIFTEQUAL 
						{printf("assignment_operator: >>=\n");}
					| BITAND
						{printf("assignment_operator: &=\n");} 
					| POWER
						{printf("assignment_operator: ^=\n");} 
					| OREQUAL
						{printf("assignment_operator: |=\n");}
					;
expression:	assignment_expression
				{printf("expression:	assignment_expression\n");}
			| expression ',' assignment_expression
				{printf("expression:	expression , assignment_expression\n");}
			;
expression_opt:%empty
					{printf("expression_opt:	%%empty\n");}
				|expression		
					{{printf("expression_opt:	expression\n");}}	
constant_expression:	conditional_expression
							{printf("constant_expression:	conditional_expression\n");}
						;

declaration:declaration_specifiers ';'
				{printf("declaration: declaration_specifiers ;\n");}
			| declaration_specifiers init_declarator_list ';'
				{printf("declaration: declaration_specifiers init_declarator_list;\n");}
			;
declaration_specifiers
	:type_specifier 
		{printf("declaration_specifiers: type_specifier \n");}
	|type_specifier declaration_specifiers
		{printf("declaration_specifiers: type_specifier declaration_specifiers\n");}
	;
init_declarator_list:	init_declarator
							{printf("init_declarator_list:	init_declarator\n");}
						| init_declarator_list ',' init_declarator
							{printf("init_declarator_list:	init_declarator_list , init_declarator\n");}
						;
init_declarator:	declarator
						{printf("init_declarator:	declarator\n");}
					| declarator '=' initializer
						{printf("init_declarator:	declarator = initializer\n");}
					;
type_specifier:	VOID
					{printf("type_specifier:	VOID\n");}
				| CHAR
					{printf("type_specifier:	CHAR\n");}
				| SHORT
					{printf("type_specifier:	SHORT\n");}
				| INT
					{printf("type_specifier:	INT\n");}
				| LONG
					{printf("type_specifier:	LONG\n");}
				| FLOAT
					{printf("type_specifier:	FLOAT\n");}
				| DOUBLE
					{printf("type_specifier:	DOUBLE\n");}
				| MATRIX
					{printf("type_specifier:	MATRIX\n");}
				| SIGNED
					{printf("type_specifier:	SIGNED\n");}
				| UNSIGNED
					{printf("type_specifier:	UNSIGNED\n");}
				| BOOL
					{printf("type_specifier:	BOOL\n");}
				;
declarator
	: pointer direct_declarator
		{printf("declarator: pointer direct_declarator\n");}
	| direct_declarator
		{printf("declarator: direct_declarator\n");}
	;
direct_declarator:	IDENTIFIER
						{printf("direct_declarator:	IDENTIFIER\n");}
					|'(' declarator ')'
						{printf("direct_declarator:	( declarator )\n");}
					|direct_declarator '[' ']'
						{printf("direct_declarator:	direct_declarator [  ]\n");}
					|direct_declarator '[' assignment_expression ']'
						{printf("direct_declarator:	direct_declarator [ assignment_expression ]\n");}
					|direct_declarator '(' parameter_type_list ')'
						{printf("direct_declarator:	direct_declarator ( parameter_type_list )\n");}
					|direct_declarator '(' identifier_list ')'
						{printf("direct_declarator:	direct_declarator ( identifier_list )\n");}
					|direct_declarator '('  ')'
						{printf("direct_declarator:	direct_declarator (  )\n");}
					;
pointer:	'*' 
				{printf("pointer:	* \n");}
			|'*'pointer
				{printf("pointer:	*pointer\n");}
			;
parameter_type_list:	parameter_list
							{printf("parameter_type_list:	parameter_list\n");}
						;

parameter_list:	parameter_declaration
					{printf("parameter_list:	parameter_declaration\n");}
				|parameter_list ',' parameter_declaration
					{printf("parameter_list:	parameter_list , parameter_declaration\n");}
				;

parameter_declaration:	declaration_specifiers declarator
							{printf("parameter_declaration:	declaration_specifiers declarator\n");}
						|declaration_specifiers
							{printf("parameter_declaration:	declaration_specifiers\n");}
						;

identifier_list:	IDENTIFIER
						{printf("identifier_list:	IDENTIFIER\n");}	
					|identifier_list ',' IDENTIFIER
						{printf("identifier_list:	identifier_list , IDENTIFIER\n");}	
					;
initializer:	assignment_expression
					{printf("initializer:	assignment_expression\n");}	
				|'{' initializer_row_list '}'
					{printf("initializer:	{ initializer_row_list }\n");}		
				;
initializer_row_list:	initializer_row
							{printf("initializer_row_list:	initializer_row\n");}	
						|initializer_row_list ';' initializer_row
							{printf("initializer_row_list:	initializer_row\n");}	
						;
initializer_row:designation_opt initializer
						{printf("initializer_row:	designation_opt initializer\n");}
				|initializer_row ',' designation_opt initializer 
						{printf("initializer_row:	initializer_row ',' designation_opt initializer\n");}
				;
designation:	designator_list '='
					{printf("designation:	designator_list =\n");}	
				;
designation_opt: %empty
					{printf("designation_opt:	%%empty\n");}
				|designation
					{printf("designation_opt:	 designation\n");}
				;
designator_list:	designator
						{printf("designator_list:	designator \n");}
					|designator_list designator
						{printf("designator_list:	designator_list designator\n");}
					;
designator:	'[' constant_expression ']'
				{printf("designator:	[ constant_expression ] \n");}
			|'.' IDENTIFIER
				{printf("designator:	. IDENTIFIER \n");}
			;
statement:	labeled_statement
				{printf("statement:	labeled_statement \n");}
			|compound_statement
				{printf("statement:	compound_statement\n");}
			|expression_statement
				{printf("statement:	expression_statement \n");}
			|selection_statement
				{printf("statement:	selection_statement\n");}
			|iteration_statement
				{printf("statement:	iteration_statement\n");}
			|jump_statement
				{printf("statement:	jump_statement\n");}
			;
labeled_statement:	IDENTIFIER ':' statement
						{printf("labeled_statement:	IDENTIFIER : statement \n");}
					|CASE constant_expression ':' statement
						{printf("labeled_statement:	CASE constant_expression : statement \n");}
					|DEFAULT ':' statement
						{printf("labeled_statement:	DEFAULT : statement \n");}
					;

compound_statement:	'{' block_item_list '}'
						{printf("compound_statement:	{ block_item_list } \n");}
					|'{''}'
						{printf("compound_statement:	{  } \n");}
					;
block_item_list:	block_item
						{printf("block_item_list:	block_item \n");}
					|block_item_list block_item
						{printf("block_item_list:	block_item_list block_item \n");}
					;

block_item:	declaration
				{printf("block_item:	declaration  \n");}
			|statement
				{printf("block_item:	statement  \n");}
			;
expression_statement:	expression';' 
							{printf("expression_statement:	expression ;  \n");}
						|';'
							{printf("expression_statement:	; \n");}
						;
selection_statement:	IF '(' expression ')' statement   	%prec "then"
							{printf("selection_statement:	IF ( expression ) statement\n");}
						|IF '(' expression ')' statement ELSE statement
							{printf("selection_statement:	IF ( expression ) statement ELSE statement\n");}
						|SWITCH '(' expression ')' statement
							{printf("selection_statement:	SWITCH ( expression ) statement\n");}
						;
iteration_statement:	WHILE '(' expression ')' statement
							{printf("iteration_statement:	WHILE ( expression ) statement\n");}
						|DO statement WHILE '(' expression ')' ';'
							{printf("iteration_statement:	DO statement WHILE ( expression ) ;\n");}
						|FOR '(' expression_opt ';' expression_opt ';' expression_opt ')' statement
							{printf("iteration_statement:	FOR ( expression_opt ; expression_opt ; expression_opt ) statement\n");}
						|FOR '(' declaration expression_opt ';' expression_opt ')' statement
							{printf("iteration_statement:	FOR ( declaration expression_opt ; expression_opt ) statement\n");}
						;
jump_statement:	GOTO IDENTIFIER ';'
					{printf("jump_statement:	GOTO IDENTIFIER ;\n");}
				|CONTINUE ';'
					{printf("jump_statement:	CONTINUE ;\n");}
				|BREAK ';'
					{printf("jump_statement:	BREAK ;\n");}
				|RETURN expression_opt ';'
					{printf("jump_statement:	RETURN expression_opt ;\n");}
				;
translation_unit:	external_declaration
						{printf("translation_unit:	external_declaration\n");}
					|translation_unit external_declaration
						{printf("translation_unit:	translation_unit external_declaration\n");}
					;
external_declaration:	function_definition
							{printf("external_declaration:	function_definition\n");}
						|declaration
							{printf("external_declaration:	declaration\n");}
						;
declaration_list:	declaration
						{printf("declaration_list:	declaration\n");}
					|declaration_list declaration
						{printf("declaration_list:	declaration_list declaration\n");}
					;
declaration_list_opt: %empty
						{printf("declaration_list_opt:	%%empty\n");}
					|declaration_list
						{printf("declaration_list_opt:	declaration_list\n");}
function_definition:	declaration_specifiers declarator declaration_list_opt compound_statement
							{printf("function_definition:	declaration_specifiers declarator declaration_list_opt compound_statement\n");}
					;
%%
void yyerror(const char *s) {
printf("%s\n",s);
}

