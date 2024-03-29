(* Reminder: If a test case requires multiple arguments, use a tuple:
let myfn_with_2_args_tests = [
  ((arg1, arg1), (expected_output))
]
*)

(* Q1 *)
(* TODO: Write a good set of tests for compress *)
let compress_tests = [
  (([]), ([]));
  (([A]), ([(1, A)]));
  (([A;A]), ([(2, A)]));
  (([A;T]), ([(1, A); (1, T)]));
  (([A;A;G;T;T;C]), ([(2, A); (1, G); (2, T); (1, C)]));
  (([A;A;A;A;G;G;A;T;T;T;C;C]), ([(4, A); (2, G); (1, A); (3, T); (2, C)]));
]

(* TODO: Implement compress. *)
let compress (l : nucleobase list) : (int * nucleobase) list =
  let rec compress' l (r: (int*nucleobase) list) acc=
    match l with
    | [] -> []
    | [h] -> r @ [(acc, h)]
    | (h1::h2::t) ->
        if (h1 = h2) then compress' (h2::t) r (acc+1)
        else compress' (h2::t) (r @ [(acc,h1)]) 1
  in
  compress' l [] 1

(* TODO: Write a good set of tests for decompress *)
let decompress_tests = [
  (([]), ([]));
  (([1, A]), ([A]));
  (([2,C]), ([C;C])); 
  (([5,T]), ([T;T;T;T;T]));
  (([(1,A); (1,T)]), ([A;T]));
  (([(1, A); (1, T)]), ([A;T]));
  (([(1, A); (1, T)]), ([A;T])); 
  (([(2, G); (1, A)]), ([G;G;A]));
  (([(4, T); (2, G)]), ([T;T;T;T;G;G]));
  (([(3, A); (3, T); (1, G); (2, C)]), ([A;A;A;T;T;T;G;C;C]));
  (([(4, A); (2, G); (1, A); (3, T); (1, C); (1, T); (1, C)]),
   ([A;A;A;A;G;G;A;T;T;T;C;T;C]))
]

let rec makeSubList (r: nucleobase list) (a: int) (n: nucleobase)=
  if (a=0) then r
  else makeSubList (n::r) (a-1) n

(* TODO: Implement decompress. *)
let rec decompress (l : (int * nucleobase) list) : nucleobase list =
  match l with
  | [] -> []
  | (i, n)::t -> (makeSubList [] i n) @ (decompress t)
      


(* Q2 *)
(* TODO: Write a good set of tests for eval *) 
let eval_tests = [ 
  ((FLOAT 0.), (0.)); 
  ((FLOAT 342.768), (342.768));
  ((SIN (FLOAT 0.)), (0.));
  ((SIN (FLOAT 0.79)), (0.7103532724)); 
  ((COS (FLOAT 0.)), (1.));
  ((COS (FLOAT 1.25)), (0.3153223624)); 
  ((EXP (FLOAT 0.)), (1.));
  ((EXP (FLOAT 0.6)), (1.8221188)); 
  ((PLUS (FLOAT 3.4, FLOAT 0.)), (3.4));
  ((PLUS (FLOAT 0., FLOAT 5.6)), (5.6));
  ((PLUS (FLOAT 15.4, FLOAT 32.5)), (47.9));
  ((MINUS (FLOAT 3.4, FLOAT 0.)), (3.4));
  ((MINUS (FLOAT 0., FLOAT 5.6)), (-5.6));
  ((MINUS (FLOAT 15.4, FLOAT 32.5)), (-17.1));
  ((MULT (FLOAT 3.4, FLOAT 0.)), (0.));
  ((MULT (FLOAT 0., FLOAT 5.6)), (0.));
  ((MULT (FLOAT 15.4, FLOAT 32.5)), (500.5));
  ((DIV (FLOAT 0., FLOAT 3.4)), (0.));
  ((DIV (FLOAT 5., FLOAT 2.)), (2.5));
  ((DIV (FLOAT 15.4, FLOAT 32.5)), (0.4738461538));
  ((SIN(EXP(FLOAT 5.0))), (-0.6876914117));
  ((COS(MINUS(FLOAT 5.6, EXP(FLOAT 3.4)))), (0.7188559281));
  ((MULT (PLUS (FLOAT 2.2, FLOAT 3.3), FLOAT 5.0)), (27.5));
  ((DIV(FLOAT 34.5, (MINUS(FLOAT 15.4, (MULT (FLOAT 3.4, FLOAT 5.6)))))), 
   (-9.478021978))
] 

