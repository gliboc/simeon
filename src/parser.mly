%{
open Ast
open String

let join_of_list = List.fold_left (fun r1 (r2, c) -> Join (r1, r2, c))
%}

%token EOF
%token SELECT FROM WHERE AS IN MINUS UNION JOIN ON
%token AND OR NOT EQ LT GT LEQ GEQ ADD SUB STAR DIV
%token <string> ID FILE STRING
%token <int> NUM
%token COMMA DOT LPAR RPAR

%left OR
%left AND
%nonassoc NOT
%left ADD SUB
%left STAR DIV

%start main
%type <Ast.t> main

%%

main:
  | q=query EOF                                   { q }

query:
  | SELECT p=proj r=from                          { Select (p, r, None) }
  | SELECT p=proj r=from WHERE c=cond             { Select (p, r, Some c) }
  | LPAR q1=query RPAR MINUS LPAR q2=query RPAR   { Minus (q1, q2) }
  | LPAR q1=query RPAR UNION LPAR q2=query RPAR   { Union (q1, q2) }

proj:
  | STAR                                          { Star }
  | a=attrs                                       { Attrs a }

attrs:
  | x=attr_bind                                   { [x] }
  | x=attr_bind COMMA xs=attrs                    { x :: xs }

attr_bind:
  | x=attr                                        { (x, None) }
  | x=attr AS? y=ID                               { (x, Some y) }

attr: x=ID DOT y=ID                               { (x, y) }

from:
  | FROM r=rels j=join                            { join_of_list r j }

rels:
  | r=rel                                         { r }
  | r=rel COMMA rs=rels                           { Product (r, rs)}

rel:
  | f=FILE AS? x=ID                               { File (f, x) }
  | LPAR q=query RPAR AS? x=ID                    { Query (q, x) }

join:
  |                                               { [] }
  | JOIN r=rel ON c=cond j=join                   { (r, c) :: j }

cond:
  | LPAR c=cond RPAR                              { c }
  | NOT c=cond                                    { Not c }
  | c1=cond OR c2=cond                            { Or (c1, c2) }
  | c1=cond AND c2=cond                           { And (c1, c2) }
  | e1=expr EQ e2=expr                            { Eq (e1, e2) }
  | e1=expr LT e2=expr                            { Lt (e1, e2) }
  | e1=expr GT e2=expr                            { And (Not (Lt (e1, e2)), Not (Eq (e1, e2))) }
  | e1=expr GEQ e2=expr				  { Not (Lt (e1, e2)) }
  | e1=expr LEQ e2=expr                           { Or (Lt (e1, e2), Eq (e1, e2)) }
  | p=proj IN LPAR q=query RPAR                   { In (p, q) }
  | p=proj NOT IN LPAR q=query RPAR               { Not (In (p, q)) }

expr:
  | LPAR e=expr RPAR                              { e }
  | e1=expr ADD e2=expr                           { Add (e1, e2) }
  | e1=expr SUB e2=expr                           { Sub (e1, e2) }
  | e1=expr STAR e2=expr                          { Mult (e1, e2) }
  | e1=expr DIV e2=expr                           { Div (e1, e2) }
  | i=NUM                                         { Num i }
  | s=STRING                                      { String s }
  | a=attr_bind                                   { Attr a }
