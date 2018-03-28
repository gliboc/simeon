(* Contains the type for our data (a record with lists of lists) as
   well as some data reading or writing primitives in CSV format *)
open Csv


type value =
  | Num of int
  | String of string
[@@deriving show]

let value_of_string s =
  try Num (int_of_string s)
  with Failure _ -> String s

type table =
  { mutable attr : Ast.attr_bind list;
    mutable inst : value list list;
    mutable id : string}
[@@deriving show]

type instance = value list list [@@deriving show]

let create_table attr inst name =
    { attr = attr;
      inst = List.map (List.map value_of_string) inst;
      id = name }

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

let rec pprint_data = List.iter (fun x -> print_endline (String.concat " " (List.map show_value x)))
