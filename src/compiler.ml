(* Compiler from miniSQL AST to relational algebra AST *)

open Ast
open Algebra
        
exception Unhandled_In_Case

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

and match_attr_cond (a : attr_bind list) a' = match (a, a') with
    | ([], _ | _, []) -> failwith "In attributes do not match"
    | [x], [t] -> Eq (Attr x, Attr t)          
    | x :: xs, t :: q -> And (Eq (Attr x, Attr t), match_attr_cond xs q)

and compile = function
    | Select (Attrs p, rel, c) -> (* In transformation doesn't work with * yet *)
        let r = 
          begin match c with
          | None -> c_rel rel
          | Some (In (Attrs p_in, q_in)) ->
               let _ = Printf.printf "Transforming an IN into a JOIN at compilation\n" in
               begin
               try    
                   let (p', rel', c') =
                   begin 
                       match q_in with
                       | Select (Attrs p', rel', c') -> (p', rel', c')
                       | _ -> raise Unhandled_In_Case 
                   end
               	   in compile (Select (Attrs p, Join (rel, rel', (match_attr_cond p_in p')), c'))  
               with Unhandled_In_Case ->
 		   let _ = Printf.printf "This case of IN is not handled\n" in                  
            	   Select (c_rel rel, c_cond (In (Attrs p_in, q_in)))
               end
          | Some c -> Select (c_rel rel, c_cond c)           
          end 
	  in Project (r, p)                                                                       
    | Select (Star, rel, c) ->
        begin match c with
          | None -> c_rel rel
          | Some c -> Select (c_rel rel, c_cond c) 
	end
    | Minus (q1, q2) -> Minus (compile q1, compile q2)
    | Union (q1, q2) -> Union (compile q1, compile q2)
