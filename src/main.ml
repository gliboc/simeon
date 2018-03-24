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
let db_links = Hashtbl.create 10
let _ = Hashtbl.add db_links "Cars" "cars.csv"

let rec repl () =
  let _ = print_string "|> " in
  let stream = Lexing.from_string (read_line ()) in
  let _ =  
    let query = Parser.main Lexer.token stream in
    begin
    	Printf.printf "Your query: %s\n" (AstSql.show_query query);
    	let bytecode = Compiler.compile query in bytecode
     (*	Interpreter.read_data (Interpreter.eval bytecode)
         *)
    end
  in repl ()


let _ =
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
