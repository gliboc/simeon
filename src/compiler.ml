(* Compiler from miniSQL AST to relational algebra AST *)

open Ast
open Algebra
        
exception Unhandled_In_Case

let rec c_cond debug = function
    | Or (c1, c2) -> Or (c_cond debug c1, c_cond debug c2)
    | And (c1, c2) -> And (c_cond debug c1, c_cond debug c2)
    | Eq (e1, e2) -> Eq (e1, e2)
    | Lt (e1, e2) -> Lt (e1, e2)
    | Not c -> Not (c_cond debug c)
    | In (e, q) -> In (e, compile debug q)

and c_rel : (bool -> Ast.rel -> Algebra.t) = fun debug -> function
    | Query (q, id) -> Rename (compile debug q, id)
    | File (f, id) -> File (f, id)
    | Join (r1, r2, c) -> Join (c_rel debug r1, c_rel debug r2, c_cond debug c)
    | Product (r1, r2) -> Product (c_rel debug r1, c_rel debug r2)

and match_attr_cond a a' = match (a, a') with
    | ([], _ | _, []) -> failwith "In attributes do not match"
    | [x], [t] -> Eq (Attr x, Attr t)          
    | x :: xs, t :: q -> And (Eq (Attr x, Attr t), match_attr_cond xs q)

and compile debug = function
    | Select (Attrs p, rel, c) -> (* In transformation doesn't work with * yet *)
        let r = 
          (begin match c with
          | None -> c_rel debug rel
          | Some (In (Attrs p_in, q_in)) ->
               let _ = if debug then Printf.printf "Transforming an IN into a JOIN at compilation\n" in
               begin
               try    
                   let (p', rel', c') =
                   begin 
                       match q_in with
                       | Select (Attrs p', rel', c') -> (p', rel', c')
                       | _ -> raise Unhandled_In_Case 
                   end
               	   in compile debug (Select (Attrs p, Join (rel, rel', (match_attr_cond p_in p')), c'))  
               with Unhandled_In_Case ->
 		   let _ = if debug then Printf.printf "This case of IN is not handled\n" in                  
            	   Select (c_rel debug rel, c_cond debug (In (Attrs p_in, q_in)))
               end
          | Some c -> Select (c_rel debug rel, c_cond debug c)           
          end) 
	  in Project (r, p)                                                                       
    | Select (Star, rel, c) ->
        begin match c with
          | None -> c_rel debug rel
          | Some c -> Select (c_rel debug rel, c_cond debug c) 
	end
    | Minus (q1, q2) -> Minus (compile debug q1, compile debug q2)
    | Union (q1, q2) -> Union (compile debug q1, compile debug q2)
    | UnionAll (q1, q2) -> UnionAll (compile debug q1, compile debug q2)
    | Order (a, q, b) -> Order (a, compile debug q, b)
