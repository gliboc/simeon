(* Contains the type for the miniSQL AST *)

type attr = string * string [@@deriving show, eq]

type attr_bind = attr * string option[@@deriving show]
type proj =
  | Star
  | Attrs of attr_bind list
[@@deriving show]

type expr =
  | Num of int
  | String of string
  | Attr of attr_bind
  | Add of expr * expr
  | Sub of expr * expr
  | Mult of expr * expr
  | Div of expr * expr
[@@deriving show]

type 'a cond =
  | Or of 'a cond * 'a cond
  | And of 'a cond * 'a cond
  | Eq of expr * expr
  | Lt of expr * expr
  | In of expr * 'a
  | Not of 'a cond
[@@deriving show]

type t =
  | Select of proj * rel * t cond option
  | Minus of t * t
  | Union of t * t
[@@deriving show]

and rel =
  | File of string * string
  | Query of t * string
  | Join of rel * rel * t cond
  | Product of rel * rel
[@@deriving show]

