#include "ass4_15cs10004_translator.h"

/************ Global variables *************/

symbTable* globalSymbolTable;					// Global Symbbol Table
quads qarr;										// Quads array
typeEnum TYPE;									// Stores latest type specifier
bool TRANSPOSE = false;							// variable to check if a transpose expresion is being parsed
bool INIT = false;								// variable to check if an initializer expresion is being parsed
symbTable* symbolTable;							// Points to current symbol symbolTable
symbol* currSymbol; 							// points to latest function entry in symbol symbolTable

/*
	function to calculate the sizeof the given symbol table type
	i/p param : symbtype
	o/p : size of the given symbol table variable
*/
int calSizeOfType (symbType* t){ 				
	if(t->cat==_VOID){
		return 0;
	}else 
	if(t->cat ==_CHAR){
		return SIZE_OF_CHAR;
	}else
	if(t->cat==_INT){
		return SIZE_OF_INT;
	}else
	if(t->cat==_DOUBLE){
		return SIZE_OF_DOUBLE;
	}else
	if(t->cat==PTR){
		return SIZE_OF_POINTER;
	}else
	if(t->cat==_MATRIX){
		return t->row * t->col *SIZE_OF_DOUBLE + 8; 			// 8 for the two variables row and col 
	}
	else{
		return 0;
	}
}
/*
 	func to get the string value of the variable type while printing the symbol table
 	i/p: a symbol type t
 	o/p: the string corresponding to it for the symbol table
*/
string getStringValue (const symbType* t){
	if (t==NULL) return "null";
	if(t->cat==_VOID){
		return "void";
	}else 
	if(t->cat ==_CHAR){
		return "char";
	}else
	if(t->cat==_INT){
		return "int";
	}else
	if(t->cat==_DOUBLE){
		return "double";
	}else
	if(t->cat==PTR){
		return "ptr("+ getStringValue(t->ptr)+")";
	}else
	if(t->cat==_MATRIX){
		return "Matrix("+ tostr(t->row)+","+tostr(t->col)+",double)";
	}else
	if(t->cat==FUNC){
		return "funct";
	}else{
		return "type";
	}
}

/*
	symbtype constructor 
	i/p: category , ptr and width
*/
symbType::symbType(typeEnum cat, symbType* ptr, int width){
	this->cat = cat;
	this->ptr = ptr;
	setwidth(width);
	this->transpose = false;
}
/*
	setter function of the symbtype class variable width 

*/
void symbType::setwidth(int width){
	this->width = width;
}
/*
	getter function for the width variable
*/
int symbType::getwidth(){
	return this->width;
}
// getter setter functions 
void symbType::setcols(int cols){
	col = cols;
}
int symbType::getcols(){
	return this->col;
}
void symbType::setrows(int rows){
	row = rows;
}
int symbType::getrows(){
	return this->row;
}
void symbType::settranspose(bool transpose){
	this->transpose = transpose;
}
bool symbType::gettranspose(){
	return this->transpose;
}

/*
	lookup function for searching the vraible 'name' in the symbol table 
	return it if present else create a new vriable with 'name' and return that.
	i/p: name of the symbol
	o/p: the poiinter to that symbol table element 
*/
symbol* symbTable::lookup (string name) {
	list <symbol>::iterator it;
	it = symbolTable.begin();
	string nameString = name;
	while(it!=symbolTable.end()){
		if (it->name == name ) break;
		it++;
	}
	if (it!=symbolTable.end() ) {
		return &*it;
	}
	else {
			string debug = getDebugString("134"," in lookup else");
			//cout<<debug<<endl;
			symbol* s;
			s =  new symbol (name);
			s->varCategory = "local";
			symbolTable.push_back (*s);
			return &symbolTable.back();	
	}
}
/*
	func to get the debug string given the loc (line number) and the message( val)
	i/p: line number(loc) , message (val)
	o/p: debug string
*/
string getDebugString(string loc,string val){
	if(val != ""){
		string temp = loc + val + "\n";
		return temp;
	}
	return loc;
}

