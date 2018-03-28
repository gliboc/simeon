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

`ast_trans.ml` contains function for transforming the AST in order, for example, to eliminate the IN and NOT IN conditions (ie. transform them into JOIN statements).

The file `compiler.ml` translates the miniSQL ast to the relational algebra.

### Optimizer

`optimizer.ml` contains a function for optimizing the bytecode. It consists simply in pushing down the projections
over the selections when the selection attributes are a subset of the projection ones.

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
- selection, projection, cartesian product, minus, union, join
- renaming for columns and relations
- the two special operator ReadSelectProjectRename and JoinProjectRename
  - ReadSelectProjectRename seems more efficient as it avoids the few table creations
    that would happen if we had chained the operators, by constructing the attributes and the instance at once.
  - JoinProjectRename takes advantage of projecting before doing the cartesian product of the join. Therefore, there are less operations than usual.

In the miniSQL, the following commands are operationnal :
- SELECT .. FROM .. WHERE ..
- SELECT * FROM ..
- UNION, UNION ALL, MINUS
- ORDER BY .. (DESC)
- Conditions IN, NOT IN, translated to pure relationnal algebra joins
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

#### In and NotIn

This part was a bit difficult. At first, we implemented a naive version using pattern matching
to transform an In condition into a normal query, as suggested. But this could not work for nested
queries, neither for combinations of In and Not In.

So we built an ast treatment function, containt in `ast_trans.ml` that would :

 - Transform a set of conditions into a DNF form
 - Purge the conjunctions from IN and NOTIN clauses

