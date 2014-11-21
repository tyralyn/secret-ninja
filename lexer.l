%option yylineno
%pointer

%{
    #include <stdlib.h>
    #include <errno.h>
    #include <limits.h>
    #include "ast.hpp"
    #include "parser.hpp"
    void yyerror(const char *);
%}

/* WRITEME: Copy any definitions and start conditions from Project 3 here */
digit			[0-9]
lChar 			[a-z]
uChar			[A-Z]	

%x comment		
			
			
%%			

  /* WRITEME: Copy your Flex rules from Project 3 here */


"/*"         			BEGIN(comment); 

<comment>[^*\n]*        /* eat anything that's not a '*' */ 
<comment><<EOF>>		yyerror("dangling comment");
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             { }
<comment>"*"+"/"        BEGIN(INITIAL);



  
"print"			{ 
						return T_PRINT; }
						
"return"		{ return T_RETURN; }

"if"			{ return T_IF; }

"else" 			{ return T_ELSE; }

"for"			{ return T_FOR; }

"new"			{ return T_NEW; }

"int"			{ return T_INT; }

"bool"			{ return T_BOOL; }

"none"			{ return T_NONE; }

"and"			{ return T_AND; }

"or"			{ return T_OR; }

"not"			{ return T_NOT; }

"true"			{ return T_TRUE; }

"false"			{ return T_FALSE; }

(({uChar}|{lChar})({digit}|{uChar}|{lChar})*) { /*printf("IDENTIFIER KKKKKK\n");*/
						return T_IDENTIFIER; }  
  
([0]|[1-9]{digit}*) { ;
						return T_NUMBER; }
						
[{] 			{ return T_OPEN_BRACKET; }
				
[}]				{ return T_CLOSE_BRACKET; }

[(]				{ return T_OPEN_PARENS; }

[)]				{ return T_CLOSE_PARENS; }

[+]				{ return T_PLUS; }

[-]				{ return T_MINUS; }

[*]				{ return T_MULTIPLY; }

[/]				{ return T_DIVIDE; }

"=="			{ return T_EQUAL_TO; }

"<="			{ return T_LESS_THAN_EQUAL_TO; }

[=]				{ return T_ASSIGNMENT; }

[<]				{ return T_LESS_THAN; }

"\." 			{ return T_DOT; }

[:]				{ return T_COLON; }

[;]				{ return T_SEMICOLON; }

[,]				{ return T_COMMA; }


\n					{ }						
[ \t]				{ }

.                 	{ yyerror("invalid character"); }

%%

int yywrap(void) {
  return 1;
}
