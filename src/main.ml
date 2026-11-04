let usage_msg = "usage: ft_turing [-h] jsonfile input\n
positional arguments:
  jsonfile\tjson description of the machine
  input\t\tinput of the machine
\noptional arguments:
  -h, --help\tshow this help message and exit"

let () =
  match Array.to_list Sys.argv with
  | [ _; ("-h" | "--help") ] -> print_endline usage_msg

  | [ _; jsonfile; _ ] -> 
    (match Parser.load_machine jsonfile with
      | Ok _ -> print_endline "machine ok"
      | Error msg -> prerr_endline ("Error: " ^ msg); exit 1)

  | _ -> prerr_endline "Error: ft_turing expected 2 arguments (jsonfile input)\nTry './ft_turing --help' for more information"; exit 1

