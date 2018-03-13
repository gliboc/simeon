open Csv;;
open Ast;;
open Interpret;;
open Pervasives;;

type infos = {mutable file : string; mutable data : data option; mutable expr : operator option};;

let create_info () =
	{file = ""; data = None; expr = None}

(* let test () =
  let ui = read_csv ("cars.csv") in
  let op = Projection (Relation ui, ["Year"; "Model"]) in 
  let c = eval op in 
  print c ;;

test ();; *)


(* write_to_csv (read_csv ("cars.csv")) "test.csv";; *)

let rec repl () = 
	let infos = create_info () in
	let _ = print_endline " --- Welcome to simeon's miniSQL engine repl ! --- " in
	let _ = print_string "|> " in
		let lexbuf = read_line () in 
		let _ = print_string lexbuf in
		let _ = print_endline "" in 
	repl ()
;; 

repl ()