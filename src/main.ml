let usage_msg = "usage: ft_turing [-h] jsonfile input\n
positional arguments:
  jsonfile\tjson description of the machine
  input\t\tinput of the machine
\noptional arguments:
  -h, --help\tshow this help message and exit"

let () =
  match Array.to_list Sys.argv with
  | [ _; ("-h" | "--help") ] -> print_endline usage_msg

  | [ _; jsonfile; input ] -> 
    (match Parser.load_machine jsonfile with
    | Error msg -> prerr_endline ("Error: " ^ msg); exit 1
    | Ok m ->
      (match Parser.validate_input m input with
      | Error msg -> prerr_endline ("Error: " ^ msg); exit 1
      | Ok _ -> print_endline "input ok"))

  | _ -> prerr_endline "Error: ft_turing expected 2 arguments (jsonfile input)\nTry './ft_turing --help' for more information"; exit 1

