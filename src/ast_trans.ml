open Ast

let rec match_attr_cond a a' = match (a, a') with
    | ([], _ | _, []) -> failwith "In attributes do not match"
    | [x], [t] -> Eq (Attr x, Attr t)
    | x :: xs, t :: q -> And (Eq (Attr x, Attr t), match_attr_cond xs q)

type term =
  | TEq of expr * expr
  | TNeq of expr * expr
  | TLt of expr * expr
  | TGe of expr * expr
  | TIn of proj * t
  | TNin of proj * t

let cond_of_term = function
  | TEq (e1, e2) -> Eq (e1, e2)
  | TNeq (e1, e2) -> Not (Eq (e1, e2))
  | TLt (e1, e2) -> Lt (e1, e2)
  | TGe (e1, e2) -> Not (Lt (e1, e2))
  | TIn (p, e) -> In (p, e)
  | TNin (p, e) -> Not (In (p, e))

let rec dnf = function
  | Or (a, b) -> dnf a @ dnf b
  | And (a, b) ->
    List.concat (List.map (fun x -> List.map (fun y -> x @ y) (dnf b)) (dnf a))
  | Eq (a, b) -> [[TEq (a, b)]]
  | Lt (a, b) -> [[TLt (a, b)]]
  | In (a, b) -> [[TIn (a, b)]]
  | Not (And (a, b)) -> dnf (Or (Not a, Not b))
  | Not (Or (a, b)) -> dnf (And (Not a, Not b))
  | Not (Not a) -> dnf a
  | Not (Eq (a, b)) -> [[TNeq (a, b)]]
  | Not (Lt (a, b)) -> [[TGe (a, b)]]
  | Not (In (a, b)) -> [[TNin (a, b)]]

(* split a conjunction into common terms, TIn's and TNin's *)
let split_conj =
  let rec aux xs ys zs = function
    | [] -> (xs, ys, zs)
    | TIn (a, b) :: ts -> aux xs ((a, b) :: ys) zs ts
    | TNin (a, b) :: ts -> aux xs ys ((a, b) :: zs) ts
    | t :: ts -> aux (t :: xs) ys zs ts
  in aux [] [] []

let rec in_to_join r (p, q) = match bubble q with
  | Select (p', r', c') ->
    let (p, p') = match p, p' with
      | Attrs p, Attrs p' -> p, p'
      | _, _ -> failwith "subquery lifting not implemented for STAR selection" in
    (Join (r, r', match_attr_cond p p'), c')
  | _ -> failwith "subquery lifting not implemented for union/minus!"

(* take a query and return one without IN operator *)
and bubble = function
  | UnionAll (q1, q2) -> UnionAll (bubble q1, bubble q2)
  | Union (q1, q2) -> Union (bubble q1, bubble q2)
  | Order (p, q, b) -> Order (p, bubble q, b)
  | Minus (q1, q2) -> Minus (bubble q1, bubble q2)
  | Select (p, r, None) -> Select (p, r, None)
  | Select (p, r, Some c) ->
    let dc = dnf c in
    let aux conj =
      let (xs, ys, zs) = split_conj conj in
      let c = match xs with
        | [] -> None
        | x :: xs -> Some (List.fold_left
          (fun a b -> And (a, cond_of_term b))
          (cond_of_term x) xs) in
      let handle_in (r, c) x =
        let (r, c') = in_to_join r x in
        let c = match (c, c') with
          | Some c, Some c' -> Some (And (c, c'))
          | Some c, None | None, Some c -> Some c
          | _ -> None in
        (r, c) in
      let (r', c') = List.fold_left handle_in
        (r, c) ys in
      List.fold_left
        (fun q x ->
          let (r, c) = in_to_join r x in
          Minus (q, Select (p, r, c)))
        (Select (p, r', c')) zs in
    List.fold_left (fun q conj -> Union (q, aux conj))
      (aux (List.hd dc))
      (List.tl dc)
