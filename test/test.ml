exception Parse_error

open Libdash
        
let rec parse_all () : Ast.t list =
  let stackmark = Dash.init_stack () in
  match Dash.parse_next ~interactive:false () with
  | Dash.Done -> Dash.pop_stack stackmark; []
  | Dash.Error -> Dash.pop_stack stackmark; raise Parse_error
  | Dash.Null -> Dash.pop_stack stackmark; parse_all ()
  | Dash.Parsed n -> 
     (* translate to our AST *)
     let c = Ast.of_node n in
     (* deallocate *)
     Dash.pop_stack stackmark;
     (* keep calm and carry on *)
     c::parse_all ()

let read_file filename = 
  let lines = ref [] in
  let chan = open_in filename in
  try
    let rec go () =
      lines := input_line chan :: !lines;
      go ()
    in
    go ()
  with End_of_file ->
    close_in chan;
    String.concat "\n" (List.rev !lines)
     
let round_trip f =
  let contents = read_file f in
  let contents_ss = Dash.alloc_stack_string contents in
  Dash.setinputstring contents_ss;
  let cs = parse_all () in
  let rendering = String.concat "\n" (List.map Ast.to_string cs) in
  let rendering_ss = Dash.alloc_stack_string rendering in
  Dash.setinputstring rendering_ss;
  let cs' = parse_all () in
  let rendering' = String.concat "\n" (List.map Ast.to_string cs') in
  rendering = rendering'
     
let main () = 
  Dash.initialize ();
  let files = Array.to_list (Sys.readdir "tests") in
  List.iter
    (fun name ->
      let testfile = "tests/" ^ name in
      Printf.printf "%s: %s\n%!" testfile
        (try if round_trip testfile
             then "OK"
             else "FAILED"
         with Parse_error -> "parse error"))
    files
;;

main ()
