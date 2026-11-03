NAME		= ft_turing
NAME_BYTE	= ft_turing_byte
SRC			= src/main.ml

all: $(NAME)

$(NAME): $(SRC)
	ocamlfind ocamlopt $(SRC) -o $(NAME)

bytecode: $(NAME_BYTE)

$(NAME_BYTE): $(SRC)
	ocamlfind ocamlopt $(SRC) -o $(NAME_BYTE)


clean:
	rm -f src/*.cmi src/*.cmx src/*.cmo src/*.o

fclean: clean
	rm -f $(NAME) $(NAME_BYTE)

re: fclean all

.PHONY: all bytecode clean fclean re