/*
	function to generate a temp variable of type t and based on various flags and init value
	flag transpose : if the var created is used for the transpose matrix storage
	flag matrix_temp: for the var to be created for the matrix binary opn like : m = n+p; //where m,n,p are matrix of dim n*m
	flag init_matrix: for the var created for the matrix iniitalization
	i/p: type t, initial value string and the flags
	o/p: the pointer to the temporary varaible created 
*/
symbol* gentemp (symbType* t, string init,bool transpose,bool matrix_temp,bool init_matrix) {
	char n[20];
	sprintf(n, "t%02d", symbolTable->tempVarCount++);
	symbol* s = new symbol (n);
	if(!matrix_temp && !transpose){
		s->type = t;
		s->setinit(init);
	}
	if(transpose){					// reversing the rows and cols while transposing 
		s->type->row = t->col;
		s->type->col = t->row;
		s->size = t->row*t->col*8 + 8;
		s->type->cat = _MATRIX;
	}
	if(matrix_temp || init_matrix){
		s->type = t;
		s->size = t->row*t->col*8 + 8;
	}
	s->varCategory = "temp";
	if(t->cat!=_MATRIX ||transpose || matrix_temp || init_matrix){
		symbolTable->symbolTable.push_back ( *s);
		s->init = "";
	}
	else{
		symbolTable->tempVarCount--;
	}
	return &symbolTable->symbolTable.back();
}
/*
	an overloaded gentemp function used for 
	creating a temp variable for a typeEnum and init string with no special flags 
	i/p: typeEnum t, initial value string init
	o/p: the pointer to the temporary varaible created 
*/
symbol* gentemp (typeEnum t, string init) {
	char n[20];
	sprintf(n, "t%02d", symbolTable->tempVarCount++);
	symbol* s = new symbol (n, t);
		s->offset = 0;
		string temp = "temp";
		s->setinit(init);
	s->varCategory = temp;
	if(t!=_MATRIX){
		s->offset = 0;
		symbolTable->symbolTable.push_back ( *s);
	}
	else{
		symbolTable->tempVarCount--;
	}
	s->offset = 0;
	return &symbolTable->symbolTable.back();
}

/*
	symbTable constructor with a name as param
*/
symbTable::symbTable (string name){
	settname(name);
	this->tempVarCount = 0;
}
/*
	func to print the symbol table completely and recursively. it prints the symbol table with the 
	help of operator overloading '<<' for neat printing of the table and its elements
	param 'all' tells if to print the complete table along with all the nested tables also or just the single symbol table
	i/p: all (default value 0)
*/
void symbTable::print(int all) {
	list<symbTable*> tableList;
	int i=0;
	for(i=0;i<120;i++){
		cout<<"#";
	}
	string tnameString = gettname();
	string parentString = "Parent: ";
	cout<<endl;
	cout << "Symbol Table : " << setfill (' ') << left << setw(35)  << gettname();
	cout << right << setw(20) << parentString;
	if (this->parent!=NULL)
		cout << this -> parent->tname;
	else cout << "null" ;
	cout << endl;
	
	for(i=0;i<120;i++){
		cout<<"-";
	}
	cout<<endl;
	string nameString = "Name";
	cout << setfill (' ') << left << setw(16) << nameString;
	string typeString = "Type";
	cout << left << setw(32) << typeString;
	cout << left << setw(12) << "Category";
	string initValString = "Init Val";
	cout << left << setw(32) << initValString;
	cout << left << setw(8) << "Size";
	string OffsetString = "Offset";
	cout << left << setw(8) << OffsetString;
	cout << left;
	printf("Nest");
	cout<<endl;
	for(i=0;i<120;i++){
		cout<<"-";
	}
	cout<<endl;
	list <symbol>::iterator it = symbolTable.begin();
	while(it!=symbolTable.end()){
		cout << &*it;
		if (it->nest!=NULL) tableList.push_back (it->nest);				// add if there is a nested table present 
		it++;
	}
	for(i=0;i<120;i++){
		cout<<"-";
	}
	cout<<endl;
	cout<<endl;
	/*
		if all == 1 , print the nested tables also and when printing the nested table all will be set to 0
	*/
	if (all) {
		list<symbTable*>::iterator iterator = tableList.begin();
		while(iterator != tableList.end()){
			 (*iterator)->print();
			 ++iterator;
		}		
	}
}
/*
	function to calculate and store the offsets in the symbol table; calculates using the sizes
	i/p: none 
*/
void symbTable::calculateOffsets() {
	list<symbTable*> tableList;
	int off;
	list<symbol>::iterator it = symbolTable.begin();
	while(it!=symbolTable.end()){
		if (it==symbolTable.begin()) {
			int offsetValue = 0;
			it->offset = offsetValue;
			off = it->size;
		}
		else {
			it->offset = off;
			int offsetValue = it->offset + it->size;;
			off = offsetValue;
		}
		if (it->nest!=NULL) tableList.push_back (it->nest);
		it++;
	}
	list<symbTable*>::iterator iterator = tableList.begin(); 
	while(iterator != tableList.end()){
		(*iterator)->calculateOffsets();
		++iterator;
	}
}

