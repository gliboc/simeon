(* Contains the REPL for miniSQL, as well as the script
   for loading miniSQL queries in *.sql files *)
open Algebra


let rec repl debug () =
  let _ = print_string "|> " in
  let stream = Lexing.from_string (read_line ()) in
  let _ =
    let query = Parser.main Lexer.token stream in
    begin
    if debug then Printf.printf "Your query: %s\n" (Ast.show query);
    let query = Ast_trans.bubble query in
    if debug then Printf.printf "Your new query: %s\n" (Ast.show query);
    let bytecode = Compiler.compile debug query in
    let _ = if debug then Printf.printf "Expression: %s\n" (Algebra.show bytecode)
    in Data.pprint_data (Interpreter.eval debug bytecode).inst
    end
  in repl debug ()

let wrap_repl debug () =
  let _ = print_endline
"  _____ ____  ___ ___    ___   ___   ____
 / ___/|    ||   |   |  /  _] /   \\ |    \\
(   \\_  |  | | _   _ | /  [_ |     ||  _  |
 \\__  | |  | |  \\_/  ||    _]|  O  ||  |  |
 /  \\ | |  | |   |   ||   [_ |     ||  |  |
 \\    | |  | |   |   ||     ||     ||  |  |
  \\___||____||___|___||_____| \\___/ |__|__|
  "
  in repl debug ()

let ask_debug () =
    let _ = Printf.printf "Debug mode? y/n\n" in
    let answ = read_line () in
    if answ = "y" then true
    else false
      

let () =
    let debug = ask_debug () in
  if Array.length Sys.argv > 1 then
    let chan = open_in Sys.argv.(1) in
    let stream = Lexing.from_channel chan in
    let query = Parser.main Lexer.token stream in
    begin
      if debug then Printf.printf "Your query: %s\n" (Ast.show query);
      let bytecode = Compiler.compile debug query in
      let _ = if debug then Printf.printf "Expression: %s\n" (Algebra.show bytecode)
      in Data.pprint_data (Interpreter.eval debug bytecode).inst
    end
  else
    wrap_repl debug ()
