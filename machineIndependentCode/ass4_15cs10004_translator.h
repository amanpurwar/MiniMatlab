#ifndef ASS4_15CS10004_TRANSLATOR_H 
#define ASS4_15CS10004_TRANSLATOR_H
#define NUMBERTOSTRING( x ) static_cast< std::ostringstream & >( \
        ( std::ostringstream() << std::dec << x ) ).str()
#include <bits/stdc++.h>
#include <iostream>
#include <vector>
#include <algorithm>
#define SIZE_OF_CHAR 		1
#define SIZE_OF_INT  		4
#define SIZE_OF_DOUBLE		8
#define SIZE_OF_POINTER		4
extern  char* yytext;
extern  int yyparse();

using namespace std;
/********* Forward Declarations ************/

class symbol;						// Entry in a symbol symbolTable
class symbTable;					// Symbol Table
class quad;						// Entry in quad array
class quads;					// All Quads
class symbType;					// Type of a symbol in symbol symbolTable

/************** Enum types *****************/

enum typeEnum {	// Type enumeration
_VOID, _CHAR, _INT, _DOUBLE, PTR, ARR, FUNC, _MATRIX}; 	
enum opTypeEnum { 
EQUAL, 
// Relational Operators 
LT, GREATER_THAN, LE, GREATER_THAN_EQUAL, EQOP, NEOP,GOTOOP, _RETURN,
// Arithmatic Operators
ADD, SUB, MULTIPLY, DIVIDE, RIGHT_SHIFT_OP, LEFTOP, MODOP,
// Unary Operators
UNARY_MINUS, UPLUS, ADDRESS, RIGHT_POINTER, B_NOT, LNOT,
// Bit Operators
BAND, XOR, INOR,
// PTR Assign
PTRL, PTRR,
// ARR Assign
MATRIXR, MATRIXL,
// Function call
PARAM, CALL, LABEL,
// Transpose
_DOTCOMMA
};

/********** Class Declarations *************/

class symbType { 				// Type of an element in symbol table and other information necessary for that
private:
	int width;					// Size of the Matrix
public:
	int row; 					// Row of the matrix for Matrix category
 	int col;					// Col of the matrix for Matrix category
public:
	symbType(typeEnum cat, symbType* ptr = NULL, int width = 1); //symbtype constructor
	typeEnum cat; 				// category of symbol
	symbType* ptr;				// pointer-> pointer to ptr type 
	bool transpose; 			// while calculating the transpose of a matrix this attribute is used
public: 						// getter and setter for the above variables 
	void setwidth(int width); 
	int getwidth();
	void setrows(int rows);
	int getrows();
	void setcols(int cols);
	int getcols();
	void settranspose(bool transpose);
	bool gettranspose();
	friend ostream& operator<<(ostream&, const symbType); // overloading the << operator to enable easy printing 
};

class symbol { // Row in a Symbol Table
public:
	string name;				// Name of symbol
	symbType *type;				// Type of Symbol
	
public:
	string init;				// Symbol initialisation
	string varCategory;			// category of the symbol :local, temp or global
	int size;					// Size of the type of symbol
	int offset;					// Offset of symbol computed at the end
	
public:
	symbTable* nest;			// Pointer to nested symbol in the symbolTable
	void setsize(int size);		// getter and setter for variables
	int getsize();
	void setoffset(int offsetVal);
	int getoffset();
public:
	symbol (string, typeEnum t=_INT, symbType* ptr = NULL, int width = 0); 	//constructor for symbol class
	symbol* update(symbType * t); 		// Update using type object and nested symbolTable pointer
	string val; 				// variable for storing the value of symbolTable entry
	symbol* update(typeEnum t); 		// Update using raw type and nested symbolTable pointer
	symbol* initialize (string);        // set the initial value of the variale if any
public:
	friend ostream& operator<<(ostream&, const symbol*);
	//gettter and setter for the variables
	void setname(string nameVal); 	
	string getname();
	void setinit(string initVal);
public:
	string getinit();
	void setcategory(string varCategoryVal);
	string getcategory();
	symbol* linkst(symbTable* t); 		//set the nested table entry during the function call
};


class symbTable { 						// Symbol Table
public:
	string tname;						// Name of Table
	int tempVarCount;					// Count of temporary variables
	list <symbol> symbolTable; 			// The symbolTable of symbols
	symbTable* parent;                  // parent of the cuurent table , needed for nested table

public:
	symbTable (string name="");
	symbol* lookup (string name);		// Lookup for a symbol in symbol symbolTable and creates one if no such name exists
	void print(int all = 0);			// Print the symbolTable
	void calculateOffsets();			// Compute offset of the whole symbol symbolTable recursively
public: 								// getter setters for the variables 
	void settname(string tnameVal);
	string gettname();
	void settcount(int tempVarCountVal);
	int  gettcount();
	void setparent(symbTable* parentVal);
	symbTable* getparent(); 	
};

