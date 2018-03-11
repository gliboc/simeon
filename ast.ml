open Printf

type comp = Eq | Lt | Gt | Leq | Geq
;;

type cond = Id of string * comp
;;

type data = string list list
;;

type operators = 
	  Select of data * cond
	| Project of data
	| Product of data * data
	| Relation of data
	| Renaming of data
	| Minus of data
	| Union of data
;;

let rec write_into_file (data, oc) = match data with
	| DataVoid -> ()
	| List (t, d) -> 
		fprintf oc "%s\n" (tup_to_string t);
		write_into_file (d, oc)
;;

let write_to_csv (data, file) =
	let () =
		let oc = open_out file in
		begin
			write_into_file (data, oc);
			close_out oc;
		end
	in ()



