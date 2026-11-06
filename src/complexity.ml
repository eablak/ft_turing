open Types

let ( let* ) = Result.bind

let expand template n = 
  let rec go = function
    | c :: '^' :: 'n' :: rest -> String.make n c :: go rest
    | c :: rest -> String.make 1 c :: go rest
    | [] -> []
  in
  String.concat "" (go (List.of_seq (String.to_seq template)))

let measure_one m template n = 
  let input = expand template n in
  let* _ = Parser.validate_input m input in
  match Simulator.run ~verbose:false m input with
  | Halted { steps; _ } -> Ok (n, steps)
  | Blocked { steps; state; read } ->
    Error (Printf.sprintf "n=%d: blocked at '%s' reading '%c' after %d steps" n state read steps)

let slope (n1, t1) (n2, t2) = 
  log (float_of_int t2 /. float_of_int t1) /. log (float_of_int n2 /. float_of_int n1)

let classify k =
  if k < 0.3 then "O(1)"
  else if k < 1.3 then "O(n)"
  else if k < 2.4 then "O(n^2)"
  else if k < 3.4 then "O(n^3)"
  else "O(n^4) or worse / exponential"

let sizes = [1; 2; 4; 8; 16; 32; 64]

let rec all = function
  | [] -> Ok []
  | Error e :: _ -> Error e
  | Ok x :: rest -> Result.map (fun xs -> x :: xs) (all rest)

let report m template = 
  let* points = all (List.map (measure_one m template) sizes) in
  Printf.printf "%6s %10s %8s\n" "n" "steps" "slope";
  let slopes = 
    List.mapi (fun i p ->
      if i = 0 then (Printf.printf "%6d %10d %8s\n" (fst p) (snd p) "-"; None)
      else
        let k = slope(List.nth points (i-1)) p in
        Printf.printf "%6d %10d %8.2f\n" (fst p) (snd p) k;
        Some k) points
      |> List.filter_map Fun.id in
  let last2 = List.rev slopes |> List.filteri (fun i _ -> i < 2) in
  let k = List.fold_left (+.) 0. last2 /. float_of_int (List.length last2) in
  Printf.printf "Estimated complexity: %s (slope %.2f)\n" (classify k) k;
  Ok ()