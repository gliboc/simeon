open Printf

type attr = string * string [@@deriving show, eq]
type attr_bind = attr * string option
[@@deriving show, eq]

type query =
  | Select of attr_bind list * rel list * cond
  | Minus of query * query
  | Union of query * query
  | SelectAll of rel list * cond

and rel =
  | File of string * string
  | Query of query * string

and cond =
  | Or of cond * cond
  | And of cond * cond
  | Eq of attr * attr
  | Lt of attr * attr
  | In of attr * query
  | NotIn of attr * query
[@@deriving show]

let show_list f xs = String.concat ", " (List.map f xs)

let show_attr (x, y) = x ^ "." ^ y

let show_attr_bind = function
  | (a, None) -> show_attr a
  | (a, Some x) -> sprintf "%s AS %s" (show_attr a) x

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
  | In (a, q) -> sprintf "%s IN (%s)" (show_attr a) (show_query q)
  | NotIn (a, q) -> sprintf "%s NOT IN (%s)" (show_attr a) (show_query q)
