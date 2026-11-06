type direction = Left | Right

type transition = {
  read      : char;
  to_state  : string;
  write     : char;
  action    : direction;
}

type machine = {
  name        : string;
  alphabet    : char list;
  blank       : char;
  states      : string list;
  initial     : string;
  finals      : string list;
  transitions : (string * transition list) list;
}

type tape = {
  left  : char list;
  head  : char;
  right : char list;
}

type outcome = 
  | Halted of { steps : int; tape : tape }
  | Blocked of { steps : int; state : string; read : char }