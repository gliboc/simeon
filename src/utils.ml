(* Utility functions, mainly used in Interpreter *)
(* Should probably be added in a module type *)
open Ast
open Data

type row = string list [@@deriving show]
type index = bool list [@@deriving show]

let rec is_in_column tuple = function
    [] -> false
    | row :: rs when tuple = row -> true
    | _ :: rs -> is_in_column tuple rs

let check_in tuple table =
    let _ = Printf.printf "Checking in for %s\n" (show_row tuple) in
    let _ = Printf.printf "In table %s\n\n" (show_instance table.inst) in
    if List.length table.attr != List.length tuple 
       then failwith "The number of columns for IN doesn't match"
    else
       is_in_column tuple table.inst 


let cartesian l l' =
  List.concat (List.map (fun e -> List.map (fun e' -> e @ e') l') l)

let rec attr_mem a = function
    | [] -> false
    | ((a', _) :: _) when (fst a) = a' -> true
    | ((_, al) :: _) when (snd a) = al -> true
    | _ :: xs -> attr_mem a xs             
    

let rec get_attr_index a i = function
    | [] -> failwith "Attribute does not exist."
    | ((a', _) :: _) when (fst a) = a' -> i
    | ((_, al) :: _) when (snd a) = al -> i
    | _ :: xs -> get_attr_index a (i+1) xs             

let rec make_list n v = match n with
    | 0 -> []
    | k when k > 0 -> v :: (make_list (k-1) v)
    | _ -> failwith "Can't create list : negative length"                          

let slct_ind attr l = 
    List.map (fun a -> attr_mem a attr) l  

let rec drop_items proj l = match (l, proj) with
  | [], _ -> []
  | t :: q, [] -> failwith "Proj_indices made a mistake"
  | t :: q, true :: q' -> t :: drop_items q' q
  | t :: q, false :: q' -> drop_items q' q

let get_alias attr = snd attr

let rec get_val (attr : attr_bind list) row (a : attr_bind) = match (attr, row) with
    | (([], _) | (_, [])) -> failwith "Attribute not found"
    | ((a', _) :: _, el :: _) when (fst a) = a' -> el
    | ((_, Some al) :: _, el :: _) when Some al = (snd a) -> el
    | (_ :: attr', _ :: r) -> get_val attr' r a

let rec get_attr_values attr row acc = function
    | [] -> List.rev acc
    | x :: xs -> let v = get_val attr row x in
                 get_attr_values attr row (v :: acc) xs   


