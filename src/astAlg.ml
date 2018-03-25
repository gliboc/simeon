type cond_expr = 
  | Eq of AstSql.attr * AstSql.attr
  | Lt of AstSql.attr * AstSql.attr
  | And of cond_expr * cond_expr
  | Or of cond_expr * cond_expr
  | Not of cond_expr
  | In of AstSql.attr * operator
[@@deriving show]

and operator =
  | Void
  | Select of operator * cond_expr
  | Projection of operator * AstSql.attr_bind list
  | Product of operator * operator
  | Relation of string * string
  | Renaming of operator * string
  | Minus of operator * operator
  | Union of operator * operator
[@@deriving show]


let parse _ = Relation ("", "")

