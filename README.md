``` 
  _____ ____  ___ ___    ___   ___   ____  
 / ___/|    ||   |   |  /  _] /   \ |    \ 
(   \_  |  | | _   _ | /  [_ |     ||  _  |
 \__  | |  | |  \_/  ||    _]|  O  ||  |  |
 /  \ | |  | |   |   ||   [_ |     ||  |  |
 \    | |  | |   |   ||     ||     ||  |  |
  \___||____||___|___||_____| \___/ |__|__|
  ```
                                           

This project is being written by *Guillaume Duboc* and *Peio Borthelle*.

The runtime environment used for development is Ocaml 4.06.

The project uses the opam lib `csv` for reading CSV files, and `menhir` for parsing.

## Architecture

### Relational algebra

The file `astAlg.ml` contains type definitions for the relational algebra expressions and operators. It is possible to load csv files into a relation with functions defined in the file.

These expressions can be interpreted using the code in `interpret.ml`. Our current data type is only a record field with the field instance containing a `string string list` and the field name containing the name of the relation.

### miniSQL

`astSql.ml` contains the miniSQL types defined according to the grammar. Such expressions can be parsed from the SQL language using the code in `parser.mly`

The file `compiler.ml` is aimed at translating the miniSQL ast to the relational algebra ast, though it is not fully implemented yet.

### repl

We have a repl that is not very useful yet, though in the future when the compiler is implemented it will allow us to load files and do tests on them.
