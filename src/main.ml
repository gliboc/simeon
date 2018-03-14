(*type infos = {mutable file : string;
              mutable data : data option;
              mutable expr : operator option}

let create_info () =
  {file = ""; data = None; expr = None}

(* let test () =
  let ui = read_csv ("cars.csv") in
  let op = Projection (Relation ui, ["Year"; "Model"]) in 
  let c = eval op in 
  print c ;;

test ();; *)*)


(* write_to_csv (read_csv ("cars.csv")) "test.csv";; *)

let rec repl () =
  let _ = print_string "|> " in
  let stream = Lexing.from_string (read_line ()) in
  let _ = try
    let query = Parser.main Lexer.token stream in
    Printf.printf "your query: %s\n" (AstSql.show_query query)
  with
    | Parser.Error -> print_endline "plz can i haz SQL"
  in repl ()


let _ =
  let _ = print_endline " --- Welcome to simeon's miniSQL engine repl ! --- "
  in repl ()
