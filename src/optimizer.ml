open Ast
open Algebra

module Set = Set.Make (struct type t=attr_bind
                              let compare = compare end)
exception Get_Attribute

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

let get_attr_rel rel =
    let rec aux = function
        | Project (_, a) -> Set.of_list a
        | File _ -> raise Get_Attribute
        | (Union (a, b)|Product(a,b)|Minus(a,b)|UnionAll(a,b)) -> Set.union (aux a) (aux b)
        | Join(a,b,c) -> Set.union (Set.union (aux a) (aux b)) (get_attr_set c)
        | Rename(a,_) -> aux a
        | ReadSelectProjectRename (_, _, a) -> Set.of_list a
        | JoinProjectRename (a, b, c, d) -> Set.of_list d
        | Select (p, _) -> aux p
        | Order (_, p, _) -> aux p
     in aux rel



let rec opti x = match x with
    | Project (Select (t, c), a) ->
        let s = get_attr_set c in
        let s_a = Set.of_list a in
        if Set.subset s s_a
                then Select (opti @@ Project (t, a), c)
        else Project(opti @@ Select (t, c), a)
    | Select (Product (t, q), c) ->
        let s = get_attr_set c in
        let tt = get_attr_rel t in
        let qq = get_attr_rel q in
                if Set.subset s tt
                 then Product(Select (t, c), q)
                else if Set.subset s qq
                 then Product(t, Select(q,c))
                else
                 begin
                 match c with
                     | And(c1,c2) -> let s1 = get_attr_set c1 in
                                     let s2 = get_attr_set c2 in
                                     if (Set.subset s1 tt) &&
                                        (Set.subset s2 qq)
                                        then Product(Select(t,c1),Select(q,c2))
                                     else if (Set.subset s1 qq) &&
                                            (Set.subset s2 tt)
                                        then Product(Select(t,c2),Select(q,c1))
                                     else Select(opti @@ Product(t,q), c)
                     | _ -> Select(opti @@ Product(t,q), c)
		 end
    | Select(Minus(a, b),c) -> Minus(Select(opti a,c),Select(opti b,c))
    | _ -> x 