// getter and setter implemantation
void symbTable::settname(string tnameVal){
	tname = tnameVal;
}
string symbTable::gettname(){
	return this->tname;
}
void symbTable::settcount(int tempVarCountVal){
	tempVarCount = tempVarCountVal;
}
int symbTable::gettcount(){
	return this->tempVarCount;
}
void symbTable::setparent(symbTable* parentVal){
	parent = parentVal;
}
symbTable* symbTable::getparent(){
	return this->parent;
}
//#3333333333333333###############################################################################################################3 ask C
/*
	function to link the nested symbolTable to the current symbol Table
	i/p: symbtable t ( to be linked)

*/
symbol* symbol::linkst(symbTable* t) {
	this->nest = t;
	this->varCategory = "function";
}
/*
	'<<' operator overloading for neat printing takes a ostream and a symbType for printing 
	it returns the ostream parameter so that you can connect << expressions together avoiding creating a new "cout" when using the one global cout 
	i/p: ostream& and symbol t
	o/p: ostream parameter
*/
ostream& operator<<(ostream& os, const symbType* t) {
	typeEnum cat = t->cat;
	ostream& op = os;
	string debug = getDebugString("354"," in operator <<");
	//cout<<debug<<endl;  //debug
	string stype = getStringValue(t);
	op << stype;
	return op;
}
/*
	'<<' operator overloading for neat printing takes a ostream and a symbol for printing 
	it return the ostream parameter so that you can connect << expressions together avoiding creating a new "cout" when using the one global cout 
	i/p: ostream& and symbol t
*/
ostream& operator<<(ostream& os, const symbol* it) {
	string init = it->init;
	int size = it->size;
	int offset = it->offset;
	ostream& op = os;
	op << left << setw(16) << it->name;
	op << left << setw(32) << it->type;
	string debug = getDebugString("372"," in operator <<");
	//cout<<debug<<endl;  //debug
	op << left << setw(12) << it->varCategory;
	ostream& op2 = os;
	op2 << left << setw(32) << init;
	op2 << left << setw(8) << size;
	op2 << left << setw(8) << offset;
	op2 << left;
	string nullString = "null";
	if (it->nest == NULL) {
		op2 << nullString <<  endl;	
	}
	else {
		debug = getDebugString("387"," in operator <<  else");
	//cout<<debug<<endl;  //debug
		op2 << it->nest->tname <<  endl;
	}
	return op2;
}
// getter and setter 
void statement::setnextList(vector<int> nextlist){
	nextList = nextlist;
}
vector<int> statement::getnextList(){
	return this->nextList;
}
// constructor
quad::quad (string result, string arg1, opTypeEnum op, string arg2):
	result (result), arg1(arg1), arg2(arg2), op (op){};

quad::quad (string result, int arg1, opTypeEnum op, string arg2):
	result (result), arg2(arg2), op (op) {
		this ->arg1 = NUMBERTOSTRING(arg1);
	}
