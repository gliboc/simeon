(* Contains the type for our data (a record with lists of lists) as
   well as some data reading or writing primitives in CSV format *)
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

let rec pprint_data = function
    | [] -> ()
    | x :: xs -> let _ = Printf.printf "%s\n"
                 (List.fold_right (fun x s -> x ^ " " ^ s)
                 		 x "") ;
      		 in pprint_data xs
             
    

