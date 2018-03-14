(* Converting a miniSQL ast to a relationnal algebra ast *)
open AstSql

let compile_cond cond = function
  | x -> x (* todo *)
;;

let rec compile = function 
  | MINUS (s1, s2) -> Minus (compile s1, compile s2)
  | UNION (s1, s2) -> Union (compile s1, compile s2)
  | SELECT (atts, rels, cond) -> Void (* todo*) 
;;     
