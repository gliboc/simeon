open AstAlg
open Csv

type table =
  { mutable attr : AstSql.attr_bind list;
    mutable inst : string list list;
    mutable id : string}
[@@deriving show]

type instance = string list list [@@deriving show]

let create_table attr inst name =
    { attr = attr; inst = inst; id = name}

let rec create_attr id = function
    | [] -> []
    | x :: xs -> ((id, x), None) :: create_attr id xs             

let read_csv filename =
  let ic = of_channel (open_in filename) in
  let csv_file = input_all ic in
  let _ = close_in ic in csv_file

let write_to_csv data filename =
  let oc = to_channel (open_out filename) in
  let _ = output_all oc data in close_out oc

let rec read_data = function
    | [] -> ()
    | x :: xs -> let _ = Printf.printf "%s\n"
                 (List.fold_right (fun x s -> x ^ " " ^ s)
                 		 x "") ;
      		 in read_data xs
    
let cartesian l l' =
  List.concat (List.map (fun e -> List.map (fun e' -> e @ e') l') l)

let slct_ind attr l = 
    List.map (fun a -> List.mem a attr) l  

let rec drop_items proj l = match (l, proj) with
  | [], _ -> []
  | t :: q, [] -> failwith "Proj_indices made a mistake"
  | t :: q, true :: q' -> t :: drop_items q' q
  | t :: q, false :: q' -> drop_items q' q

let eval_cond cmp a a' = match cmp with
    | Eq -> a = a'


let rec fltr attr a1 a2 cmp (u, v) row = match (attr, row) with
    | ([], _) -> begin match (u, v) with
        	   | (Some a, Some a') -> eval_cond cmp a a'
                   | _ -> failwith "The condition you expressed is invalid:\nKeys do not exist in constructed table"
 		 end                                       
    | ((a, _) :: attrs, el :: r) when a = a1 -> fltr attrs a1 a2 cmp (Some el, v) r
    | ((a, _) :: attrs, el :: r) when a = a2 -> fltr attrs a1 a2 cmp (u, Some el) r
    | ((a, _) :: attrs, el :: r) -> fltr attrs a1 a2 cmp (u, v) r                                                                                                                              

and fltr_rw attr c row = match c with
    | Cond(a1, cmp, a2) -> fltr attr a1 a2 cmp (None, None) row
    | And(c1, c2) -> (fltr_rw attr c1 row) && (fltr_rw attr c2 row)
    | Or(c1, c2) -> (fltr_rw attr c1 row) || (fltr_rw attr c2 row)  


let rec eval op = 
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
  end     





