 %{ 
 	/* C Declarations and Definitions */
	#include <string.h>
	#include <stdio.h>
	#include "ass4_15cs10004_translator.h"
	extern	int yylex();
	extern bool TRANSPOSE;
	extern bool INIT;
	void yyerror(const char *s);
	extern typeEnum TYPE;
%}


%union {
	int integerValue;
	int instr;
	char* charValue;
	char* stringValue;
	float floatingValue;
	symbol* symp;
	expr* exp;
	vector<int>* nl;
	symbType* st;
	statement* stat;
	unary* A;
	char uop;	//unary operator
}
%token RIGHT_ASSIGN LEFT_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN
%token DIV_ASSIGN MOD_ASSIGN AND_ASSIGN XOR_ASSIGN EQ_ASSIGN OR_ASSIGN RIGHT_OP LEFT_OP DOTCOMMA // DOTCOMMA == transpose operation
%token INC_OP DEC_OP PTR_OP AND_OP OR_OP LE_OP GE_OP EQ_OP NE_OP
%token <symp>IDENTIFIER  PUNCTUATORS COMMENT 
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID MATRIX
%token BOOL 
%token BREAK CASE CONTINUE DEFAULT DO IF ELSE FOR GOTO WHILE SWITCH SIZEOF
%token RETURN

%token <integerValue>INT_CONSTANT ZERO_CONSTANT	
%token <stringValue> FLOAT_CONSTANT 
%token <charValue>CHAR_CONSTANT
%token <stringValue> STRING_LITERAL
%token <symp> MULTICOMMENT


%start translation_unit
   	
// Expressions
%type <A> postfix_expression
	unary_expression
	cast_expression
%type <exp>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	and_expression
	exclusive_or_expression
	inclusive_or_expression
	logical_and_expression
	logical_or_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <uop> unary_operator
%type <symp> constant initializer initializer_row_list initializer_row

%type <instr> M
%type <instr> check
%type <exp> N
%type <st> pointer
%type <symp> direct_declarator init_declarator declarator
%type <integerValue> argument_expression_list
%type <stat> iteration_statement
	jump_statement
	block_item
	block_item_list  
	statement
	labeled_statement 
	compound_statement
	selection_statement

%%
primary_expression
	: IDENTIFIER {
		string debug = getDebugString("87","IDENTIFIER");
		//cout<<debug<<endl; //debug
		$$ = new expr();
		$$->symp = $1;
		$$->setisbool(0);
	}
	| constant {
		symbol* tempe = new symbol("temp");
		$$ = new expr();
		$$->symp = $1;
	}
	| STRING_LITERAL {
		symbol *tempe = new symbol("tempVar");
		$$ = new expr();
		$$->symp = gentemp(PTR, $1);
		$$->symp->initialize($1);
		string debug = getDebugString("99","in string_literal");	//cout<<debug<<endl; //debug
		$$->symp->type->ptr = new symbType(_CHAR);
	}
	| '(' expression ')' {
		$$ = $2;
	}
	;

constant
	: INT_CONSTANT {
		$$ = gentemp(_INT, NUMBERTOSTRING($1));
		string debug = getDebugString("111 "," int constatn");
		emit(EQUAL, $$->getname(), $1);
	}
	| ZERO_CONSTANT {
		$$ = gentemp(_INT, NUMBERTOSTRING($1));
		emit(EQUAL, $$->getname(), $1);
	}
	| FLOAT_CONSTANT {
		if(INIT != 1){
		$$ = gentemp(_DOUBLE, *new string ($1));
		string debug = getDebugString("121 ","float_constant");
		//cout<<debug<<endl;
		emit(EQUAL, $$->getname(), *new string($1));
		}
		else{
			string debug = "in float constant else";
			//cout<<debug<<endl;
		
			$$ = new symbol(*new string ($1),_DOUBLE);
			$$->init = *new string ($1);
		}
		
	}
	| CHAR_CONSTANT{
		$$ = gentemp(_CHAR , $1);
		string debug = getDebugString("136"," in char constant");  //cout<<debug<<endl;
		emit(EQUAL, $$->getname(), $1);
	}
	;

