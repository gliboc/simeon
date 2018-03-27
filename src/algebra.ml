(* Contains the types for the relational algebra AST *)

type t =
  | Select of t * t Ast.cond
  | Project of t * Ast.attr_bind list
  | Order of Ast.attr_bind list * t
  | Product of t * t
  | File of string * string
  | Minus of t * t
  | Union of t * t
  | Join of t * t * t Ast.cond
  | Rename of t * string
[@@deriving show]
