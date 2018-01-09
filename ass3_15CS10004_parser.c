#include <stdio.h>
#include "y.tab.h"
 extern int yyparse (void);
 extern char *yytext;
int main(int argc,char** argv){
	if(yyparse()==0)
		printf("%s",yytext);
}
