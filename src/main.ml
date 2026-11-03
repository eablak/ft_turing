let usage_msg = "usage: ft_turing -[h] jsonfile input\n
positional arguments:\n
  jsonfile\t\tjson description of the machine\n
  input\t\tinpıut of the machine
\noptional arguments:\n
  -h, --helps\t\tshow this help message and exit"

let () =
  match Array.to_list Sys.argv with
  | [ _; ("-h" | "--help") ] -> print_endline usage_msg
  | [ _; jsonfile; input ] -> (*continue*)
    ignore (jsonfile, input)
  | _ -> prerr_endline usage_msg; exit 1