//constructor
void quad::setop(opTypeEnum opType){
	op = opType;
}
opTypeEnum quad::getop(){
	return this->op;
}
void quad::setresult(string res){
	result = res;
}
string quad::getresult(){
	return this->result;
}
void quad::setarg1(string arg1Val){
	arg1 = arg1Val;
}
string quad::getarg1(){
	return this->arg1;
}

/*
	a function to initialize the symbol value to init
	i/p: intial value
	o/p: updated symbol value 
*/
symbol* symbol::initialize (string init) {
	this->init = init;
}
/*
	method to update different fields of an existing entry 
	i/p: symbtype t to be updated
	o/p: updated symbtype value 
*/
symbol* symbol::update(symbType* t) {
	type = t;
	string updateVal = "update";
	this -> size = calSizeOfType(t);
	return this;
}
// constructor
symbol::symbol (string name, typeEnum t, symbType* ptr, int width){
	type = new symbType (symbType(t, ptr, width));
	this->name = name;
	nest = NULL;
	init = "";
	varCategory = "";
	offset = 0;
	size = calSizeOfType(type);
}
//getter and setter
void symbol::setname(string nameVal){
	name = nameVal;
}
string symbol::getname(){
	return this->name;
}
void symbol::setinit(string initVal){
	init = initVal;
}
string symbol::getinit(){
	return this->init;
}
void symbol::setcategory(string varCategoryVal){
	varCategory = varCategoryVal;
}
string symbol::getcategory(){
	return this->varCategory;
}
void symbol::setsize(int size){
	this->size = size;
}
int symbol::getsize(){
	return this->size;
}

/*
	 Used for backpatching  the quad result address
	 i/p: the address to be updated
	 o/p: void 
*/
void quad::update (int addr) {	
	this ->result = addr;
}

/*
	method to update different fields of an existing symbol entry
	i/p: the type t
	o/p: updated symbol pointer  
*/
symbol* symbol::update(typeEnum t) {
	this->type = new symbType(t);
	string temp = getDebugString("495"," in the symbol update");
	//cout<<temp<<endl;
	this->size = calSizeOfType(this->type);
	return this;
}
//getter setter 
void symbol::setoffset(int offsetVal){
	offset = offsetVal;
}
int symbol::getoffset(){
	return this->offset;
}