(* TODO: Implement eval. *)
let rec eval e = match e with 
  | FLOAT x -> x
  | SIN x -> sin(eval x)
  | COS x -> cos(eval x)
  | EXP x -> exp(eval x)
  | PLUS (x,y)-> ((eval x) +. (eval y))
  | MINUS (x,y) -> ((eval x) -. (eval y))
  | MULT (x,y) -> ((eval x) *. (eval y))
  | DIV (x,y) -> ((eval x) /. (eval y))
      

(* TODO: Write a good set of tests for to_instr *)
let to_instr_tests = [
  ((FLOAT 0.), ([Float 0.])); 
  ((FLOAT 342.768), ([Float 342.768]));
  ((SIN (FLOAT 0.)), ([Float 0.; Sin]));
  ((SIN (FLOAT 0.79)), ([Float 0.79; Sin])); 
  ((COS (FLOAT 0.)), ([Float 0.; Cos]));
  ((COS (FLOAT 1.25)), ([Float 1.25; Cos])); 
  ((EXP (FLOAT 0.)), ([Float 0.; Exp]));
  ((EXP (FLOAT 0.6)), ([Float 0.6; Exp])); 
  ((PLUS (FLOAT 3.4, FLOAT 0.)), ([Float 3.4; Float 0.; Plus]));
  ((PLUS (FLOAT 0., FLOAT 5.6)), ([Float 0.; Float 5.6; Plus]));
  ((PLUS (FLOAT 15.4, FLOAT 32.5)), ([Float 15.4; Float 32.5; Plus]));
  ((MINUS (FLOAT 3.4, FLOAT 0.)), ([Float 3.4; Float 0.; Minus]));
  ((MINUS (FLOAT 0., FLOAT 5.6)), ([Float 0.; Float 5.6; Minus]));
  ((MINUS (FLOAT 15.4, FLOAT 32.5)), ([Float 15.4; Float 32.5; Minus]));
  ((MULT (FLOAT 3.4, FLOAT 0.)), ([Float 3.4; Float 0.; Mult]));
  ((MULT (FLOAT 0., FLOAT 5.6)), ([Float 0.; Float 5.6; Mult]));
  ((MULT (FLOAT 15.4, FLOAT 32.5)), ([Float 15.4; Float 32.5; Mult]));
  ((DIV (FLOAT 0., FLOAT 3.4)), ([Float 0.; Float 3.4; Div]));
  ((DIV (FLOAT 5., FLOAT 2.)), ([Float 5.; Float 2.; Div]));
  ((DIV (FLOAT 15.4, FLOAT 32.5)), ([Float 15.4; Float 32.5; Div]));
  ((SIN(EXP(FLOAT 5.0))), ([Float 5.0; Exp; Sin]));
  ((COS(MINUS(FLOAT 5.6, EXP(FLOAT 3.4)))), 
   ([Float 5.6; Float 3.4; Exp; Minus; Cos]));
  ((MULT (PLUS (FLOAT 2.2, FLOAT 3.3), FLOAT 5.0)), 
   ([Float 2.2; Float 3.3; Plus; Float 5.0; Mult]));
  ((DIV(FLOAT 34.5, (MINUS(FLOAT 15.4, (MULT (FLOAT 3.4, FLOAT 5.6)))))), 
   ([Float 34.5; Float 15.4; Float 3.4; Float 5.6; Mult; Minus; Div]))
]

(* TODO: Implement to_instr. *)
let rec to_instr e = match e with
  | FLOAT x -> [Float x] 
  | SIN x -> (to_instr x) @ [Sin]
  | COS x -> (to_instr x) @ [Cos]
  | EXP x -> (to_instr x) @ [Exp]
  | PLUS (x,y) -> (to_instr x) @ (to_instr y) @ [Plus]
  | MINUS (x,y) -> (to_instr x) @ (to_instr y) @ [Minus]
  | MULT (x,y) -> (to_instr x) @ (to_instr y) @ [Mult]
  | DIV (x,y) -> (to_instr x) @ (to_instr y) @ [Div]


