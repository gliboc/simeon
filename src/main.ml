(* Contains the REPL for miniSQL, as well as the script
   for loading miniSQL queries in *.sql files *)
open Algebra


let rec repl () =
  let _ = print_string "|> " in
  let stream = Lexing.from_string (read_line ()) in
  let _ =
    let query = Parser.main Lexer.token stream in
    begin
    Printf.printf "Your query: %s\n" (Ast.show query);
    let bytecode = Compiler.compile query in
    let _ = Printf.printf "Expression: %s\n" (Algebra.show bytecode)
    in Data.pprint_data (Interpreter.eval bytecode).inst
    end
  in repl ()

let wrap_repl () =
  let _ = print_endline
"  _____ ____  ___ ___    ___   ___   ____
 / ___/|    ||   |   |  /  _] /   \\ |    \\
(   \\_  |  | | _   _ | /  [_ |     ||  _  |
 \\__  | |  | |  \\_/  ||    _]|  O  ||  |  |
 /  \\ | |  | |   |   ||   [_ |     ||  |  |
 \\    | |  | |   |   ||     ||     ||  |  |
  \\___||____||___|___||_____| \\___/ |__|__|
  "
  in repl ()

let () =
  if Array.length Sys.argv > 1 then
    let chan = open_in Sys.argv.(1) in
    let stream = Lexing.from_channel chan in
    let query = Parser.main Lexer.token stream in
    begin
      Printf.printf "Your query: %s\n" (Ast.show query);
      let bytecode = Compiler.compile query in
      let _ = Printf.printf "Expression: %s\n" (Algebra.show bytecode)
      in Data.pprint_data (Interpreter.eval bytecode).inst
    end
  else
    wrap_repl ()
