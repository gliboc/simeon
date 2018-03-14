{
open Parser
exception Bad_token of string
}

let alpha = ['a'-'z' 'A'-'Z']
let ident = alpha (alpha | ['0'-'9' '_'])*
let file = (alpha | ['0'-'9' '_' '-'])+ ".csv"

rule token = parse
  | [' ' '\t' '\n' ]  { token lexbuf }
  | "SELECT"   { SELECT }
  | "FROM"     { FROM }
  | "WHERE"    { WHERE }
  | "AS"       { AS }
  | "IN"       { IN }
  | "MINUS"    { MINUS }
  | "UNION"    { UNION }
  | "AND"      { AND }
  | "OR"       { OR }
  | "NOT"      { NOT }
  | '='        { EQ }
  | '<'        { LT }
  | ','        { COMMA }
  | '.'        { DOT }
  | '('        { LPAR }
  | ')'        { RPAR }
  | ident      { ID (Lexing.lexeme lexbuf) }
  | file       { FILE (Lexing.lexeme lexbuf) }
  | eof        { EOF }
  | _          { raise (Bad_token (Lexing.lexeme lexbuf)) }