(* TODO: Write a good set of tests for instr *)
let instr_tests = [
  ((Float 4.2, []), (Some [4.2]));
  ((Float 4.2, [2.2; 3.3; 5.5]), (Some [4.2; 2.2; 3.3; 5.5]));
  ((Sin, []), (None));
  ((Sin, [1.1]), (Some [0.8912073601]));
  ((Sin, [1.1; 5.5; 6.6]), (Some [0.8912073601; 5.5; 6.6]));
  ((Cos, []), (None));
  ((Cos, [1.1]), (Some [0.4535961214]));
  ((Cos, [1.1; 5.5; 6.6; 98.]), (Some [0.4535961214; 5.5; 6.6; 98.]));
  ((Exp, []), (None));
  ((Exp, [4.2]), (Some [66.68633104]));
  ((Exp, [4.2; 5.5]), (Some [66.68633104; 5.5]));
  ((Plus, []), (None));
  ((Plus, [5.5]), (None));
  ((Plus, [5.5; 6.6; 4.2; 3.3]), (Some [12.1; 4.2; 3.3]));
  ((Minus, []), (None));
  ((Minus, [33.3]), (None));
  ((Minus, [33.3; 4.2; 4.2; 6.6]), (Some [-29.1; 4.2; 6.6]));
  ((Mult, []), (None));
  ((Mult, [5.0]), (None));
  ((Mult, [5.0; 5.5]), (Some [27.5]));
  ((Div, []), (None));
  ((Div, [5.]), (None));
  ((Div, [5.; 55.5; 5.]), (Some [11.1; 5.]));
]


(* TODO: Implement to_instr. *)               
let instr i s = match i with
  | Float x -> Some (x::s)
  | Sin -> (match s with
      | [] -> None
      | x::t -> Some (sin x::t) )
  | Cos -> (match s with
      | [] -> None
      | x::t -> Some (cos x::t) )
  | Exp -> (match s with
      | [] -> None
      | x::t -> Some (exp x::t) ) 
  | Plus -> (match s with
      | [] -> None
      | [x] -> None
      | x::y::t -> Some ((y+.x)::t) ) 
  | Minus -> (match s with
      | [] -> None
      | [x] -> None
      | x::y::t -> Some ((y-.x)::t) ) 
  | Mult -> (match s with
      | [] -> None
      | [x] -> None
      | x::y::t -> Some ((y*.x)::t) ) 
  | Div -> (match s with
      | [] -> None
      | [x] -> None
      | x::y::t -> Some ((y/.x)::t)) 
  

(* TODO: Write a good set of tests for prog *)
let prog_tests = [
  (([Float 2.2]), (Some 2.2)); 
  (([Sin]), (None));
  (([Float 1.1; Sin]), (Some 0.8912073601));
  (([Cos]), (None));
  (([Float 1.1; Cos]), (Some 0.4535961214));
  (([Exp]), (None));
  (([Float 4.2; Exp]), (Some 66.68633104));
  (([Plus]), (None));
  (([Float 2.2; Plus]), (None));
  (([Float 2.2; Float 3.3; Plus]), (Some 5.5));
  (([Minus]), (None));
  (([Float 2.2; Minus]), (None));
  (([Float 2.2; Float 3.3; Minus]), (Some (-1.1)));
  (([Mult]), (None));
  (([Float 2.2; Mult]), (None));
  (([Float 2.2; Float 3.3; Mult]), (Some 7.26));
  (([Div]), (None));
  (([Float 2.2; Div]), (None));
  (([Float 2.2; Float 4.4; Div]), (Some 0.5));
  (([Float 2.2; Float 3.3; Plus; Float 5.; Mult]), (Some 27.5));
  (([Float 2.2; Exp; Float 4.5; Plus; Sin; Float 5.5; Mult]), (Some 4.501268651))
]

let rec prog_helper (il: instruction list) (fs: stack) = match il with
  | [] -> (let x::[] = fs in x )
  | Sin::tl -> (let x::xs = fs in prog_helper (tl) ((sin x)::xs) )
  | Cos::tl -> (let x::xs = fs in prog_helper (tl) ((cos x)::xs) )
  | Exp::tl -> (let x::xs = fs in prog_helper (tl) ((exp x)::xs) )
  | Plus::tl -> (let x::y::xs = fs in prog_helper (tl) ((x+.y)::xs) )
  | Minus::tl -> (let x::y::xs = fs in prog_helper (tl) ((x-.y)::xs) )
  | Mult::tl -> (let x::y::xs = fs in prog_helper (tl) ((x*.y)::xs) )
  | Div::tl -> (let x::y::xs = fs in prog_helper (tl) ((x/.y)::xs) )

(* TODO: Implement prog. *) 
let prog instrs =
  let rec create_two_lists (list: instruction list) (il: instruction list) (fs: stack) =
    match list with
    | [] -> Some (prog_helper (il) (fs))
    | (Float x)::t -> create_two_lists (t) (il) (fs @ [x])
    | (Sin as x)::t | (Cos as x)::t | (Exp as x):: t 
      -> if fs = [] then None
        else create_two_lists (t) (il @ [x]) (fs)
    | (Plus as x)::t | (Minus as x)::t | (Mult as x)::t | (Div as x)::t
      ->  (match fs with
          | [] -> None
          | [y] -> None
          | y::z::a -> create_two_lists (t) (il @ [x]) (fs))
  in
  create_two_lists instrs [] []