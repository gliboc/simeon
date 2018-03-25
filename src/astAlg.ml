(* Contains the types for the relational algebra AST *)

type cond_expr = 
  | Eq of AstSql.attr * AstSql.attr
  | Lt of AstSql.attr * AstSql.attr
  | EqCst of AstSql.attr * string
  | LtCst of AstSql.attr * string
  | And of cond_expr * cond_expr
  | Or of cond_expr * cond_expr
  | Not of cond_expr
  | In of AstSql.attr * operator
[@@deriving show]

and rel = string * string 

and operator =
  | Select of operator * cond_expr
  | Projection of operator * AstSql.attr_bind list
  | Product of operator * operator
  | Relation of rel
  | Renaming of operator * string
  | Minus of operator * operator
  | Union of operator * operator
  | Join of rel * rel * cond_expr
[@@deriving show]