postfix_expression
	: primary_expression  {
		$$ = new unary ();
		$$->type = $1->symp->type;
		$$->setcat($$->type->cat);
		$$->symp = $1->symp;
		$$->loc = $$->symp;
	}
	| postfix_expression '[' expression ']''[' expression ']' {
		$$ = new unary();
		symbol *temp = new symbol("temp");
		$$->symp = $1->symp;			// copy the base
		$$->type = $1->type->ptr;    	// type = type of element
		$$->loc = new symbol("",_INT);		// store computed address
		// New address = already computed + $3 * new width
		if ($1->getcat()==_MATRIX) {		// if something already computed
			symbol* t = gentemp(_INT);
 			emit(MULTIPLY, t->getname(), $3->symp->getname(), NUMBERTOSTRING(8));
 			string debug  = getDebugString("159",t->getname());
 			//cout<<debug<<endl;
 			symbol* u = gentemp(_INT);
 			emit(SUB, u->getname(), t->getname(), NUMBERTOSTRING(8));
 			t = gentemp(_INT);
 			emit(MATRIXR,t->name,$1->symp->getname(),NUMBERTOSTRING(4));
 			debug  = getDebugString("159",t->getname());
 			//cout<<debug<<endl;
 			symbol* v = gentemp(_INT);
 			emit(MULTIPLY,v->getname(),u->name, t->getname());
 			t = gentemp(_INT);
 			emit(MULTIPLY, t->getname(), $6->symp->getname(), NUMBERTOSTRING(8));
 			debug = getDebugString(t->getname()," 171 "+$6->symp->getname());
 			//cout<<debug<<endl;
 			u = gentemp(_INT);
 			emit(ADD, u->getname(), t->getname(), v->getname());
 			t = gentemp(_INT);
 			$$->loc->setname(t->name);
 			$$->type->cat=_INT;
 			emit(ADD, t->name, u->getname() , NUMBERTOSTRING(8));
 			debug  = getDebugString("179",t->getname());
 			//cout<<debug<<endl;
		}
 		else {
	 		emit(MULTIPLY, $$->loc->getname(), $3->symp->getname(), NUMBERTOSTRING(calSizeOfType($$->type)));
 		}
 		// Mark that it contains array address and first time computation is done
		$$->setcat(_MATRIX);
		$$->symp->type->cat = _MATRIX;
	}
	| postfix_expression '(' ')' {symbol* tempe = new symbol("temp");}
	| postfix_expression '(' argument_expression_list ')' {
		$$ = new unary();
		$$->symp = gentemp($1->type->cat);
		symbol* tempe = new symbol("temp");
		emit(CALL, $$->symp->getname(), $1->symp->getname(), tostr($3));
	}
	| postfix_expression '.' IDENTIFIER /* Ignored */
	| postfix_expression PTR_OP IDENTIFIER  /* Ignored */
	| postfix_expression INC_OP { 
		$$ = new unary();

		if($1->symp->type->cat==_MATRIX){
			symbol* t = gentemp(_DOUBLE);
			//derefrencing the  matrix
			emit(MATRIXR, t->getname(), $1->symp->name, $1->loc->getname());
			string debug  = getDebugString("205",t->getname());
 			//cout<<debug<<endl;
			symbol* u =  gentemp(_DOUBLE);
			emit (ADD, u->getname(), t->getname(), "1");
			debug  = getDebugString("209",t->getname());
 			//cout<<debug<<endl;
			emit(MATRIXL, $1->symp->getname(),$1->loc->getname(),u->getname());
			$$->symp = t;
		}
		else{
			// copy $1 to $$
			$$->symp = gentemp($1->symp->type->cat);
			emit (EQUAL, $$->symp->getname(), $1->symp->getname());
			string debug  = getDebugString("218",$$->symp->getname());
 			//cout<<debug<<endl;
			// Increment $1
			emit (ADD, $1->symp->getname(), $1->symp->getname(), "1");
		}
	}
	| postfix_expression DEC_OP {
		$$ = new unary();

		if($1->symp->type->cat==_MATRIX){
			symbol* t = gentemp(_DOUBLE);
			//derefrencing the  matrix
			emit(MATRIXR, t->getname(), $1->symp->getname(), $1->loc->getname());
			string debug  = getDebugString("231",t->getname());
 			//cout<<debug<<endl;
			emit (SUB, t->name, t->getname(), "1");
			emit(MATRIXL, $1->symp->name,$1->loc->getname(),t->getname());
		    debug  = getDebugString("235",$1->symp->getname());
 			//cout<<debug<<endl;
			$$->symp = t;
		}
		else{
			// copy $1 to $$
			$$->symp = gentemp($1->symp->type->cat);
			emit (EQUAL, $$->symp->getname(), $1->symp->getname());

			// Decrement $1
			emit (SUB, $1->symp->getname(), $1->symp->getname(), "1");
		}
	}
	| postfix_expression DOTCOMMA {
		string temp = $1->symp->getname();
		// for transpose set the flag to true 
		int row = $1->type->getrows();
		int col = $1->type->getcols();
		//cout<<col<<" "<<row;
		string debug  = getDebugString("254","int DOTCOMMA");
 		//cout<<debug<<endl;
		$$->symp = gentemp($1->type,"",true);
		//$1->type->row = row;
		//$1->type->col = col;
		$$->symp->size = row*col*8 + 8;
		$$->symp->type->setrows(col);
		$$->symp->type->setcols(row);
		emit(_DOTCOMMA,$$->symp->getname(),temp);
		TRANSPOSE = true;
	}
	;

argument_expression_list
	: assignment_expression {
		emit (PARAM, $1->symp->name);
		$$ = 1; symbol* tempe = new symbol("tempVar");}
	| argument_expression_list ',' assignment_expression {
		emit (PARAM, $3->symp->getname());
		string debug  = getDebugString("273",$3->symp->getname());
 			//cout<<debug<<endl;
		$$ = $1+1;
	}
	;
