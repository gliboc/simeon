(* Interpreter for a relational algebra syntaxic tree *)
open Algebra
open Data

type row = string list [@@deriving show]

let cartesian l l' =
  List.concat (List.map (fun e -> List.map (fun e' -> e @ e') l') l)
let slct_ind attr l = 
    List.map (fun a -> List.mem a attr) l  

let rec drop_items proj l = match (l, proj) with
  | [], _ -> []
  | t :: q, [] -> failwith "Proj_indices made a mistake"
  | t :: q, true :: q' -> t :: drop_items q' q
  | t :: q, false :: q' -> drop_items q' q

let rec get_val attr row a = match (attr, row) with
    | (([], _) | (_, [])) -> failwith "Attribute not found"
    | ((a', _) :: _, el :: _) when a = a' -> el
    | (_ :: attr', _ :: r) -> get_val attr' r a

let rec fltr attr a1 a2 cmp row = 
    let (a, a') = (get_val attr row a1, get_val attr row a2) in 
    	cmp a a'

and fltr_cst attr a1 cst cmp row =
    let k = get_val attr row a1 in 
        cmp k cst

and fltr_rw attr c row = match c with
    | Eq (a1, a2) -> fltr attr a1 a2 (=) row 
    | Lt (a1, a2) -> fltr attr a1 a2 (<) row 
    | EqCst (a1, v) -> fltr_cst attr a1 v (=) row 
    | LtCst (a1, v) -> fltr_cst attr a1 v (<) row 
    | And(c1, c2) -> (fltr_rw attr c1 row) && (fltr_rw attr c2 row)
    | Or(c1, c2) -> (fltr_rw attr c1 row) || (fltr_rw attr c2 row)
    | In (a, op) -> let table = eval op in check_in attr a table row
    | Not (op) -> not (fltr_rw attr op row)

and check_in attr a' table row =
    if List.length table.attr > 1
       then failwith "Expected number of columns: 1"
    else
       let a = get_val attr row a' in is_in_table a table.inst

and is_in_table a = function
    | [] -> false
    | x :: xs -> (List.mem a x) || (is_in_table a xs)  

and eval op = 
  let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
  begin match op with
  | Relation (d, id) -> let _ = Printf.printf "Loading file %s\n" d in
    			let l = read_csv (String.sub d 1 (String.length d - 2)) in
    			let _ = Printf.printf "File looks like :\n %s\n" (show_instance l) in
    			let attr, inst = List.hd (l), List.tl (l) in
    			let tab = create_table (create_attr id attr) inst id in
    			let _ = Printf.printf "Table looks like :\n%s\n\n" (show_table tab) in
    			tab
  
  | Union (r, s) ->
      let r', s' = eval r, eval s in
      let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
      let atr, ats = r'.attr , s'.attr in
      if atr = ats then
        create_table atr (r'.inst @ s'.inst) "dummy"
      else
        failwith "Attributes are not compatible for union"
  
  | Product (r, s) ->
      let r', s' = eval r, eval s in
      let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
      let tab = create_table (r'.attr @ s'.attr) (cartesian r'.inst s'.inst) "dummy" in
      let _ = Printf.printf "Table looks like :\n%s\n\n" (show_table tab) in tab

  | Projection (r, proj) ->
      let r' = eval r in
      let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
      let _ = Printf.printf "Table looks like :\n %s\n\n" (show_table r') in
      let slct = slct_ind proj r'.attr in
      	create_table (drop_items slct r'.attr) (List.map (drop_items slct) r'.inst) r'.id
  
  | Select (r, cond) ->
      let r' = eval r in
      let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
      let _ = Printf.printf "Table looks like :\n %s\n\n" (show_table r') in
        create_table (r'.attr) (List.filter (fltr_rw r'.attr cond) r'.inst) "dummy"
  
  | Minus (r,s) ->
      let r', s' = eval r, eval s in
      let _ = Printf.printf "Evaluating %s\n\n" (show_operator op) in
      if r'.attr = s'.attr then
        create_table (r'.attr) (List.filter (fun row -> not (List.mem row s'.inst)) r'.inst) r'.id
      else
        failwith "Attributes not compatible for minus operation"
  
  | Join (r, s, c) ->
      eval (Select (Product (r, s), c))
 
  | Renaming (_) -> (*TODO*) failwith "Implement renaming"
          
  end     





