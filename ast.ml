open Printf
open Csv

type comp = Eq | Lt | Gt | Leq | Geq
;;

type cond_expr = Cond of string * comp * string
			   | And of cond_expr * cond_expr
			   | Or of cond_expr * cond_expr
			   | Not of cond_expr
;;

type data = string list list
;;

type operator = 
	  Select of operator * cond_expr
	| Projection of operator * string list
	| Product of operator * operator
	| Relation of data
	| Renaming of operator
	| Minus of operator * operator
	| Union of operator * operator
;;

let read_csv (filename) =
  let ic = of_channel (open_in filename) in
  let csv_file = input_all ic in
  let _ = close_in ic in csv_file
;;

let write_to_csv data filename =
	let oc = to_channel (open_out filename) in
	let _ = output_all oc data in close_out oc
;;

let get_attr data = List.hd(data)

let get_inst data = List.tl(data)

let count_attr data =
	let attr = List.hd(data) in List.length attr




