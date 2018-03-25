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
Also `ppx_deriving` to manipulate custom types. All are installable through OPAM.

## Architecture

### Relational algebra

The file `astAlg.ml` contains type definitions for the relational algebra expressions and operators. It is possible to load csv files into a relation with functions defined in the file.

These expressions can be interpreted using the code in `interpreter.ml`. Our current data type is only a record field with the field instance containing a `string string list` and the field name containing the name of the relation.

### Data

Our data consists in three field records of type `data` defined in `data.ml`. This module also contains
primitives for reading and writing files in CSV format.

### miniSQL

`astSql.ml` contains the miniSQL types defined according to the grammar. Such expressions can be parsed from the SQL language using the code in `parser.mly`

The file `compiler.ml` is aimed at translating the miniSQL ast to the relational algebra ast, though it is not fully implemented yet.

### repl

The REPL parses SQL queries on the fly. It is now functional.

### Tests

Some working examples can be found in `tested_queries`


## What's working

In the relational algebra, the following operators are functioning:
- selection, projection, cartesion product, relation, minus, union
- `in` in the form of a standalone relational algebra operation. It should be
  replaced with its translation once join is implemented 
- renaming is to be implemented soon
- join is half-implemented too

In the miniSQL, the following commands are operationnal :
- (SELECT attrs | SELECT *) FROM .. WHERE ..
- IN, UNION, MINUS
- nested queries 
