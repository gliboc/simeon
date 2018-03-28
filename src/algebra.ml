(* Contains the types for the relational algebra AST *)

type t =
  | Select of t * t Ast.cond
  | Project of t * Ast.attr_bind list
  | Order of Ast.attr_bind list * t * bool
  | Product of t * t
  | File of string * string
  | Minus of t * t
  | Union of t * t
  | UnionAll of t * t
  | Join of t * t * t Ast.cond
  | Rename of t * string
  | ReadSelectProjectRename of (string * string) * t Ast.cond * Ast.attr_bind list
  | JoinProjectRename of t * t * t Ast.cond * Ast.attr_bind list
[@@deriving show]
