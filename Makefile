NAME		= ft_turing
NAME_BYTE	= ft_turing_byte
SRC			= src/types.ml src/parser.ml src/simulator.ml src/complexity.ml src/main.ml
PKG			= yojson
LOCAL_BIN	= $(HOME)/.local/bin
export PATH := $(LOCAL_BIN):/opt/homebrew/bin:/usr/local/bin:$(PATH)

all: $(NAME)

$(NAME): $(SRC) | deps
	opam exec -- ocamlfind ocamlopt -package $(PKG) -linkpkg -I src $(SRC) -o $(NAME)

bytecode: $(NAME_BYTE)

$(NAME_BYTE): $(SRC) | deps
	opam exec -- ocamlfind ocamlc -package $(PKG) -linkpkg -I src $(SRC) -o $(NAME_BYTE)

deps:
	@mkdir -p "$(LOCAL_BIN)"
	@if ! command -v opam > /dev/null 2>&1; then \
		echo "opam not found. Installing OPAM to $(LOCAL_BIN) without sudo..."; \
		if [ "$$(uname -s)" = "Darwin" ] && command -v brew > /dev/null 2>&1; then \
			brew install ocaml opam; \
		else \
			OS=$$(uname -s); \
			ARCH=$$(uname -m); \
			case "$$OS-$$ARCH" in \
				Linux-x86_64)   OPAM_ARCH="x86_64-linux" ;; \
				Linux-aarch64)  OPAM_ARCH="arm64-linux" ;; \
				Linux-i686)     OPAM_ARCH="i686-linux" ;; \
				Darwin-arm64)   OPAM_ARCH="arm64-macos" ;; \
				Darwin-x86_64)  OPAM_ARCH="x86_64-macos" ;; \
				*) echo "Unsupported architecture: $$OS-$$ARCH"; exit 1 ;; \
			esac; \
			curl -fsSL "https://github.com/ocaml/opam/releases/download/2.2.1/opam-2.2.1-$$OPAM_ARCH" -o "$(LOCAL_BIN)/opam" && \
			chmod +x "$(LOCAL_BIN)/opam"; \
		fi; \
	fi
	@if [ ! -d "$$HOME/.opam" ]; then \
		echo "Initializing OPAM (user-local, no sudo)..."; \
		opam init -y --disable-sandboxing --bare; \
	fi
	@if [ -z "$$(opam switch show 2>/dev/null)" ]; then \
		echo "Creating OPAM switch..."; \
		if command -v ocamlc > /dev/null 2>&1; then \
			opam switch create default ocaml-system -y || opam switch create default 5.2.1 -y; \
		else \
			opam switch create default 5.2.1 -y; \
		fi; \
	fi
	@opam exec -- command -v ocamlfind > /dev/null 2>&1 || opam install -y ocamlfind
	@opam exec -- ocamlfind query $(PKG) > /dev/null 2>&1 || opam install -y $(PKG)

clean:
	rm -f src/*.cmi src/*.cmx src/*.cmo src/*.o

fclean: clean
	rm -f $(NAME) $(NAME_BYTE)

re: fclean all

.PHONY: all bytecode clean fclean re