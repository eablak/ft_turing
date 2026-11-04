open Types

let read_file path =
  try
    let ic = open_in_bin path in
    Fun.protect
      ~finally:(fun () -> close_in_noerr ic)
      (fun () -> Ok (really_input_string ic (in_channel_length ic)))
  with Sys_error msg | Failure msg -> Error ("cannot read file: " ^ msg)

let parse_json content = 
  try Ok (Yojson.Safe.from_string content)
  with Yojson.Json_error msg -> Error ("invalid JSON: " ^ msg)

let load_json path = Result.bind (read_file path) parse_json

let ( let* ) = Result.bind

let field name = function
  | `Assoc l -> 
      (match List.assoc_opt name l with
        | Some v -> Ok v
        | None -> Error ("missing field '" ^ name ^ "'"))
  | _ -> Error "expected a JSON object" 

let as_string name = function
  | `String s -> Ok s
  | _ -> Error ("'" ^ name ^ "' must be a string")

let as_list name = function
  | `List s -> Ok s
  | _ -> Error ("'" ^ name ^ "' must be a list")

let as_char name = function
  | `String s when String.length s = 1 -> Ok s.[0]
  | _ -> Error ("'" ^ name ^ "' must be a string of length 1")

let rec all = function
    | [] -> Ok []
    | Error e :: _ -> Error e
    | Ok x :: rest -> Result.map (fun xs -> x :: xs) (all rest)

let get_string name json = 
  let* v = field name json in
  as_string name v

let get_char name json = 
  let* v = field name json in
  as_char name v

let get_string_list name json = 
  let* v = field name json in
  let* items = as_list name v in
  all (List.map (as_string name) items)

let get_char_list name json = 
  let* v = field name json in
  let* items = as_list name v in
  all (List.map (as_char name) items)

let parse_direction = function
  | `String "LEFT" -> Ok Left
  | `String "RIGHT" -> Ok Right
  | _ -> Error "'action' must be \"LEFT\" or \"RIGHT\""

let parse_transition json = 
  let* read = get_char "read" json in
  let* to_state = get_string "to_state" json in
  let* write = get_char "write" json in
  let* a = field "action" json in
  let* action = parse_direction a in
  Ok { read; to_state; write; action}

let parse_state_transitions (state, json) = 
  let* items = as_list state json in
  let* transitions = all (List.map parse_transition items) in
  Ok (state, transitions)

let parse_transitions json =
  let* v = field "transitions" json in
  match v with
  | `Assoc states -> all (List.map parse_state_transitions states)
  | _ -> Error "'transitions' must be an object"

let parse_machine json = 
  let* name = get_string "name" json in
  let* alphabet = get_char_list "alphabet" json in
  let* blank = get_char "blank" json in
  let* states = get_string_list "states" json in
  let* initial = get_string "initial" json in
  let* finals = get_string_list "finals" json in
  let* transitions = parse_transitions json in
  Ok { name; alphabet; blank; states; initial; finals; transitions }