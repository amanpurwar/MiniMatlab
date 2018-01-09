#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
 extern int yylex(void);
 extern char *yytext;
int main(int argc,char** argv){
	int token;
	while (token = yylex()) {
		if(token == -1){
			printf("ERROR , not a valid pattern : %s",yytext);
			exit(-1); 
		}
		else if(token>=258 && token<=280){
				printf("<KEYWORD, %s >\n",yytext); 
		}
		else if(token==281)	printf("<IDENTIFIER, %s >\n",yytext); 
		else if(token==282) printf("<CONSTANT, %s >\n",yytext);
		else if(token==283) printf("<STRING_LITERAL, %s >\n",yytext);
		else if(token==284) {}
		else {
				printf("<PUNCTUATOR, %s >\n",yytext); 					
		}
	}
}
