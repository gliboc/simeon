%{
open AstSql
open String
%}

%token EOF
%token SELECT FROM WHERE AS IN MINUS UNION
%token AND OR NOT EQ LT
%token <string> ID
%token <string> FILE
%token COMMA DOT LPAR RPAR

%left OR
%left AND

%start main
%type <AstSql.query> main

%%

main:
  | q=query EOF                                   { q }

query:
  | SELECT a=attrs FROM r=rels WHERE c=cond       { Select (a, r, c) }
  | LPAR q1=query RPAR MINUS LPAR q2=query RPAR   { Minus (q1, q2) }
  | LPAR q1=query RPAR UNION LPAR q2=query RPAR   { Union (q1, q2) } 

attrs:
  | x=attr_bind                                   { [x] }
  | x=attr_bind COMMA xs=attrs                    { x :: xs }

attr_bind:
  | x=attr                                        { (x, None) }
  | x=attr AS y=ID                                { (x, Some y) }

attr: x=ID DOT y=ID                               { (x, y) }

rels:
  | x=rel                                         { [x] }
  | x=rel COMMA xs=rels                           { x :: xs }

rel:
  | f=FILE x=ID                                   { File (f, x) }
  | LPAR q=query RPAR x=ID                        { Query (q, x) }

cond:
  | LPAR c=cond RPAR                              { c }
  | c1=cond OR c2=cond                            { Or (c1, c2) }
  | c1=cond AND c2=cond                           { And (c1, c2) }
  | a1=attr EQ a2=attr                            { Eq (a1, a2) }
  | a1=attr LT a2=attr                            { Lt (a1, a2) }
  | a=attr IN LPAR q=query RPAR                   { In (a, q) }
  | a=attr NOT IN LPAR q=query RPAR               { NotIn (a, q) }
