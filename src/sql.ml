type attr = string * string
type attr_bind = attr * string option

type query =
  | Select of attr_bind list * (rel * string) list * cond
  | Minus of query * query
  | Union of query * query

and rel =
  | File of string
  | Query of query

and cond =
  | Or of cond * cond
  | And of cond * cond
  | Eq of attr * attr
  | Lt of attr * attr
  | In of attr * query
  | NotIn of attr * query

