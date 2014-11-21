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
%token <integer_ptr> T_NUMBER
%token <identifier_ptr> T_IDENTIFIER
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

%token T_OPEN_PARENS T_CLOSE_PARENS T_OPEN_BRACKET T_CLOSE_BRACKET 

/* WRITEME: Specify types for all nonterminals and necessary terminals here */

%type <expression_ptr> expression
%type <expression_list_ptr> parametersp
%type <methodcall_ptr> methodcall
%type <program_ptr> startp
%type <class_ptr> startle
%type <class_list_ptr> startpp
%type <identifier_ptr> classtype
%type <method_list_ptr> methods
%type <declaration_list_ptr> members
%type <declaration_ptr> member
%type <type_ptr> type
%type <declaration_list_ptr> declarations
%type <declaration_ptr> declaration
%type <identifier_list_ptr> declarationsp



%%

/* WRITEME: This rule is a placeholder. Replace it with your grammar
            rules from Project 3 */

startp : startle startpp {$$=$1; $$ = new ProgramNode($2);}
		;
			
startle: T_IDENTIFIER classtype T_OPEN_BRACKET members methods T_CLOSE_BRACKET{$$ = new ClassNode($1, $2, $4, $5);}
		;
		
startpp: startpp startle{$$->pushBack($2); $$->$1; }
		|  { $$ = new std::list<ClassNode*>(); }
		;
		
classtype: T_COLON T_IDENTIFIER {$$=$2;}
		| {$$ = NULL;}
		;	
			 
		
arguments: member argumentsp
		|
		;
		
argumentsp: T_COMMA member argumentsp
		|
		;
		
methods: T_IDENTIFIER T_OPEN_PARENS arguments T_CLOSE_PARENS T_COLON returntype T_OPEN_BRACKET methodbody T_CLOSE_BRACKET methods
		| 
		;
		
members: members member {$$=$1, $$->push_back($2); }
		| { $$ = new std::list<DeclarationNode*>(); }
		;
		
member: type T_IDENTIFIER member{$$=new DeclarationNode($1,$2);}
		| { $$ = new std::list<IdentifierNode*>(); }
		;
		
methodbody: declarations statements returnstatement 
		;
		
statements: statement statements
		|
		;
		
statement: assignment 
		| methodcall
		| ifelse 
		| forloop 
		| printstatement 
		;
		
assignment: T_IDENTIFIER T_ASSIGNMENT expression
		;
		
returnstatement: T_RETURN expression
		|
		;
		
type: T_INT { $$ = new IntegerTypeNode();}
		| T_BOOL { $$ = new BooleanTypeNode();}
		| T_IDENTIFIER { $$ = new ObjectTypeNode($1);}
		;
		
returntype:	type | T_NONE
		;

declarations: declaration declarations {$$->pushBack($1); $$=$2;}
		| { $$=new std::list<DeclarationNode*>(); }
		
declaration: type declarationsp { $$ = new DeclarationNode($1, $2);}
		;
		
		
declarationsp: declarationsp T_COMMA T_IDENTIFIER {;$$=$1; $$->pushBack($3);}
		| T_IDENTIFIER { $$ = new std::list<IdentifierNode*>(); $$->pushBack($1);}
		;	
		
parametersp: parametersp T_COMMA expression { $$ = $1; $$->push_back($3); }
		| expression  {$$ = new std::list<ExpressionNode*>(); $$->push_back($1);}
		;
		
methodcall: T_IDENTIFIER T_OPEN_PARENS parametersp T_CLOSE_PARENS {$$ = new MethodCallNode($1, NULL, $3);}
		| T_IDENTIFIER T_DOT T_IDENTIFIER T_OPEN_PARENS parametersp T_CLOSE_PARENS {$$ = new MethodCallNode($1, $3, $5);}

ifelse : T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET T_ELSE T_OPEN_BRACKET block T_CLOSE_BRACKET 
		| T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET 
		;
		
block: statement statements
		;
		
forloop: T_FOR assignment T_SEMICOLON expression T_SEMICOLON assignment T_OPEN_BRACKET block T_CLOSE_BRACKET
		;
		
printstatement: T_PRINT expression
		;
		
expression: expression T_PLUS expression { $$ = new PlusNode($1, $3); }
		| expression T_MINUS expression { $$ = new MinusNode($1, $3); }
		| expression T_MULTIPLY expression { $$ = new TimesNode($1, $3); }
		| expression T_DIVIDE expression { $$ = new DivideNode($1, $3); }
		| expression T_LESS_THAN expression { $$ = new LessNode($1, $3); }
		| expression T_LESS_THAN_EQUAL_TO expression { $$ = new LessEqualNode($1, $3); }
		| expression T_EQUAL_TO expression { $$ = new EqualNode($1, $3); }
		| expression T_AND expression { $$ = new AndNode($1, $3); }
		| expression T_OR expression { $$ = new OrNode($1, $3); }
		| T_NOT expression { $$ = new NotNode($2); }
		| T_MINUS expression %prec T_UNARY_MINUS { $$ = new NegationNode($2); }
		| T_IDENTIFIER T_DOT T_IDENTIFIER { $$ = new MemberAccessNode($1, $3); }
		| T_IDENTIFIER {$$ = new VariableNode($1);}
		| methodcall {$$ = $1;}
		| T_OPEN_PARENS expression T_CLOSE_PARENS { $$ = $2; }
		| T_NUMBER {$$ = new IntegerLiteralNode($1);}
		| T_FALSE {$$ = new BooleanLiteralNode($1);}
		| T_TRUE {$$ = new BooleanLiteralNode($1);}
		| T_NEW T_IDENTIFIER  T_OPEN_PARENS parametersp T_CLOSE_PARENS {$$ = new NewNode($2, $4);}
		;

%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
