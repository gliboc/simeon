open Csv;;
open Ast;;
open Interpret;;


let test () =
  let ui = read_csv ("cars.csv") in
  let op = Projection (Relation ui, ["Year"; "Model"]) in 
  let c = eval op in 
  print c ;;

test ();;





write_to_csv (read_csv ("cars.csv")) "test.csv";;