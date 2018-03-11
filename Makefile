all:
	ocamlbuild -package csv -lib unix main.native
clean:
	ocamlbuild -clean
