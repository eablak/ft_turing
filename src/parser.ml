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