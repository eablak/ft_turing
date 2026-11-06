NAME		= ft_turing
NAME_BYTE	= ft_turing_byte
SRC			= src/types.ml src/parser.ml src/simulator.ml src/complexity.ml src/main.ml
PKG			= yojson

all: $(NAME)

$(NAME): $(SRC) | deps
	opam exec -- ocamlfind ocamlopt -package $(PKG) -linkpkg -I src $(SRC) -o $(NAME)

bytecode: $(NAME_BYTE)

$(NAME_BYTE): $(SRC) | deps
	opam exec -- ocamlfind ocamlc -package $(PKG) -linkpkg -I src $(SRC) -o $(NAME_BYTE)

deps:
	@if ! command -v opam > /dev/null 2>&1; then \
		echo "opam not found. Installing OCaml and OPAM..."; \
		if [ "$$(uname -s)" = "Darwin" ]; then \
			command -v brew > /dev/null 2>&1 || { echo "Error: Homebrew is required on macOS"; exit 1; }; \
			brew install ocaml opam; \
		elif [ "$$(uname -s)" = "Linux" ]; then \
			if command -v apt-get > /dev/null 2>&1; then \
				sudo apt-get update && sudo apt-get install -y ocaml opam build-essential m4 unzip bubblewrap; \
			elif command -v dnf > /dev/null 2>&1; then \
				sudo dnf install -y ocaml opam make gcc m4 unzip bubblewrap; \
			elif command -v pacman > /dev/null 2>&1; then \
				sudo pacman -Sy --noconfirm ocaml opam base-devel m4 unzip bubblewrap; \
			else \
				curl -fsSL https://opam.ocaml.org/install.sh | sh; \
			fi; \
		fi; \
	fi
	@if [ ! -d "$$HOME/.opam" ]; then \
		echo "Initializing OPAM..."; \
		opam init -y --disable-sandboxing --bare; \
	fi
	@if [ -z "$$(opam switch show 2>/dev/null)" ]; then \
		echo "Creating OPAM switch..."; \
		opam switch create default ocaml-system 2>/dev/null || opam switch create default 5.2.1 -y; \
	fi
	@opam exec -- command -v ocamlfind > /dev/null 2>&1 || opam install -y ocamlfind
	@opam exec -- ocamlfind query $(PKG) > /dev/null 2>&1 || opam install -y $(PKG)

clean:
	rm -f src/*.cmi src/*.cmx src/*.cmo src/*.o

fclean: clean
	rm -f $(NAME) $(NAME_BYTE)

re: fclean all

.PHONY: all bytecode clean fclean re