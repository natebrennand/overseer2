
OCAMLC=ocamlc
OCAMLDEP=ocamldep

OFLAGS=-w A # warn about everything
# OFLAGS=-w -A # silence everything


LIBS = str.cma unix.cma
OVERSEER_OBJS = overseer.cmo

default: overseer

all: clean overseer

overseer: $(OVERSEER_OBJS)
	$(OCAMLC) $(LIBS) -o overseer $(OVERSEER_OBJS)
	./overseer **/*.ml -c make

overseer.cmo: overseer.ml

.PHONY: clean overseer all
clean:
	rm -f overseer *.cmo *.cmi *.out *.diff

%.cmo: %.ml
	$(OCAMLC) $(OFLAGS) -c $<

%.cmi: %.mli
	$(OCAMLC) $(OFLAGS) -c $<
