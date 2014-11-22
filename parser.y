%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>
    #include "ast.hpp"
    
    #define YYDEBUG 1
    int yylex(void);
    void yyerror(const char *);
    
    extern ASTNode* astRoot;
%}

%error-verbose

/* WRITEME: Copy your token and precedence specifiers from Project 3 here */
%token <integer_ptr> T_NUMBER <identifier_ptr> T_IDENTIFIER
%token T_CHILDCLASS_IDENTIFIER T_DECLARATION_IDENTIFIER T_ARGUMENT_IDENTIFIER T_ASSIGNMENT_IDENTIFIER

%token T_PRINT T_RETURN T_IF T_ELSE T_FOR T_NEW <integertype_ptr> T_INT <booleantype_ptr> T_BOOL <none_ptr> T_NONE <integer_ptr> T_TRUE <integer_ptr>T_FALSE

%token T_COLON T_SEMICOLON T_COMMA

%right T_ASSIGNMENT 
%left T_OR
%left T_AND
%left T_LESS_THAN T_LESS_THAN_EQUAL_TO T_EQUAL_TO
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%right T_NOT T_UNARY_MINUS
%left T_DOT
%nonassoc P_METHOD 
%nonassoc P_STATEMENTS
%nonassoc P_DECLARATION
%nonassoc P_MEMBER 

%token T_OPEN_PARENS T_CLOSE_PARENS T_OPEN_BRACKET T_CLOSE_BRACKET 

/* WRITEME: Specify types for all nonterminals and necessary terminals here */
%type <program_ptr> start
%type <class_list_ptr> startp
%type <class_ptr> startle
%type <type_ptr> type
%type <identifier_ptr> classtype
%type <declaration_list_ptr> members
%type <method_list_ptr> methods
%type <declaration_ptr> member

%%

/* WRITEME: This rule is a placeholder. Replace it with your grammar
            rules from Project 3 */
			
start: startp { $$ = new ProgramNode($1);}
		;			
			
startp : startp startle {$$ = $1; $$->push_back($2);}
		| { $$ = new std::list<ClassNode*>(); }
		;

startle: T_IDENTIFIER classtype T_OPEN_BRACKET members methods T_CLOSE_BRACKET{$$ = new ClassNode($1, $2, $4, $5);}
		;
		
classtype: T_COLON T_IDENTIFIER { $$=$2; }
		| { $$ = NULL; }
		;	
			
		
arguments: member argumentsp
		|
		;
		
argumentsp: T_COMMA member argumentsp
		|
		;
		
methods: T_IDENTIFIER T_OPEN_PARENS arguments T_CLOSE_PARENS T_COLON returntype T_OPEN_BRACKET methodbody T_CLOSE_BRACKET methods %prec P_METHOD
		|
		;
		
members: members member %prec P_MEMBER
		|
		;
		
member: type T_IDENTIFIER {std::list<IdentifierNode*>* k = new std::list<IdentifierNode*>(); k->push_back($2); $$=new DeclarationNode($1,k);}
		;
		
methodbody: declarations statements returnstatement 
		;
		
statements: statements statement %prec P_STATEMENTS
		|
		;
		
statement: assignment
		| methodcall   
		| ifelse 	
		| forloop 
		| printstatement 
;
		
assignment: T_IDENTIFIER T_ASSIGNMENT expression %prec P_STATEMENTS 
		;
		
returnstatement: T_RETURN expression
		|
		;
		
type: T_INT { $$ = new IntegerTypeNode();}
		| T_BOOL { $$ = new BooleanTypeNode();}
		| T_IDENTIFIER{ $$ = new ObjectTypeNode($1);}
		
returntype:	type | T_NONE
		;
		
declarations: declarations type declarationsp T_IDENTIFIER  %prec P_DECLARATION 
		|  %prec P_DECLARATION 
		;
		
declarationsp: declarationsp T_IDENTIFIER T_COMMA
		|
		;	

parameters: parametersp
		|
		;
		
parametersp: parametersp T_COMMA expression
		| expression
		;
		
methodcall: T_IDENTIFIER paramlist %prec P_STATEMENTS 
		| T_IDENTIFIER T_DOT T_IDENTIFIER paramlist %prec P_STATEMENTS 

paramlist : T_OPEN_PARENS parameters T_CLOSE_PARENS	
		;
		
ifelse : T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET T_ELSE T_OPEN_BRACKET block T_CLOSE_BRACKET 
		| T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET 
		;
		
block: statement statements
		;
		
forloop: T_FOR assignment T_SEMICOLON expression T_SEMICOLON assignment T_OPEN_BRACKET block T_CLOSE_BRACKET
		;
		
printstatement: T_PRINT expression
		;
		
expression: expression T_PLUS expression
		| expression T_MINUS expression
		| expression T_MULTIPLY expression
		| expression T_DIVIDE expression
		| expression T_LESS_THAN expression
		| expression T_LESS_THAN_EQUAL_TO expression
		| expression T_EQUAL_TO expression
		| expression T_AND expression
		| T_NOT expression
		| expression T_OR expression
		| T_MINUS expression %prec T_UNARY_MINUS
		| T_IDENTIFIER T_DOT T_IDENTIFIER
		| T_IDENTIFIER
		| methodcall
		| T_OPEN_PARENS expression T_CLOSE_PARENS
		| T_NUMBER
		| T_FALSE
		| T_TRUE
		| T_NEW T_IDENTIFIER
		| T_NEW T_IDENTIFIER  paramlist
		;
		
%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
