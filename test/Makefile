.PHONY : all test clean

all : test.native test.byte

test : test.native test.byte $(wildcard tests/*)
	@echo "TESTING test.native"
	@for f in tests/*; do \
		./round_trip.sh ./test.native $$f 2>test.err; \
	done
	@echo "TESTING test.byte"
	@for f in tests/*; do \
		./round_trip.sh ./test.byte $$f 2>test.err; \
	done


test.native : test.ml
	ocamlfind ocamlopt -g -thread -package threads,str,libdash -linkpkg $^ -o test.native
	ldd $@ || otool -L $@

test.byte : test.ml 
	ocamlfind ocamlc -g -thread -package threads,str,libdash -linkpkg $^ -o test.byte

clean :
	rm -f *.o *.cmo *.cmi *.cmx test.native test.byte test.err
