(* Converting a miniSQL ast to a relationnal algebra ast *)
open AstAlg
open AstSql

let rec c_cond = function
    | Or (c1, c2) -> AstAlg.Or (c_cond c1, c_cond c2)
    | And (c1, c2) -> AstAlg.And (c_cond c1, c_cond c2)
    | Eq (attr, attr') -> Cond (attr, AstAlg.Eq, attr')
    | Lt (a, a') -> Cond (a, AstAlg.Lt, a')
    | _ -> failwith "To do"
            
and    
    compile_rel = function
    | File (f, id) -> Relation (f, id)
    | Query (q, id) -> Renaming (compile q, id)

and productify = function
    | [] -> failwith "Empty relation"
    | [rel] -> compile_rel rel
    | rel :: rels -> Product (compile_rel rel, productify rels)  

and
    compile = function
    | Select (attrs, rels, conds) -> 
        Projection (AstAlg.Select (productify rels, c_cond conds), attrs)
    | Minus (q1, q2) -> AstAlg.Minus (compile q1, compile q2)
    | Union (q1, q2) -> AstAlg.Union (compile q1, compile q2)
                                                            
