(* Compiler from miniSQL AST to relational algebra AST *)
open Algebra
open Ast

let rec c_cond = function
    | Or (c1, c2) -> Algebra.Or (c_cond c1, c_cond c2)
    | And (c1, c2) -> Algebra.And (c_cond c1, c_cond c2)
    | Eq (attr, attr') -> Algebra.Eq (attr, attr')
    | EqCst (attr, v) -> Algebra.EqCst (attr, v)
    | Lt (a, a') -> Algebra.Lt (a, a')
    | LtCst (attr, v) -> Algebra.LtCst (attr, v)
    | In (a, q) -> Algebra.In (a, compile q)
    | _ -> failwith "To do"
            
and    
    c_rel = function
    | File (f, id) -> Algebra.Relation (f, id)
    | Query (q, id) -> Renaming (compile q, id)

(* now done at parsing *)
(*
and productify = function
    | [] -> failwith "Empty relation"
    | [rel] -> compile_rel rel
    | rel :: rels -> Product (compile_rel rel, productify rels)  
*)
                           
and
    compile = function
    | Join (r1, r2, conds) ->
        Algebra.Select (Product (compile r1, compile r2), c_cond conds)
    | SelectAll (rels, conds) -> Algebra.Select (compile rels, c_cond conds)
    | Select (attrs, rels, conds) -> 
        Projection (Algebra.Select (compile rels, c_cond conds), attrs)
    | Minus (q1, q2) -> Algebra.Minus (compile q1, compile q2)
    | Union (q1, q2) -> Algebra.Union (compile q1, compile q2)
    | Product (r, rs) -> Algebra.Product (c_rel r, compile rs)
    | Relation (r) -> c_rel r