class quad { // Individual Quad
public:
	opTypeEnum op;					// Operator for the quad
	string result;					// Result of the quad 
	string arg1;					// Argument 1
	string arg2;					// Argument 2

public:
	void print ();								// Print the quad 
public:
	void update (int addr);						// Used for backpatching address
	quad (string result, string arg1, opTypeEnum op = EQUAL, string arg2 = "");
	quad (string result, int arg1, opTypeEnum op = EQUAL, string arg2 = "");
public: 										// getter and setter 
	void setop(opTypeEnum opType);
	opTypeEnum getop();
	void setresult(string res);
	string getresult();
	void setarg1(string arg1Val);
	string getarg1();	
};

class quads { 						// Quad Array
public:
	vector <quad> array;;			// Vector of quads

public:
	quads () {array.reserve(330);}
public:
	void print ();								// Print all the quads
	void printtab();							// Print quads in tabular form
};
/*********** Function Declarations *********/


void backpatch (vector<int>, int); 					// backpatch list with the addr int
void emit(opTypeEnum opL, string result, string arg1="", string arg2 = ""); 		// emit the quads and push it in the quad array
int emit(opTypeEnum op, string result, int arg1, int arg2 = 0); 					// overloaded emit function
void emit(opTypeEnum op, string result, int arg1, string arg2 = ""); 				// overloaded emit function 


symbol* gentemp (typeEnum t=_INT, string init = "");		// Generate a temporary variable and insert it in symbol symbolTable
symbol* gentemp (symbType* t, string init = "",bool transpose = false,bool matrix_temp = false,bool init_matrix = false);		// Generate a temporary variable and insert it in symbol symbolTable
vector<int> makeList (int);									// Make a new vector contaninig an integer
string getDebugString(string loc,string val = ""); 			// function to generate the debug string 
vector<int> merge (vector<int> &, vector<int> &);			// Merge two vector list to make a single big list
string getemit(opTypeEnum op, string result);

int calSizeOfType (symbType*); 								// calcualate size of the given symbType
symbol* convint2type(symbol*, typeEnum,symbol*); 			// convert int to other types
symbol* convdouble2type(symbol*, typeEnum,symbol*);			// convert double to other types
string getStringValue (const symbType*);					// For printing type structure
string opToString(int);										// return the opcode string for the operators 

symbol* conv (symbol*, typeEnum);							// Convert symbol like chars  to different type
bool typecheck(symbol* &s1, symbol* &s2);					// Checks if two symbbol in symbolTable entries have same type
bool typecheck(symbType* s1, symbType* s2);					// Checks if the type objects are equivalent or not

int nextinstr();											// Returns the address of the next instruction

void changeTable (symbTable* newsymbolTable); 				// fo switching b/w the symbol tables

/*** Global variables declared in cxx file****/

extern symbTable* symbolTable;								// Current Symbbol Table
extern symbTable* globalSymbolTable;						// Global Symbbol Table
extern quads qarr;											// Quads
extern symbol* currSymbol;									// Pointer to just encountered symbol

/** Attributes/Global for Boolean Expression***/

class expr { 												// class havong expression's attributes 
public:
	int isbool;												// int variable that stores if the expression is bool or not 1 for true and 0 for false

	// Valid for non-bool type
	symbol* symp;											// Pointer to the symbol symbolTable entry

	// Valid for bool type
public:
	vector<int> trueList;									// TrueList attribute for the boolean
	vector<int> falseList;									// TrueList attribute for the boolean
	vector<int> nextList;  									// nextList attribute for the boolean
public: 													// getter and setter for variables 
	void setnextList(vector<int> nextList);
	vector<int> getnextList();
	void settrueList(vector<int> trueList);
	vector<int> gettrueList();
public:
	void setfalseList(vector<int> falseList);
	vector<int> getfalseList();
	void setisbool(int isbool);
	int getisbool();	
};

class statement { 										// class to store the nextlist for the statements
public:
	vector<int> nextList;  								// Nextlist for statement 
public:
	void setnextList(vector<int> nextlist);				// getter and setter s
	vector<int> getnextList();	
	};			


class unary {    										// class for unary expressions 
public:
	typeEnum cat;										// category attribute of the unary expr 
public:
	void setcat(typeEnum category);
	typeEnum getcat();
public:
	symbol* loc;										// Temporary used for computing matrix address and storing it 
	symbol* symp;										// Pointer to symbol in  symbolTable
	symbType* type;
public:
	void setsymp(symbol* Symp);
public:
	symbol* getsymp();
	string val;   
	};	
// Utility functions for getting the string from the attributes
template <typename T> string tostr(const T& t) { 
   ostringstream os; 
   os<<t; 
   return os.str(); 
} 
symbol* convchar2type(symbol*, typeEnum,symbol*); 	// convert char to different types
expr* convertToBoolean (expr*);				// convert any expression to bool
expr* convertFromBoolean (expr*);			// convert bool to expression

#endif