(* Contains the types for the relational algebra AST *)

type cond_expr = 
  | Eq of Ast.attr_bind * Ast.attr_bind
  | Lt of Ast.attr_bind * Ast.attr_bind
  | EqCst of Ast.attr_bind * string
  | LtCst of Ast.attr_bind * string
  | And of cond_expr * cond_expr
  | Or of cond_expr * cond_expr
  | Not of cond_expr
  | In of Ast.attr_bind * operator
[@@deriving show]

and rel = string * string 

and operator =
  | Select of operator * cond_expr
  | Projection of operator * Ast.attr_bind list
  | Product of operator * operator
  | Relation of rel
  | Renaming of operator * string
  | Minus of operator * operator
  | Union of operator * operator
  | Join of operator * operator * cond_expr
[@@deriving show]
