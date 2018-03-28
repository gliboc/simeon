open Ast
open Algebra
        
module Set = Set.Make (struct type t=attr_bind 
                              let compare = compare end)

let get_attr_set cond = 
    let rec aux_e = function
        | Attr a -> Set.singleton a
        | (Num _ | String _) -> Set.empty
        | (Add(r,s)|Sub(r,s)|Mult(r,s)|Div(r,s)) 
 		-> Set.union (aux_e r) (aux_e s)                                                           
    and aux = function
    | Or (a, b) -> Set.union (aux a) (aux b)
    | And (a, b) -> Set.union (aux a) (aux b)
    | (Eq(e1,e2)|Lt(e1,e2)) -> Set.union (aux_e e1) (aux_e e2)
    | Not(a) -> aux a
    | In (Attrs p, _) -> Set.of_list p
    | In (Star, _) -> Set.empty 
    
    in aux cond                                                                      		   

let opti x = match x with
    | Project (Select (t, c), a) ->
    	let s = get_attr_set c in
 	let s_a = Set.of_list a in 
 	if Set.subset s s_a
 		then Select (Project (t, a), c)
 	else x
    | _ -> x
