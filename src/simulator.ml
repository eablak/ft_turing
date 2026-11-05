open Types

let width = 80
let min_tape_len = 20

let string_of_direction = function
  | Left -> "LEFT"
  | Right -> "RIGHT"

let format_char_list lst =
  "[ " ^ String.concat ", " (List.map (String.make 1) lst) ^ " ]"

let format_string_list lst =
  "[ " ^ String.concat ", " lst ^ " ]"

let center_text text total_width =
  let len = String.length text in
  if len >= total_width then text
  else
    let pad_left = (total_width - len) / 2 in
    let pad_right = total_width - len - pad_left in
    String.make pad_left ' ' ^ text ^ String.make pad_right ' '

let print_header m =
  let border = String.make width '*' in
  let empty_line = "*" ^ String.make (width - 2) ' ' ^ "*" in
  let title_line = "* " ^ center_text m.name (width - 4) ^ " *" in
  print_endline border;
  print_endline empty_line;
  print_endline title_line;
  print_endline empty_line;
  print_endline border;
  Printf.printf "Alphabet: %s\n" (format_char_list m.alphabet);
  Printf.printf "States  : %s\n" (format_string_list m.states);
  Printf.printf "Initial : %s\n" m.initial;
  Printf.printf "Finals  : %s\n" (format_string_list m.finals);
  List.iter (fun (state, transitions) ->
    List.iter (fun t ->
      Printf.printf "(%s, %c) -> (%s, %c, %s)\n"
        state t.read t.to_state t.write (string_of_direction t.action)
    ) transitions
  ) m.transitions;
  print_endline border

let make_tape blank input =
  let chars = List.of_seq (String.to_seq input) in
  let len = List.length chars in
  let padded =
    if len < min_tape_len then
      chars @ List.init (min_tape_len - len) (fun _ -> blank)
    else
      chars
  in
  match padded with
  | [] -> { left = []; head = blank; right = [] }
  | h :: t -> { left = []; head = h; right = t }

let move_tape blank tape action write_char =
  match action with
  | Right ->
      (match tape.right with
       | [] -> 
          { left = write_char :: tape.left; head = blank; right = [] }
       | r_head :: r_tail -> 
          { left = write_char :: tape.left; head = r_head; right = r_tail })
  | Left ->
      (match tape.left with
       | [] -> 
          { left = []; head = blank; right = write_char :: tape.right }
       | l_head :: l_tail -> 
          { left = l_tail; head = l_head; right = write_char :: tape.right })

let string_of_chars chars =
  String.of_seq (List.to_seq chars)

let print_step tape current_state t =
  let left_str = string_of_chars (List.rev tape.left) in
  let right_str = string_of_chars tape.right in
  Printf.printf "[%s<%c>%s] (%s, %c) -> (%s, %c, %s)\n"
    left_str
    tape.head
    right_str
    current_state
    t.read
    t.to_state
    t.write
    (string_of_direction t.action)

let find_transition m state read_char =
  match List.assoc_opt state m.transitions with
  | None -> None
  | Some ts -> List.find_opt (fun t -> t.read = read_char) ts

let run m input =
  print_header m;
  let initial_tape = make_tape m.blank input in
  let rec loop state tape =
    if List.mem state m.finals then
      ()
    else
      match find_transition m state tape.head with
      | None ->
          Printf.eprintf "Error: Machine blocked! No transition found for state '%s' and character '%c'.\n"
            state tape.head;
          exit 1
      | Some t ->
          print_step tape state t;
          let next_tape = move_tape m.blank tape t.action t.write in
          loop t.to_state next_tape
  in
  loop m.initial initial_tape

