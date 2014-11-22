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

%token T_OPEN_PARENS T_CLOSE_PARENS T_OPEN_BRACKET T_CLOSE_BRACKET 

/* WRITEME: Specify types for all nonterminals and necessary terminals here */
%type <program_ptr> start
%type <class_list_ptr> startp
%type <class_ptr> startle
%type <identifier_ptr> classtype
%type <parameter_list_ptr> arguments
%type <parameter_ptr> argumentsp
%type <method_list_ptr> methods
%type <declaration_list_ptr> members
%type <declaration_ptr> member
%type <methodbody_ptr> methodbody
%type <methodcall_ptr> methodcall
%type <statement_list_ptr> statements
%type <statement_ptr> statement
%type <assignment_ptr> assignment
%type <returnstatement_ptr> returnstatement
%type <type_ptr> type
%type <type_ptr> returntype
%type <declaration_list_ptr> declarations
%type <identifier_list_ptr> declarationsp
%type <expression_list_ptr> parameters
%type <expression_list_ptr> parametersp
%type <ifelse_ptr> ifelse
%type <statement_list_ptr> block
%type <for_ptr> forloop
%type <print_ptr> printstatement
%type <expression_ptr> expression



%%

/* WRITEME: This rule is a placeholder. Replace it with your grammar
            rules from Project 3 */
			
start: startp{$$ = new ProgramNode($1);}
		;			
			
startp : startp startle {$$=$1; $$->push_back($2);}
		|{$$ = new std::list<ClassNode*>(); }
		;

startle: T_IDENTIFIER classtype T_OPEN_BRACKET members methods T_CLOSE_BRACKET {$$=new ClassNode($1, $2, $4, $5);}
		;
		
classtype: T_COLON T_IDENTIFIER {$$=$2;}
		| {$$=NULL;}
		;	
		
arguments: type T_IDENTIFIER argumentsp { $$->push_back(new ParameterNode($1,$2));  $$->push_back($3);}
		| {$$ = new std::list<ParameterNode*>(); }
		;		
		
argumentsp: argumentsp T_COMMA type T_IDENTIFIER {$$=$1; $$= new ParameterNode($3,$4);} 
		| {$$ = NULL; }
		;
		
methods: T_IDENTIFIER T_OPEN_PARENS arguments T_CLOSE_PARENS T_COLON returntype T_OPEN_BRACKET methodbody T_CLOSE_BRACKET methods {$$->push_back(new MethodNode($1, $3, $6, $8)); $$=$10;}
		| {$$ = new std::list<MethodNode*>(); }
		;
		
members: members member {$$=$1; $$->push_back($2);}
		| {$$ = new std::list<DeclarationNode*>(); }
		;
		
member: type T_IDENTIFIER {$$= new DeclarationNode($1, new std::list<IdentifierNode*>(1, $2)); }
		;
		
methodbody: declarations statements returnstatement {$$=new MethodBodyNode($1, $2, $3);}
		;
		
statements: statement statements {$$->push_back($1); $$=$2;}
		| {$$ = new std::list<StatementNode*>(); }
		;
		
statement: assignment {$$=$1;}
		| methodcall {$$=new CallNode($1);}
		| ifelse {$$=$1;}
		| forloop {$$=$1;}
		| printstatement {$$=$1;}
		;
		
assignment: T_IDENTIFIER T_ASSIGNMENT expression  {$$ = new AssignmentNode($1, $3);}
		;
		
returnstatement: T_RETURN expression {$$ = new ReturnStatementNode($2);}
		| {$$ = new ReturnStatementNode(NULL);}
		;
		
type: T_INT { $$ = new IntegerTypeNode();}
		| T_BOOL { $$ = new BooleanTypeNode();}
		| T_IDENTIFIER { $$ = new ObjectTypeNode($1);}
		;
		
returntype:	type {$$=$1;}
		| T_NONE {$$=new NoneNode();}
		;
		
declarations: declarations type T_IDENTIFIER declarationsp {$$ = $1; $4->push_back($3); DeclarationNode* n = new DeclarationNode($2, $4);}
		| {$$ = new std::list<DeclarationNode*>(); }
		;
		
declarationsp: T_COMMA T_IDENTIFIER declarationsp  {$$->push_back($2); $$=$3;}
		| {$$ = new std::list<IdentifierNode*>(); }
		;	

parameters: parametersp {$$=$1;}
		;
		
parametersp: parametersp T_COMMA expression {$$=$1, $$->push_back($3);}
		| expression {$$ = new std::list<ExpressionNode*>(); $$->push_back($1);}
		| {$$ = new std::list<ExpressionNode*>(); }
		;
		
methodcall: T_IDENTIFIER T_OPEN_PARENS parameters T_CLOSE_PARENS {$$ = new MethodCallNode($1, NULL, $3);}
		| T_IDENTIFIER T_DOT T_IDENTIFIER T_OPEN_PARENS parameters T_CLOSE_PARENS {$$ = new MethodCallNode($1, $3, $5);}
		
ifelse : T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET T_ELSE T_OPEN_BRACKET block T_CLOSE_BRACKET {$$ = new IfElseNode($2, $4, $8);}
		| T_IF expression T_OPEN_BRACKET block T_CLOSE_BRACKET {$$ = new IfElseNode($2, $4, NULL);}
		;
		
block: statement statements {$2->push_back($1);$$=$2;}
		;
		
forloop: T_FOR assignment T_SEMICOLON expression T_SEMICOLON assignment T_OPEN_BRACKET block T_CLOSE_BRACKET {$$ = new ForNode($2, $4, $6, $8);}
		;
		
printstatement: T_PRINT expression {$$ = new PrintNode($2);}
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
		| T_NEW T_IDENTIFIER T_OPEN_PARENS parameters T_CLOSE_PARENS {$$ = new NewNode($2, $4);}
		;
		
%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