unary_expression
	: postfix_expression {
		$$ = $1;
//		debug ($$->symp);
	}
	| INC_OP unary_expression {
		// Increment $1
		if($2->symp->type->cat==_MATRIX){
			symbol* t = gentemp(_DOUBLE);
			//derefrencing the  matrix
			emit(MATRIXR, t->getname(), $2->symp->getname(), $2->loc->getname());
			emit (ADD, t->getname(), t->getname(), "1");
			string debug  = getDebugString("290");
 			//cout<<debug<<endl;
			emit(MATRIXL, $2->symp->getname(),$2->loc->getname(),t->getname());
		}
		else{
			emit (ADD, $2->symp->getname(), $2->symp->getname(), "1");
		}
		// Use the same value
		$$ = $2;
	}
	| DEC_OP unary_expression {
		// Decrement $1
		if($2->symp->type->cat==_MATRIX){
			symbol* t = gentemp(_DOUBLE);
			//derefrencing the  matrix
			emit(MATRIXR, t->getname(), $2->symp->getname(), $2->loc->getname());
			emit (SUB, t->getname(), t->getname(), "1");
			emit(MATRIXL, $2->symp->getname(),$2->loc->getname(),t->getname());
		}
		else
		{emit (SUB, $2->symp->getname(), $2->symp->getname(), "1");
			string debug  = getDebugString("311","in dec_op-");
 			//cout<<debug<<endl;
		}
		symbol *tempe = new symbol("tempVar");
		// Use the same value
		$$ = $2; 
	}
	| unary_operator cast_expression {
		$$ = new unary();	symbol *tempe = new symbol("tempVar");
		switch ($1) {
			case '&':
				$$->symp = gentemp(PTR);
				$$->symp->type->ptr = $2->symp->type; 
				emit (ADDRESS, $$->symp->getname(), $2->symp->getname());
				//string temp  = getDebugString("325",$$->symp->getname());
 				//cout<<temp<<endl;	
				break;
			case '*':
				$$->setcat(PTR);
				$$->loc = gentemp ($2->symp->type->ptr);
				emit (PTRR, $$->loc->getname(), $2->symp->getname());
				$$->symp = $2->symp;
				break;
			case '+':
				$$ = $2;
				break;
			case '-':
				$$->symp = gentemp($2->symp->type->cat);
				emit (UNARY_MINUS, $$->symp->getname(), $2->symp->getname());
				break;
			default:
				break;
		}
	}
	;

unary_operator
	: '&' {
		$$ = '&';
	}
	| '*' {
		$$ = '*';
	}
	| '+' {
		$$ = '+';
	}
	| '-' {
		$$ = '-';
	}
	;
cast_expression
	: unary_expression  {
		$$ = $1;
	}
	;
