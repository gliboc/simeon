(* Compiler from miniSQL AST to relational algebra AST *)

open Ast
open Algebra

let rec c_cond = function
    | Or (c1, c2) -> Or (c_cond c1, c_cond c2)
    | And (c1, c2) -> And (c_cond c1, c_cond c2)
    | Eq (e1, e2) -> Eq (e1, e2)
    | Lt (e1, e2) -> Lt (e1, e2)
    | Not c -> Not (c_cond c)
    | In (e, q) -> In (e, compile q)

and c_rel : (Ast.rel -> Algebra.t) = function
    | Query (q, id) -> Rename (compile q, id)
    | File (f, id) -> File (f, id)
    | Join (r1, r2, c) -> Join (c_rel r1, c_rel r2, c_cond c)
    | Product (r1, r2) -> Product (c_rel r1, c_rel r2)

and compile = function
    | Select (p, rel, c) ->
        let r = match c with
          | None -> c_rel rel
          | Some c -> Select (c_rel rel, c_cond c) in
        (match p with
          | Star -> r
          | Attrs p -> Project (r, p))
    | Minus (q1, q2) -> Minus (compile q1, compile q2)
    | Union (q1, q2) -> Union (compile q1, compile q2)
