NAME		= ft_turing
NAME_BYTE	= ft_turing_byte
SRC			= src/types.ml src/parser.ml src/main.ml
PKG			= yojson

all: $(NAME)

$(NAME): $(SRC)
	ocamlfind ocamlopt -package $(PKG) -linkpkg -I src $(SRC) -o $(NAME)

bytecode: $(NAME_BYTE)

$(NAME_BYTE): $(SRC)| deps
	ocamlfind ocamlc -package $(PKG) -linkpkg $(SRC) -o $(NAME_BYTE)

deps:
	@command -v ocamlfind > /dev/null 2>&1 || { echo "ocamlfind not found: install OCaml via OPAM"; exit 1; }
	@ocamlfind query $(PKG) > /dev/null 2>&1 || opam install -y $(PKG)

clean:
	rm -f src/*.cmi src/*.cmx src/*.cmo src/*.o

fclean: clean
	rm -f $(NAME) $(NAME_BYTE)

re: fclean all

.PHONY: all bytecode clean fclean re