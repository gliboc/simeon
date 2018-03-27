{
open Parser
exception Bad_token of string
}

let alpha = ['a'-'z' 'A'-'Z']
let ident = alpha (alpha | ['0'-'9' '_'])*
let file = '"' (alpha | ['0'-'9' '_' '-'])+ ".csv" '"'
let str = '"' [^ '"']* '"'
let num = ['0'-'9']+

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
  | "JOIN"     { JOIN }
  | "ON"       { ON }
  | "ORDER BY" { ORDER }
  | "DESC"     { DESC }
  | "*"        { STAR }
  | '+'        { ADD }
  | '-'        { SUB }
  | '/'        { DIV }
  | "<="       { LEQ }
  | '<'        { LT }
  | ">="       { GEQ }
  | '>'        { GT }
  | '='        { EQ }
  | ','        { COMMA }
  | '.'        { DOT }
  | '('        { LPAR }
  | ')'        { RPAR }
  | ident      { ID (Lexing.lexeme lexbuf) }
  | file       { FILE (Lexing.lexeme lexbuf) }
  | '"'        { read_string (Buffer.create 17) lexbuf }
  | num        { NUM (int_of_string (Lexing.lexeme lexbuf)) }
  | eof        { EOF }
  | _          { raise (Bad_token (Lexing.lexeme lexbuf)) }

and read_string buf = parse
  | '"'        { STRING (Buffer.contents buf) }
  | "\\\\"     { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | "\\t"      { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | "\\\""     { Buffer.add_char buf '"'; read_string buf lexbuf }
  | "\\r"      { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | "\\n"      { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | [^ '"' '\\' ] {Buffer.add_string buf (Lexing.lexeme lexbuf); read_string buf lexbuf }
  | _          { raise (Bad_token ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof        { raise (Bad_token ("String not terminated")) }
