open Csv

type comp =
  | Eq
  | Lt
  | Gt
  | Leq
  | Geq

type cond_expr = Cond of string * comp * string
  | And of cond_expr * cond_expr
  | Or of cond_expr * cond_expr
  | Not of cond_expr

(* FIXME this will be new type of data
 * type data = {instance : string list list; name : string} *)

type data = string list list (* using not to break compilation atm *)

type operator =
  | Void
  | Select of operator * cond_expr
  | Projection of operator * string list
  | Product of operator * operator
  | Relation of data
  | Renaming of operator * string
  | Minus of operator * operator
  | Union of operator * operator

let read_csv (filename) =
  let ic = of_channel (open_in filename) in
  let csv_file = input_all ic in
  let _ = close_in ic in csv_file

let write_to_csv data filename =
  let oc = to_channel (open_out filename) in
  let _ = output_all oc data in close_out oc

let get_attr data = List.hd(data)

let get_inst data = List.tl(data)

let count_attr data =
  let attr = List.hd(data) in List.length attr

(* FIXME let create_void_table () = {instance = [[]]; name = "VoidTable"} *)
let create_void_table () = [[]];;

let parse _ = Relation (create_void_table ())

(* FIXME *)
let exec _ = ()