/*
	func to print the single quad completely
*/
void quad::print () {
	switch(op) {
		// Shift Operations
		case LEFTOP:		cout << result << " = " << arg1 << " << " << arg2;				break;
		case RIGHT_SHIFT_OP:		cout << result << " = " << arg1 << " >> " << arg2;				break;
		case EQUAL:			cout << result << " = " << arg1 ;								break;
		// Binary Operations
		case INOR:			cout << result << " = " << arg1 << " | " << arg2;				break;
		case BAND:			cout << result << " = " << arg1 << " & " << arg2;				break;
		case MULTIPLY:			cout << result << " = " << arg1 << " * " << arg2;				break;
		case DIVIDE:		cout << result << " = " << arg1 << " / " << arg2;				break;
		case ADD:			cout << result << " = " << arg1 << " + " << arg2;				break;
		case SUB:			cout << result << " = " << arg1 << " - " << arg2;				break;
		case XOR:			cout << result << " = " << arg1 << " ^ " << arg2;				break;
		case MODOP:			cout << result << " = " << arg1 << " % " << arg2;				break;
		// Relational Operations
		case EQOP:			cout << "if " << arg1 <<  " == " << arg2 << " goto " << result;				break;
		case NEOP:			cout << "if " << arg1 <<  " != " << arg2 << " goto " << result;				break;
		case GREATER_THAN_EQUAL:			cout << "if " << arg1 <<  " >= " << arg2 << " goto " << result;				break;
		case LE:			cout << "if " << arg1 <<  " <= " << arg2 << " goto " << result;				break;
		case LT:			cout << "if " << arg1 <<  " < "  << arg2 << " goto " << result;				break;
		case GREATER_THAN:			cout << "if " << arg1 <<  " > "  << arg2 << " goto " << result;				break;
		case GOTOOP:		cout << "goto " << result;						break;
		//Unary Operators
		case B_NOT:			cout << result 	<< " = ~" << arg1;				break;
		case PTRL:			cout << "*" << result	<< " = " << arg1 ;		break;
		case UNARY_MINUS:		cout << result 	<< " = -" << arg1;				break;
		case CALL: 			cout << result << " = " << "call " << arg1<< ", " << arg2;				break;
		case LABEL:			cout << result << ": ";					break;
		case ADDRESS:		cout << result << " = &" << arg1;				break;
		case PTRR:			cout << result	<< " = *" << arg1 ;				break;
		case LNOT:			cout << result 	<< " = !" << arg1;				break;

		case MATRIXR:	{if(arg1==arg2) cout << result << " = " << arg1;		
						else cout << result << " = " << arg1 << "[" << arg2 << "]";			break;	} 	
			
		case MATRIXL:	{ if(result == arg1) cout << result << " = " << arg2;	
						else cout << result << "[" << arg1 << "]" <<" = " <<  arg2;			break;}
		case _RETURN: 		cout << "ret " << result;				break;
		case PARAM: 		cout << "param " << result;				break;
		case _DOTCOMMA: 	cout << result << " = "<<arg1<<".'"; 	break;
		default:			printf("op");							break;
	}
	cout << endl;
}
/*
	function to print the quads corresponding to a Label 
	i/p / o/p: none
*/
void quads::printtab() {
	cout << "=== Quad Table ===" << endl;
	string indexString = "index";
		cout << setw(8) << indexString;
	cout << setw(8) << " op";
	cout << setw(8) << "arg 1";
	string argString = "arg 2";
	cout << setw(8) << argString;
	string resultString = "result";
	cout << setw(8) << resultString << endl;
	vector<quad>::iterator it = array.begin();
	while(it!=array.end()){
		cout << left << setw(8) << it - array.begin(); 
		cout << left << setw(8) << opToString(it->op);
		string temp = getDebugString("575","inQuad::PrintTab");
		//cout<<temp<<endl; //to debug
		cout << left << setw(8) << it->arg1;
		cout << left << setw(8) << it->arg2;
		cout << left << setw(8) << it->result << endl;
		it++;
	}
}
/*
	function to insert addr as the target label for each of the quad ’s on the list given to by l
	i/p: list l , int address
	o/p: void

*/
void backpatch (vector<int> l, int addr) {
	vector<int>::iterator it= l.begin();
	while(it!=l.end()){
		qarr.array[*it].result = tostr(addr);
		it++;
	}
}
/*
	prints all the quads corresponding to all the labesls
	i/p|o/p: void
*/
void quads::print () {
	int i=0;
	for(i=0;i<30;i++){
		cout<<"#";
	}
	cout<<endl;
	cout << "Quad Translation" << endl;
	for(i=0;i<30;i++){
		cout<<"-";
	}
	cout<<endl;
	vector<quad>::iterator it = array.begin();
	while(it!=array.end()){
		if (it->op != LABEL) {
			cout << "\t" << setw(4) << it - array.begin() << ":\t";
			it->print();
		}
		else {
			cout << "\n";
			it->print();
			cout << "\n";
		}
		it++;
	}
	for(i=0;i<30;i++){
		cout<<"-";
	}
	cout<<endl;
}
/*
	method to add a (newly generated) quad of the form: result = arg1 op arg2 where op usually is a binary operator. If arg2 is missing, op is unary
	ip: op , result , arg1 , arg2
	op: void
*/
void emit(opTypeEnum op, string result, string arg1, string arg2) {
	qarr.array.push_back(*(new quad(result,arg1,op,arg2)));
}
/*
	overloaded emit function
*/
int emit(opTypeEnum op, string result, int arg1, int  arg2){
	int a = arg2;
	bool forAll = true;
	qarr.array.push_back(*(new quad(result,arg1,op,"temp")));
	return 0;
}
/*
	function to return the string corresponding to the operator specified
	ip: operator type
	op: corresponding string 
*/
string opToString (int op) {
	if(op==ADD){
		return " + "; 
	}else
	if(op==SUB){
		return " - ";
	}else
	if(op==MATRIXR){
		return " =M[]";
	}else
	if(op==MATRIXL){
		return " M[]= ";
	}
	switch(op) {
		case MULTIPLY:				return " * ";
		case DIVIDE:			return " / ";

		case LNOT:				return " !";
		case _RETURN: 			return " ret";
		case PARAM: 			return " param ";
		case CALL: 				return " call ";
		case LT:				return " < ";
		case GREATER_THAN:				return " > ";
		case GREATER_THAN_EQUAL:				return " >= ";
		case LE:				return " <= ";
		case EQUAL:				return " = ";
		case EQOP:				return " == ";
		case NEOP:				return " != ";
		case PTRL:				return " *L";
		case UNARY_MINUS:			return " -";
		case B_NOT:				return " ~";
		case GOTOOP:			return " goto ";
		//Unary Operators
		case ADDRESS:			return " &";
		case PTRR:				return " *R";
		
		default:				return " op ";
	}
}
/*
	 Make a new vector contaninig an integer i
	 ip: i
	 op: vector<int>
*/
vector<int> makeList (int i) {
	vector<int> l(1,i);
	return l;
}
/*
	overloaded emit function
*/
void emit(opTypeEnum op, string result, int arg1, string arg2) {
	string temp = getDebugString("706","in emit int string");
	//cout<<temp<<endl;
	qarr.array.push_back(*(new quad(result,arg1,op,arg2)));
}
/*
	Merge two vector list to make a single big list
	ip: 2 vectors to merge
*/
vector<int> merge (vector<int> &a, vector<int> &b) {
	int i=0;
	for(i=0;i<b.size();i++){
		a.push_back(b[i]);
	}
	return a;
}
/*
	Returns the address of the next instruction
	op: address
*/
int nextinstr() {
	return qarr.array.size();
}
//getter and setter
void expr::setnextList(vector<int> nextlist){
	nextList = nextlist;
	//return nextList;
}
vector<int> expr::getnextList(){
	return this->nextList;
}