multiplicative_expression
	: cast_expression {
		// Now the cast expression can't go to LHS of assignment_expression
		// So we can safely store the rvalues of pointer and arrays in temporary
		// We don't need to carry lvalues anymore
		$$ = new expr();
		if ($1->cat==_MATRIX) { // MATRIX
			if(!TRANSPOSE && $1->type->cat!=_INT){
				//cout<<"343"<<endl;
				symbType *ts=new symbType($1->getcat(),NULL,0);
				ts->setrows($1->symp->type->row);
				ts->col = $1->symp->type->getcols();
				$$->symp = gentemp(ts,"",false,true);
				string debug  = getDebugString("379","in cast_expression");
 				//cout<<debug<<endl;
				emit(MATRIXR, $$->symp->getname(), $1->symp->getname(), $1->loc->getname());
			}
			else{
				if(!TRANSPOSE && $1->type->cat==_INT){
					$$->symp = gentemp(_DOUBLE);
					string debug  = getDebugString("386","in the else");//cout<<debug<<endl;
					emit(MATRIXR, $$->symp->getname(), $1->symp->getname(), $1->loc->getname());
				}
				else{
					$$->symp = $1->symp;
					symbol *tempe = new symbol("tempVar"); tempe->name = "tempVar";
				}
			}
		}
		else if ($1->getcat()==PTR) { // Pointer
			$$->symp = $1->loc;
			symbol* tempe = $$->symp;;
		}
		else { // otherwise
			$$->symp = $1->symp;
		}
	}
	| multiplicative_expression '*' cast_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			symbol *tempe = new symbol("tempVar"); tempe->name = "tempVar";
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			string debug  = getDebugString("406","mult*cast");//cout<<debug<<endl;
			emit (MULTIPLY, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	| multiplicative_expression '/' cast_expression{
		if (typecheck ($1->symp, $3->symp) ) {
			symbol* tempe = new symbol("tempVar");
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			string debug  = getDebugString("415","mult/cast");
 			//cout<<debug<<endl;
			emit (DIVIDE, $$->symp->getname(), $1->symp->getname(), $3->symp->name);
		}
		else cout << "Type Error"<< endl;
	}
	| multiplicative_expression '%' cast_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			symbol* tempe = new symbol("tempVar");
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (MODOP, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;
additive_expression
	: multiplicative_expression {$$ = $1;}
	| additive_expression '+' multiplicative_expression {
		if (typecheck($1->symp, $3->symp)) {
			$$ = new expr();
			symbol* tempe = new symbol("tempVar");
			$$->symp = gentemp($1->symp->type->cat);
			string debug  = getDebugString("438","additive + mult");
 			//cout<<debug<<endl;
			emit (ADD, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	| additive_expression '-' multiplicative_expression {
		if (typecheck($1->symp, $3->symp)) {
			$$ = new expr();
			symbol* tempe = new symbol("tempVar");
			$$->symp = gentemp($1->symp->type->cat);
			string debug  = getDebugString("448");
 			//cout<<debug<<endl;
			emit (SUB, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;
shift_expression
	: additive_expression {$$ = $1;}
	| shift_expression LEFT_OP additive_expression {
		if ($3->symp->type->cat == _INT) {
			symbol* tempe = new symbol("tempVar");
			$$ = new expr();
			$$->symp = gentemp (_INT);
			string debug  = getDebugString("462","in LEFTOP");
 					//cout<<debug<<endl;
			emit (LEFTOP, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	| shift_expression RIGHT_OP additive_expression {
		if ($3->symp->type->cat == _INT) {
			$$ = new expr();
			$$->symp = gentemp (_INT);
			string debug  = getDebugString("472");
 					//cout<<debug<<endl;
			emit (RIGHT_SHIFT_OP, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;

relational_expression
	: shift_expression { $$ = $1; symbol *tempe = new symbol("tempVar");}
	| relational_expression '<' shift_expression {
		symbol *tempe = new symbol("tempVar");
	// check here if its of type _matrix if yes then do MATRIXR
		if (typecheck ($1->symp, $3->symp) ) {
			// New bool
			$$ = new expr();
			$$->setisbool(1);
			symbol* tempe = new symbol("tempVar");
			string debug  = getDebugString("490");
 			//cout<<debug<<endl; 
			$$->settrueList(makeList (nextinstr()));
			$$->setfalseList(makeList (nextinstr()+1));
			emit(LT, "", $1->symp->getname(), $3->symp->getname());
			tempe = new symbol("tempVar");
			emit (GOTOOP, "");   }
		else cout << "Type Error"<< endl;
	}
	| relational_expression '>' shift_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// New bool
			$$ = new expr();
			$$->setisbool(1);
			symbol* tempe = new symbol("tempVar");
			tempe->getname() = "temp"; 
			string debug  = getDebugString("506");
 					//cout<<debug<<endl;
			$$->settrueList(makeList (nextinstr()));
			$$->falseList = makeList (nextinstr()+1);
			emit(GREATER_THAN, "", $1->symp->getname(), $3->symp->getname());
			emit (GOTOOP, "");
		}
		else cout << "Type Error"<< endl;
	}
	| relational_expression LE_OP shift_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// New bool
			$$ = new expr();
			$$->setisbool(1);

			$$->settrueList(makeList (nextinstr()));
			symbol* tempe = new symbol("tempVar");
			string debug  = getDebugString("523");
 					//cout<<debug<<endl;
			tempe->getname() = "temp"; 
			$$->setfalseList(makeList (nextinstr()+1));
			emit(LE, "", $1->symp->getname(), $3->symp->getname());
			emit (GOTOOP, "");
		}
		else cout << "Type Error"<< endl;
	}
	| relational_expression GE_OP shift_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// New bool
			$$ = new expr();
			$$->setisbool(1);
			symbol* tempe = new symbol("tempVar");
			tempe->getname() = "temp"; 
			$$->settrueList(makeList (nextinstr()));
			$$->setfalseList(makeList (nextinstr()+1));
			string debug  = getDebugString("541","GE_OP");
 					//cout<<debug<<endl;
			emit(GREATER_THAN_EQUAL, "", $1->symp->getname(), $3->symp->getname());
			emit (GOTOOP, ""); tempe = new symbol("tempVar");
		}
		else cout << "Type Error"<< endl;
	}
	;

equality_expression
	: relational_expression {$$ = $1;}
	| equality_expression EQ_OP relational_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// If any is bool get its value
			convertFromBoolean ($1);
			convertFromBoolean ($3);
			string debug  = getDebugString("557","EQOP");
 					//cout<<debug<<endl;
			$$ = new expr();
			$$->setisbool(1);
			symbol* tempe = new symbol("tempVar");
			tempe->getname() = "temp"; 
			$$->settrueList(makeList (nextinstr()));
			$$->setfalseList(makeList (nextinstr()+1));
			emit (EQOP, "", $1->symp->getname(), $3->symp->getname());
			emit (GOTOOP, "");
		}
		else cout << "Type Error"<< endl;
	}
	| equality_expression NE_OP relational_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// If any is bool get its value
			convertFromBoolean ($1);
			convertFromBoolean ($3);
			string debug  = getDebugString("575");
 					//cout<<debug<<endl;
			$$ = new expr();
			$$->setisbool(1);
			
			$$->settrueList(makeList (nextinstr()));
			$$->falseList = makeList (nextinstr()+1);
			symbol* tempe = new symbol("tempVar");
			tempe->name = "temp"; 
			emit (NEOP, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
			emit (GOTOOP, "");
		}
		else cout << "Type Error"<< endl;
	}
	;

and_expression
	: equality_expression {$$ = $1;}
	| and_expression '&' equality_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			$$ = new expr();
			$$->setisbool(0);
			string debug  = getDebugString("597");
 					//cout<<debug<<endl;
			$$->symp = gentemp (_INT);
			emit (BAND, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;

exclusive_or_expression
	: and_expression {$$ = $1;}
	| exclusive_or_expression '^' and_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// If any is bool get its value
			convertFromBoolean ($1);
			convertFromBoolean ($3);
			string debug  = getDebugString("613","XOR");
 					//cout<<debug<<endl;
			$$ = new expr();
			symbol* temp = new symbol("tempVar");
			$$->setisbool(0);
			debug  = getDebugString("619");
 					//cout<<debug<<endl;
			$$->symp = gentemp (_INT);
			emit (XOR, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;

inclusive_or_expression
	: exclusive_or_expression {$$ = $1;}
	| inclusive_or_expression '|' exclusive_or_expression {
		if (typecheck ($1->symp, $3->symp) ) {
			// If any is bool get its value
			symbol* temp = new symbol("tempVar");
			convertFromBoolean ($1);
			convertFromBoolean ($3);
			string debug  = getDebugString("635","OR opn");
 					//cout<<debug<<endl;
			$$ = new expr();
			$$->setisbool(0);
			
			$$->symp = gentemp (_INT);
			emit (INOR, $$->symp->getname(), $1->symp->getname(), $3->symp->getname());
		}
		else cout << "Type Error"<< endl;
	}
	;

logical_and_expression
	: inclusive_or_expression {$$ = $1;}
	| logical_and_expression N AND_OP M inclusive_or_expression {
		convertToBoolean($5);
		symbol* temp = new symbol("tempVar");
			temp->name = "temp";
		// N to convert $1 to bool
		backpatch($2->getnextList(), nextinstr());
		convertToBoolean($1);
		$$ = new expr();
		$$->setisbool(1);
		backpatch($1->gettrueList(), $4);
		string debug  = getDebugString("659");
 					//cout<<debug<<endl;
		$$->settrueList($5->gettrueList());
		$$->setfalseList(merge ($1->falseList, $5->falseList)); }
	;

logical_or_expression
	: logical_and_expression {$$ = $1;}
	| logical_or_expression N OR_OP M logical_and_expression {
		convertToBoolean($5);
		symbol* temp = new symbol("tempVar");
			temp->getname() = "temp";
		// N to convert $1 to bool
		backpatch($2->getnextList(), nextinstr());
		convertToBoolean($1);

		$$ = new expr();
		$$->setisbool(1);
		string debug  = getDebugString("677","logical Or ");
 					//cout<<debug<<endl;
		backpatch ($$->falseList, $4);
		$$->settrueList(merge ($1->trueList, $5->trueList));
		symbol* tempvar = new symbol("tempVar");
		tempvar->getname() = "temp";
		$$->setfalseList($5->getfalseList());}
	;

M 	: %empty{	// To store the address of the next instruction for further use.
		$$ = nextinstr(); };

N 	: %empty { 	// Non terminal to prevent fallthrough by emitting a goto
		//debug ("n");
		$$  = new expr();
		$$->setnextList(makeList(nextinstr()));
		emit (GOTOOP,""); }

conditional_expression
	: logical_or_expression {$$ = $1;}
	| logical_or_expression N '?' M expression N ':' M conditional_expression {
		$$->symp = gentemp();
		string debug  = getDebugString("700","conditional_expression");
 					//cout<<debug<<endl;
		$$->symp->update($5->symp->type);
		emit(EQUAL, $$->symp->getname(), $9->symp->getname());
		vector<int> l = makeList(nextinstr());
		emit (GOTOOP, "");
		backpatch($6->getnextList(), nextinstr());
		emit(EQUAL, $$->symp->getname(), $5->symp->getname());
		debug  = getDebugString("709",$$->symp->getname());
 					//cout<<debug<<endl;
		vector<int> m = makeList(nextinstr());
		l = merge (l, m);
		emit (GOTOOP, "");
		string debug_2  = getDebugString("701");
 					//cout<<debug_2<<endl;
 		symbol* tempe = new symbol("tempVar");
		backpatch($2->getnextList(), nextinstr());
		convertToBoolean ($1);
		backpatch ($1->gettrueList(), $4);
		backpatch ($1->getfalseList(), $8);
		backpatch (l, nextinstr());}
	;

assignment_expression
	: conditional_expression { symbol *tempe = new symbol("tempVar");
		$$ = $1;}
	| unary_expression assignment_operator assignment_expression {
		symbol* tempe;
		switch ($1->getcat()) {
			case _MATRIX:  // do MATRIXL
				if(!TRANSPOSE){
					//cout<<"aman 2";
					$3->symp = conv($3->symp, $1->type->cat);
					tempe = new symbol("tempVar");
					tempe->name = "temp"; 
					string debug  = getDebugString("733");
 					//cout<<debug<<endl;
					emit(MATRIXL, $1->symp->getname(), $1->loc->getname(), $3->symp->getname());	
					break;
				}
				else{
					$3->symp = conv($3->symp, $1->symp->type->cat);
					tempe = new symbol("tempVar");
					tempe->name = "temp"; 
					string debug  = getDebugString("742");
 					//cout<<debug<<endl;
					emit(EQUAL, $1->symp->getname(), $3->symp->getname());
					TRANSPOSE = false;
					break;}
			case PTR:
				emit(PTRL, $1->symp->getname(), $3->symp->getname());	
				tempe = $1->symp; 
				break;
			default:
				$3->symp = conv($3->symp, $1->symp->type->cat);  
				emit(EQUAL, $1->symp->getname(), $3->symp->getname()); tempe = $3->symp;
				break; symbol* tempe = new symbol("tempVar");}
		$$ = $3;}
	;
assignment_operator
	: '='
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	;

expression
	: assignment_expression {$$ = $1; symbol* tempe = $1->symp;}
	| expression ',' assignment_expression{}
	;

constant_expression
	: conditional_expression
	{}
	;

/*** Declaration ***/

declaration
	: declaration_specifiers ';' {
		string debug  = getDebugString("786","in declaration_spec ;");
 					//cout<<debug<<endl;
	}
	| declaration_specifiers init_declarator_list ';' {}
	;

declaration_specifiers
	: type_specifier
	| type_specifier declaration_specifiers{}
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator {
		string debug  = getDebugString("800","init_declator_list");
 					//cout<<debug<<endl;
	}
	;

init_declarator
	: declarator {$$ = $1;}
	| declarator '=' initializer {
		if ($3->init!="") $1->initialize($3->init);
		emit (EQUAL, $1->getname(), $3->getname()); }
	;

type_specifier
	: VOID {	TYPE = _VOID;}
	| CHAR {	TYPE = _CHAR;}
	| SHORT
	| INT {		TYPE = _INT;}
	| LONG
	| FLOAT
	| DOUBLE {	TYPE = _DOUBLE;}
	| MATRIX {	TYPE = _MATRIX;}
	| SIGNED
	| UNSIGNED
	| BOOL   {}
	;
declarator
	: pointer direct_declarator { 
	    symbType * t = $1;
		while (t->ptr !=NULL) t = t->ptr;
		string debug  = getDebugString("830","direct-declatro");
 					//cout<<debug<<endl;
		t->ptr = $2->type;
		$$ = $2->update($1);  
		}
	| direct_declarator
	;
direct_declarator
	: IDENTIFIER {symbol *tempe = new symbol("tempVar");
		$$ = $1->update(TYPE);
		currSymbol = $$;
		string debug  = getDebugString("840","in IDENTIFIER");}
 			//cout<<debug<<endl; }
	| '(' declarator ')' { $$ = $2; }	
	| direct_declarator '[' assignment_expression ']' '[' assignment_expression ']'  {
		symbType * t = $1 -> type;
		symbType * prev = NULL;
		while (t->cat == ARR) {
			prev = t;
			t = t->ptr;
		}
		string debug  = getDebugString("850","in direst_delarator");
 					//cout<<debug<<endl;
		if (prev==NULL) {
			int row = atoi($3->symp->init.c_str());
			int col = atoi($6->symp->init.c_str());
			symbType* s = new symbType(_MATRIX, $1->type,row);
			debug  = getDebugString("856");
 					//cout<<debug<<endl;
			s->setrows(row);
			s->setcols(col);
			int y = calSizeOfType(s);	
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new symbType(ARR, t, atoi($3->symp->init.c_str()));
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator '(' CST parameter_type_list ')' {
		symbolTable->settname($1->getname());
		symbol* tempe = new symbol("tempVar");
			tempe->name = "temp"; 
		if ($1->type->cat !=_VOID) {
			symbol *s = symbolTable->lookup("retVal");
			s->update($1->type);		}
		string debug  = getDebugString("875");
 					//cout<<debug<<endl;
		$1 = $1->linkst(symbolTable);

		symbolTable->setparent(globalSymbolTable);
		changeTable (globalSymbolTable);				// Come back to globalsymbol symbolTable

		currSymbol = $$;						
	}
	| direct_declarator '(' identifier_list ')' { /* Ignored */}
	| direct_declarator '(' CST ')' {		
		symbolTable->settname($1->getname());			// Update function symbol symbolTable name

		if ($1->type->cat !=_VOID) {
			symbol *s = symbolTable->lookup("retVal");// Update type of return value
			s->update($1->type);
		}
		string debug  = getDebugString("892","in direct declator");
 					//cout<<debug<<endl;
		//cout<<temp<<endl;
		$1 = $1->linkst(symbolTable);		// Update type of function in global symbolTable
	
		symbolTable->setparent(globalSymbolTable);
		changeTable (globalSymbolTable);				// Come back to globalsymbol symbolTable
		debug  = getDebugString("899");
 					//cout<<debug<<endl;
		//cout<<temp<<endl;
		currSymbol = $$;
	}
	;

CST : %empty { // Used for changing to symbol symbolTable for a function
		if (currSymbol->nest==NULL) changeTable(new symbTable(""));	// Function symbol symbolTable doesn't already exist
		else {
			string debug  = getDebugString("909","in CST");
 					//cout<<debug<<endl;
			//cout<<temp<<endl; //fordebug
			changeTable (currSymbol ->nest);						// Function symbol symbolTable already exists
			emit (LABEL, symbolTable->gettname());
		}
	}
	;

pointer
	: '*' {	$$ = new symbType(PTR); }
	| '*' pointer {	$$ = new symbType(PTR, $2);}
	;

parameter_type_list
	: parameter_list{}
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration {
	string debug  = getDebugString("930","param list ");
 					//cout<<debug<<endl;
	}
	;

parameter_declaration
	: declaration_specifiers declarator {	$2->varCategory = "param";}
	| declaration_specifiers{
		string debug  = getDebugString("938","in declaration spec");
 					//cout<<debug<<endl;
	}
	;

identifier_list
	: IDENTIFIER 
	| identifier_list ',' IDENTIFIER
	;

initializer
	: assignment_expression {	$$ = $1->symp;}
	| '{' check initializer_row_list '}' {
		$$ = $3;
		string temp = "{" + $3->getinit() + "}";
		string str = $3->getinit();
		bool flag = false;
		int row =1,col = 1,i;
		for(i=0;i<str.size();i++){
			if(str[i]==','&&!flag){
				col++;
			}
			else{
				if(str[i]==';'){
					flag = true;
					row++;
				}
			}
		}
		$$->setinit(temp);
		
		string debug  = getDebugString("969");
 					//cout<<debug<<endl;
		//cout<<debug<<endl;
		symbType *t=new symbType(_MATRIX,NULL,0);
        t->row=row;
        t->setcols(col);
        symbol* tempe = new symbol("tempVar");
        debug  = getDebugString("976");
 					//cout<<debug<<endl;
        symbol *t1= gentemp(t,$$->init,false,false,true);
        $$->setname(t1->getname());
		INIT = false;
	}
	;
check: %empty {	INIT = true;}
initializer_row_list:	initializer_row {
							$$ = $1; }
						|initializer_row_list ';' initializer_row{
							string temp = $1->getinit() + ";" + $3->getinit();
							//cout<<temp<<endl;
							$$ = $1;
							$$->init = temp;
						}	
						;
initializer_row: initializer{
					$$ = $1;}
				|initializer_row ',' initializer {
					string temp = $1->init + "," + $3->init;
					$$ = $1;
					$$->setinit(temp);
					string debug  = getDebugString("999","initializer_row");
 					//cout<<debug<<endl;
				}
				;

statement
	: labeled_statement /* Skipped */
	| compound_statement {	$$ = $1;}
	| expression_statement {
		$$ = new statement();
		string debug  = getDebugString("1009","expression statement");
 					//cout<<debug<<endl;
		$$->setnextList($1->getnextList());
	}
	| selection_statement {	$$ = $1;}
	| iteration_statement {	$$ = $1;}
	| jump_statement {	$$ = $1;}
	;

labeled_statement /* Ignored */
	: IDENTIFIER ':' statement {$$ = new statement(); symbol* tempe = new symbol("tempVar");}
	| CASE constant_expression ':' statement {$$ = new statement();}
	| DEFAULT ':' statement {$$ = new statement();}
	;

compound_statement
	: '{' '}' { $$ = new statement();}
	| '{' block_item_list '}' {	$$ = $2; symbol* tempe = new symbol("tempVar"); }
	;

block_item_list
	: block_item {	$$ = $1;	symbol* tempe = new symbol("tempVar");}
	| block_item_list M block_item {
		string debug  = getDebugString("1032","block_item_list");
 					//cout<<debug<<endl;
		$$ = $3;
		backpatch ($1->getnextList(), $2);
	}
	;

block_item
	: declaration { 	$$ = new statement();symbol* tempe = new symbol("tempVar");}
	| statement {		$$ = $1;}
	;

expression_statement
	: ';' {	$$ = new expr();}
	| expression ';' {	$$ = $1;
		string debug  = getDebugString("1047","in expression");
 					//cout<<debug<<endl;
	}
	;

selection_statement
	: IF '(' expression N ')' M statement N {
		//backpatch ($8->getnextList(), nextinstr());
		convertToBoolean($3);
		$$ = new statement();
		backpatch ($3->gettrueList(), $6);
		string debug  = getDebugString("1058","in if stat");
 					//cout<<debug<<endl;
		//cout<<tempString<<endl; 		//forDebug
		vector<int> temp = merge ($3->falseList, $7->nextList);
		symbol* tempe = new symbol("tempVar"); 
		$$->setnextList((merge ($8->nextList, temp)));
		
	}
	| IF '(' expression N ')' M statement N ELSE M statement {
		backpatch ($8->getnextList(), nextinstr());
		convertToBoolean($3);
		$$ = new statement();
		symbol* tempe = new symbol("tempVar");
		string debug  = getDebugString("1071","if n else statement");
 					//cout<<debug<<endl;
		backpatch ($3->gettrueList(), $6);
		string tempString = "in if else stat";
		//cout<<tempString<<endl;			//forDebug
		backpatch ($3->falseList, $10);
		vector<int> temp = merge ($7->nextList, $8->nextList);
		debug  = getDebugString("1078");
 					//cout<<debug<<endl;
		$$->setnextList(merge (temp, $11->nextList));
	}
	| SWITCH '(' expression ')' statement /* Skipped */{ 
	symbol* tempe = new symbol("tempVar");
	}
	;

iteration_statement 	
	: WHILE M '(' expression ')' M statement { 
		$$ = new statement();
		convertToBoolean($4);
		// M1 to go back to boolean again
		// M2 to go to statement if the boolean is true
		backpatch($7->getnextList(), $2);
		string debug  = getDebugString("1092","while state");
 					//cout<<debug<<endl;
		backpatch($4->gettrueList(), $6);
		symbol* tempe = new symbol("tempVar");
			tempe->name = "temp"; 
		debug  = getDebugString("1097","while state");
 					//cout<<debug<<endl;
		$$->setnextList($4->getfalseList());
		// Emit to prevent fallthrough
		emit (GOTOOP, tostr($2));
	}
	| DO M statement M WHILE '(' expression ')' ';' {
		symbol* tempe = new symbol("tempVar");
		$$ = new statement();
		convertToBoolean($7);
		tempe = new symbol("tempVar");
		// M1 to go back to statement if expression is true
		// M2 to go to check expression if statement is complete
		backpatch ($7->gettrueList(), $2);
		backpatch ($3->getnextList(), $4);
		string debug  = getDebugString("1111","in DO while state");
 					//cout<<debug<<endl;
		// Some bug in the next statement
		$$->setnextList($7->getfalseList());

	}
	| FOR '(' expression_statement M expression_statement ')' M statement {
		$$ = new statement();
		symbol* tempe = new symbol("tempVar");
		convertToBoolean($5);
		backpatch ($5->gettrueList(), $7);
		backpatch ($8->getnextList(), $4);
		string debug  = getDebugString("1123","FOR 2 PARA");
 					//cout<<debug<<endl; 
		emit (GOTOOP, tostr($4));
		$$->setnextList($5->getfalseList());
	}
	| FOR '(' expression_statement M expression_statement M expression N ')' M statement {
		$$ = new statement();
		convertToBoolean($5);	
		symbol* tempe = new symbol("tempVar");
			tempe->name = "temp"; 
		backpatch ($5->gettrueList(), $10);
		backpatch ($8->getnextList(), $4);
		string debug  = getDebugString("1138","FOR 3 PARAM");
 					//cout<<debug<<endl;
		backpatch ($11->getnextList(), $6);
		emit (GOTOOP, tostr($6));
		$$->setnextList($5->getfalseList());
	}
	;
jump_statement /* Ignored except return */
	: GOTO IDENTIFIER ';' {$$ = new statement();}
	| CONTINUE ';' {$$ = new statement(); symbol *temp = new symbol("tempVar");}
	| BREAK ';' {$$ = new statement();}
	| RETURN ';' { $$ = new statement();
		string debug  = getDebugString("1149");
 					//cout<<debug<<endl;
		emit(_RETURN,"");
	}
	| RETURN expression ';'{
		$$ = new statement();
		string debug  = getDebugString("1155","return expression");
 					//cout<<debug<<endl;
			emit(_RETURN,$2->symp->getname());
	}
	;

translation_unit
	: external_declaration 
	| translation_unit external_declaration {
	string debug  = getDebugString("1164","translation_unit external_declaration ");
 					//cout<<debug<<endl;
		
	}
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list CST compound_statement {
	symbol* tempe = new symbol("tempVar");
	}
	| declaration_specifiers declarator CST compound_statement {
		symbolTable->setparent(globalSymbolTable);
		string debug  = getDebugString("1175","declaration spec CST");
 					//cout<<debug<<endl;
		changeTable (globalSymbolTable);
	}
	;
declaration_list
	: declaration
	| declaration_list declaration
	;

%%

void yyerror(const char *s) {
	printf ("ERROR: %s",s);
}
