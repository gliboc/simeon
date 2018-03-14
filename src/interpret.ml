open AstAlg


let cartesian l l' =
  List.concat (List.map (fun e -> List.map (fun e' -> e @ e') l') l)

let rec proj_indices proj = function
  | [] -> []
  | t :: q when List.mem t proj -> true :: proj_indices proj q
  | t :: q -> false :: proj_indices proj q

let rec drop_items (proj : bool list) (l : string list) = match (l, proj) with
  | [], _ -> []
  | t :: q, [] -> failwith "Proj_indices made a mistake"
  | t :: q, true :: q' -> t :: drop_items q' q
  | t :: q, false :: q' -> drop_items q' q

let match_cmp id_value cmp value = match cmp with
  | Eq -> id_value = value
  | Lt -> id_value < value
  | Gt -> id_value > value
  | Leq -> id_value <= value
  | Geq -> id_value >= value

let rec eval_cond id id_value conds = match conds with
  | Cond (id_cond, cmp, value) when id = id_cond ->
    match_cmp id_value cmp value
  | Cond (id_cond, cmp, value) -> true
  | And (c1, c2) -> (eval_cond id id_value c1) && (eval_cond id id_value c2)
  | Or (c1, c2) -> (eval_cond id id_value c1) || (eval_cond id id_value c2)
  | Not c -> not (eval_cond id id_value c)

let rec eval_row_cond attr (conds : cond_expr) row = match (attr, row) with
  | [], _ -> true
  | t :: q, [] -> failwith "Not enough attributes"
  | id :: q, id_value :: xs ->
    (eval_cond id id_value conds) && (eval_row_cond q conds xs )

let rec eval op = match op with
  | Relation d -> d
  | Union (r, s) ->
    let r', s' = eval r, eval s in
    let atr, ats = get_attr r', get_attr s' in
    if atr = ats then
      r' @ List.tl (s')
    else
      failwith "Attributes are not compatible"
  | Product (r, s) ->
    let r', s' = eval r, eval s in
    let atr, ats = get_attr r', get_attr s' in
    let inr, ins = get_inst r', get_inst s' in
    (atr @ ats) :: cartesian inr ins
  | Projection (r, proj) ->
    let r' = eval r in
    let atr = get_attr r' in
    let indices = proj_indices proj atr in
    List.map (drop_items indices) r'
  | Select (r, conds) ->
    let r' = eval r in
    let atr = get_attr r' in
    let inr = get_inst r' in
    atr :: (List.filter (eval_row_cond atr conds) inr)
  | Minus (r,s) ->
    let r', s' = eval r, eval s in
    let atr, ats = get_attr r', get_attr s' in
    let inr, ins = get_inst r', get_inst s' in
    if atr = ats then
      atr :: List.filter (fun row -> not (List.mem row ins)) inr
    else
      failwith "Attributes not compatible for minus operation"
