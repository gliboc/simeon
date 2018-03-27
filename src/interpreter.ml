(* Interpreter for a relational algebra syntaxic tree *)
open Algebra
open Data
open Ast
open Utils

let rec fltr debug attr a1 a2 cmp row = 
    let (a, a') = (get_val attr row a1, get_val attr row a2) in 
    let _ = if debug then Printf.printf "Comparing values %s and %s\n" a a' in    
    let resu = cmp a a' in 
    let _ = if debug then Printf.printf "The result is : %s\n\n" (string_of_bool resu) in resu

and fltr_cst debug attr a1 cst cmp row =
    let k = get_val attr row a1 in 
        cmp k cst

and fltr_rw debug attr c row = match c with
    | Eq (Attr a1, Attr a2) -> fltr debug attr a1 a2 (=) row 
    | Lt (Attr a1, Attr a2) -> fltr debug attr a1 a2 (<) row 
    | Eq (Attr a1, String v) -> fltr_cst debug attr a1 v (=) row 
    | Lt (Attr a1, String v) -> fltr_cst debug attr a1 v (<) row 
    | And (c1, c2) -> (fltr_rw debug attr c1 row) && (fltr_rw debug attr c2 row)
    | Or (c1, c2) -> (fltr_rw debug attr c1 row) || (fltr_rw debug attr c2 row)
    | In (Attrs a, op) -> let table = eval debug op in 
                          let tuple = get_attr_values attr row [] a in
                         check_in tuple table
    | Not (op) -> not (fltr_rw debug attr op row)

and eval debug = fun op -> 
  let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
  begin match op with
  | File (d, id) -> let _ = if debug then Printf.printf "Loading file %s\n" d in
                        let l = read_csv (String.sub d 1 (String.length d - 2)) in
                        let _ = if debug then Printf.printf "File looks like :\n %s\n" (show_instance l) in
                        let attr, inst = List.hd (l), List.tl (l) in
                        let tab = create_table (create_attr id attr) inst id in
                        let _ = if debug then Printf.printf "Table looks like :\n%s\n\n" (show_table tab) in
                        tab
  
  | Union (r, s) ->
      let r', s' = eval debug r, eval debug s in
      let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
      let atr, ats = r'.attr , s'.attr in
      if atr = ats then
        create_table atr (r'.inst @ s'.inst) "dummy"
      else
        failwith "Attributes are not compatible for union"
  
  | Product (r, s) ->
      let r', s' = eval debug r, eval debug s in
      let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
      let tab = create_table (r'.attr @ s'.attr) (cartesian r'.inst s'.inst) "dummy" in
      let _ = if debug then Printf.printf "Table looks like :\n%s\n\n" (show_table tab) in tab

  | Project (r, proj) ->
      let r' = eval debug r in
      let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
      let _ = if debug then Printf.printf "Table looks like :\n %s\n\n" (show_table r') in
      let slct = slct_ind proj r'.attr in
      let _ = if debug then Printf.printf "Evaluating index of projection %s\n" (List.fold_left (fun a b -> a^(show_attr_bind b)) "" proj) in
      let _ = if debug then Printf.printf "Index to be kept are:\n%s\n\n" (show_index slct) in
      let _ = if debug then Printf.printf "On attributes %s\n\n" (List.fold_left (fun a b -> a^(show_attr_bind b)) "" r'.attr) in
        create_table (drop_items slct r'.attr) (List.map (drop_items slct) r'.inst) r'.id
  
  | Select (r, cond) ->
      let r' = eval debug r in
      let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
      let _ = if debug then Printf.printf "Table looks like :\n %s\n\n" (show_table r') in
        create_table (r'.attr) (List.filter (fltr_rw debug r'.attr cond) r'.inst) "dummy"
  
  | Minus (r,s) ->
      let r', s' = eval debug r, eval debug s in
      let _ = if debug then Printf.printf "Evaluating %s\n\n" (Algebra.show op) in
      if r'.attr = s'.attr then
        create_table (r'.attr) (List.filter (fun row -> not (List.mem row s'.inst)) r'.inst) r'.id
      else
        failwith "Attributes not compatible for minus operation"
  
  | Join (r, s, c) ->
      eval debug (Select (Product (r, s), c))
 
  | Rename (r, s) -> 
       let r' = eval debug r in
       
       let hash = Hashtbl.create (List.length r'.attr) in
       let rec rename id hash = function
          | ((rel, att), al) :: xs when Hashtbl.mem hash att ->  
                  let ix = Hashtbl.find hash att in 
                  begin
                      Hashtbl.replace hash att (ix+1);
                      ((id, att ^ ":" ^ (string_of_int ix)), al) :: (rename id hash xs)
                  end
          | ((rel, att), al) :: xs ->
                begin
                   Hashtbl.add hash att 1;
                   ((id, att), al) :: (rename id hash xs)
                end
       in let renamed_attr = rename s hash r'.attr in                                                                                                             
          create_table (renamed_attr) (r'.inst) (r'.id)
  
  | Order (a, r) ->
	let r' = eval debug r in
 	let cmp r1 r2 =
 		let v1 = get_attr_values a r1 [] in
 		let v2 = get_attr_values a r2 [] in
 		if (r1 = r2) then 0
 		else if (r1 < r2) then -1
 		else 1                 
	in let ordered_inst = List.sort cmp r'.inst
 	in create_table (r'.attr) (ordered_inst) (r'.id)                      
   end     





