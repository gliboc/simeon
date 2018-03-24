open Csv

type comp =
  | Eq
  | Lt
  | Gt
  | Leq
  | Geq

type cond_expr = Cond of AstSql.attr * comp * AstSql.attr
  | And of cond_expr * cond_expr
  | Or of cond_expr * cond_expr
  | Not of cond_expr

type operator =
  | Void
  | Select of operator * cond_expr
  | Projection of operator * AstSql.attr_bind list
  | Product of operator * operator
  | Relation of string * string
  | Renaming of operator * string
  | Minus of operator * operator
  | Union of operator * operator


let get_attr data = List.hd(data)

let get_inst data = List.tl(data)

let count_attr data =
  let attr = List.hd(data) in List.length attr

(* FIXME let create_void_table () = {instance = [[]]; name = "VoidTable"} *)
let create_void_table () = [[]];;

let parse _ = Relation ("", "")

(* FIXME *)
let exec _ = ()