void expr::settrueList(vector<int> truelist){
	trueList = truelist;
	//return trueList;
}
vector<int> expr::gettrueList(){
	return this->trueList;
}

string getemit(opTypeEnum op, string result){
	string temp = getDebugString("746");
	//cout<<temp<<endl;
}
void expr::setisbool(int isbool){
	this->isbool = isbool;
}
int expr::getisbool(){
	return this->isbool;
}
void expr::setfalseList(vector<int> falseList){
	this->falseList = falseList;
	//return falseList;
}
vector<int> expr::getfalseList(){
	return this->falseList;
}

/*
	create a truelist , falselist for booleans from the i/p expression
	i/p: expression e
*/
expr* convertToBoolean (expr* e) {	// Convert any expression to bool
	if (e->isbool == 0) {
		vector<int> falseListVal= makeList (nextinstr());
		e->falseList = falseListVal;
		string temp = getDebugString("771","convertToBoolean");
		//cout<<temp<<endl;  //to debug
		emit (EQOP, "", e->symp->name, "0");
		e->trueList = makeList (nextinstr());
		emit (GOTOOP, "");
	}
}
/*
	backpatch a truelist , falselist for booleans from the i/p expression
	i/p: expr e 
	o/p: boolean expression  
*/
expr* convertFromBoolean (expr* e) {	// Convert any expression from bool
	if (e->isbool == 1) {
		e->symp = gentemp(_INT);
		backpatch (e->trueList, nextinstr());
		string temp = getDebugString("782","convertFromBoolean");
		//cout<<temp<<endl;
		emit (EQUAL, e->symp->name, "true");
		emit (GOTOOP, tostr (nextinstr()+1));
		temp = getDebugString("787","after :tostr (nextinstr()+1)");
		//cout<<temp<<endl;
		backpatch (e->falseList, nextinstr());
		emit (EQUAL, e->symp->name, "false");
	}
}
/*
	check if the 2 input types are same or not 
	i/p: t1 and t2 to be checked 
	o/p: bool value if equal or not 
*/
bool typecheck(symbType* t1, symbType* t2){ 	// Check if the symbol types are same or not
	if (t1 != NULL) {
		if (t2==NULL) return false;
		if (t1->cat==t2->cat) return (t1->ptr, t2->ptr);
		else return false;
	}else{
		if(t2!=NULL){
			return false;
		}
	}
	return true;
}
/*
	Overload function 
	check if the 2 input types are same or not 
	i/p: t1 and t2 to be checked 
	o/p: bool value if equal or not 
*/
bool typecheck(symbol*& s1, symbol*& s2){ 	// Check if the symbols have same type or not
	symbType* type1 = s1->type;
	symbType* type2 = s2->type;
	if ( typecheck (type1, type2) ) return true;
	else if (s1 = conv (s1, type2->cat) ) return true;
	else if (s2 = conv (s2, type1->cat) ) return true;
	return false;
}
// getter and setter
void unary::setcat(typeEnum category){
	cat = category;
}
typeEnum unary::getcat(){
	return this->cat;
}
void unary::setsymp(symbol *Symp){
	symp = Symp;
}
symbol* unary::getsymp(){
	return this->symp;
}
/*
	conv int to required typecast type given as param  
	ip: typeEnum t , symbol s , symbol temp (gentemp variable)
	o/p: converted variable
*/
symbol* convint2type(symbol* s, typeEnum t,symbol* temp){
	if(t==_DOUBLE){
			emit (EQUAL, temp->name, "int2double(" + s->name + ")");
			return temp;	
		}else
		if(t==_CHAR){
			emit (EQUAL, temp->name, "int2char(" + s->name + ")");
			return temp;
		}
		return s;
}
/*
	conv double to required typecast type given as param  
	ip: typeEnum t , symbol s , symbol temp (gentemp variable)
	op: converted variable
*/
symbol* convdouble2type(symbol* s, typeEnum t,symbol* temp){
	if(t==_INT){
				emit (EQUAL, temp->name, "double2int(" + s->name + ")");
				return temp;
			}else
			if(t==_CHAR){
				emit (EQUAL, temp->name, "double2char(" + s->name + ")");
				return temp;
			}
			return s;
}
/*
	conv char to required typecast type given as param  
	ip: typeEnum t , symbol s , symbol temp (gentemp variable)
	op: converted variable
*/
symbol* convchar2type(symbol* s, typeEnum t,symbol* temp){
	switch (t) {
				case _INT: {
					emit (EQUAL, temp->name, "char2int(" + s->name + ")");
					return temp;
				}
				case _DOUBLE: {
					emit (EQUAL, temp->name, "char2double(" + s->name + ")");
					return temp;
				}
			}
			return s;
}
/*
	function to convert symbol to the given typenum e and generate the appropriate emit
	ip: s,t 
*/
symbol* conv(symbol* s, typeEnum t) {
	symbol* temp = gentemp(t);
	if(s->type->cat == _INT){
		return convint2type(s,t,temp);
		}else
		if(s->type->cat == _DOUBLE){
			return convdouble2type(s,t,temp);
		}else
		if(s->type->cat == _CHAR){
			return convchar2type(s,t,temp);
		}
	return s;
}
/*
	change the surrent symbol table to the newsymbolTable during function declaration 
	i/p: the new symboltable to be assigned
*/
void changeTable (symbTable* newsymbolTable) {	// Change current symbol symbolTable
	symbolTable = newsymbolTable;
} 
int  main (int argc, char* argv[]){
	globalSymbolTable = new symbTable("Global");
	symbolTable = globalSymbolTable;
	yyparse();
	symbolTable->calculateOffsets();
	symbolTable->print(1);
	qarr.print();
};