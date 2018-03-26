(* Contains the type for the miniSQL AST *)
open Printf

type attr = string * string [@@deriving show, eq]
type attr_bind = attr * string option
[@@deriving show, eq]

type query =
  | Select of attr_bind list * query * cond
  | Minus of query * query
  | Union of query * query
  | Join of query * query * cond
  | SelectAll of query * cond
  | Product of rel * query   (* Used to parse rels into a query type *)
  | Relation of rel (* Same than previous *)

and rel =
  | File of string * string
  | Query of query * string

and cond =
  | Or of cond * cond
  | And of cond * cond
  | Eq of attr * attr
  | EqCst of attr * string        
  | Lt of attr * attr
  | LtCst of attr * string
  | In of attr * query
  | NotIn of attr * query
[@@deriving show]

let show_list f xs = String.concat ", " (List.map f xs)

let show_attr (x, y) = x ^ "." ^ y

let show_attr_bind = function
  | (a, None) -> show_attr a
  | (a, Some x) -> sprintf "%s AS %s" (show_attr a) x

(* Deprecated to ppx_deriving
 It's less pretty ok.  *)
(* 
let rec show_query = function
  | SelectAll (rels, cond) -> 
    sprintf "SELECT * FROM %s WHERE %s" 
      (show_list show_rel rels)
      (show_cond cond)
  | Select (attrs, rels, cond) ->
    sprintf "SELECT %s FROM %s WHERE %s"
      (show_list show_attr_bind attrs)
      (show_list show_rel rels)
      (show_cond cond)
  | Join (r1, r2, cond) ->
     sprintf "%s JOIN %s ON %s"
      (show_list show_rel r1)
      (show_list show_rel r2)
      (show_cond cond)
  | Minus (q1, q2) -> sprintf "(%s) MINUS (%s)" (show_query q1) (show_query q2)
  | Union (q1, q2) -> sprintf "(%s) UNION (%s)" (show_query q1) (show_query q2)

and show_rel = function
  | File (f, x) -> sprintf "%s AS %s" f x
  | Query (q, x) -> sprintf "(%s) AS %s" (show_query q) x

and show_cond = function
  | Or (c1, c2) -> sprintf "(%s) OR (%s)" (show_cond c1) (show_cond c2)
  | And (c1, c2) -> sprintf "(%s) AND (%s)" (show_cond c1) (show_cond c2)
  | Eq (a1, a2) -> sprintf "%s = %s" (show_attr a1) (show_attr a2)
  | Lt (a1, a2) -> sprintf "%s < %s" (show_attr a1) (show_attr a2)
  | EqCst (a1, v) -> sprintf "%s = %s" (show_attr a1) v
  | LtCst (a1, v) -> sprintf "%s < %s" (show_attr a1) v
  | In (a, q) -> sprintf "%s IN (%s)" (show_attr a) (show_query q)
  | NotIn (a, q) -> sprintf "%s NOT IN (%s)" (show_attr a) (show_query q)
*)
