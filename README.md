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

The file `algebra.ml` contains type definitions for the relational algebra.
These expressions can be interpreted using the code in `interpreter.ml`. 
Our current data type is a record field with the field instance containing a `string string list` and the field name containing the name of the relation.

### Data

Our data consists in three field records of type `data` defined in `data.ml`. This module also contains
primitives for reading and writing files in CSV format.

### miniSQL

`ast.ml` contains the miniSQL AST defined according to the grammar. Such expressions can be parsed from the miniSQL language using the code in `parser.mly`

The file `compiler.ml` translates the miniSQL ast to the relational algebra.

### Autres

`testing_renaming.ml` montre un exemple de fonctionnement du renaming de relation, prenant en compte les possibles conflits.

## Usage

### Build

`make` in the root directory should suffice

### repl

The REPL parses SQL queries on the fly.
You can launch it using `./main.native`, or if you have `rlwrap` installed, using `rlwrap ./main.native` for more convenience.

### Tests

Some working examples can be found in `tested_queries`

## Implementation

### What's working

In the relational algebra, the following operators are working:
- selection, projection, cartesian product, minus, union
- join
- renaming for columns and relations is implemented

In the miniSQL, the following commands are operationnal :
- SELECT .. FROM .. WHERE ..
- SELECT * FROM ..
- UNION, UNION ALL, MINUS
- ORDER BY .. (DESC)
- Conditions IN, NOT IN
- Conditions on advanced numerical expressions ('+', '-', '*')
- Logical formulas (/\, \/, !)

### Details

#### Renaming
We noticed that the renaming operation was a bit shady for a table 
resulting from a cartesion product between relations having 
same attribute names.

Example from sqlite :
`(SELECT e.a, f.a FROM T AS e, T' AS f) AS g`

In this case, T and T' having attribute a, sqlite's reaction is
to number the columns in conflict. Therefore, `e.a` and `f.a` would
respectively become `g.a` and `g.a:1`. This is the behavior 
we chose when implementing renaming.

### Union

Union is a set union, so it deletes duplicata. We implemented UNION ALL to
allow them.
