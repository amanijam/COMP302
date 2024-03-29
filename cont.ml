(* Continuations 
   Course: COMP 302: Programming Languages and Paradigms
   Author: Brigitte Pientka, Jacob Thomas Errington
*) 

(* Direct-style append 
   append: 'a list * 'a list -> 'a list 
*)
let rec append l1 l2 = match l1 with
  | [] -> l2
  | h::t -> h :: append t l2

(* By the way, notice that l2 is only _used_ at the very end.
   We can rewrite append to use partial evalution. *)
let rec append_gen = function
  | [] -> fun l2 -> l2
  | h :: t ->
     let f = append_gen t in
     fun l2 -> h :: f l2

(* --------------------------------------------------------------------------*)
(* Tail-recursion optimization - eliminate the runtime stack                 *)
(* Common optimization for many (functional) languages                       *)
(* Key to make them efficient - otherwise writing recursive programs
   may quickly fill up the stack                                             *)
(* --------------------------------------------------------------------------*)
(* Continuation-style append with the use
   of the continuation-style function 
   app_tr: 'a list -> 'a list -> ('a list -> 'a list) -> 'a list *)
let rec app_tr l1 l2 = 
  (* Since l2 is only used at the very end, we don't pass it through
     to app'. *)
  let rec app' l k = match l with 
    | []   -> k l2
    | h :: t -> app' t (fun r -> k (h :: r))
  in
    app' l1 (fun r -> r)

(* Exercise: can you rewrite app_tr to use partial evaluation? *)
let rec app_tr_gen : 'a list -> ('a list -> 'r) -> 'a list -> 'r =
  assert false

(* --------------------------------------------------------------------------*)
(*
     app_tr [1;2] [3;4]                       (fun r -> r)
==>  app_tr [2]   [3;4]            (fun r1 -> (fun r -> r) (1::r1))
==>  app_tr []    [3;4] (fun r2 -> (fun r1 -> (fun r -> r) (1::r1)) (2::r2))

==>  (fun r2 -> (fun r1 -> (fun r -> r) (1::r1)) (2::r2))  [3;4]
==>             (fun r1 -> (fun r -> r) (1::r1)) [2;3;4]
==>                        (fun r -> r) (1::[2;3;4])

*)

(* Constructs a list of numbers. *)
let rec genList n acc = if n > 0 then genList (n-1) (n::acc) else acc;; 

(* Experiment: *)

let l1 = genList 800000 [];;
let l2 = genList 400000 [];;

(* 
# append l1 l2;;
Stack overflow during evaluation (looping recursion?).

app_tr l1 l2;;
- : int list =
[1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21;
 22; 23; 24; 25; 26; 27; 28; 29; 30; 31; 32; 33; 34; 35; 36; 37; 38; 39; 40;
 41; 42; 43; 44; 45; 46; 47; 48; 49; 50; 51; 52; 53; 54; 55; 56; 57; 58; 59;
 60; 61; 62; 63; 64; 65; 66; 67; 68; 69; 70; 71; 72; 73; 74; 75; 76; 77; 78;
 79; 80; 81; 82; 83; 84; 85; 86; 87; 88; 89; 90; 91; 92; 93; 94; 95; 96; 97;
 98; 99; 100; 101; 102; 103; 104; 105; 106; 107; 108; 109; 110; 111; 112;
 113; 114; 115; 116; 117; 118; 119; 120; 121; 122; 123; 124; 125; 126; 127;
 128; 129; 130; 131; 132; 133; 134; 135; 136; 137; 138; 139; 140; 141; 142;
 143; 144; 145; 146; 147; 148; 149; 150; 151; 152; 153; 154; 155; 156; 157;
 158; 159; 160; 161; 162; 163; 164; 165; 166; 167; 168; 169; 170; 171; 172;
 173; 174; 175; 176; 177; 178; 179; 180; 181; 182; 183; 184; 185; 186; 187;
 188; 189; 190; 191; 192; 193; 194; 195; 196; 197; 198; 199; 200; 201; 202;
 203; 204; 205; 206; 207; 208; 209; 210; 211; 212; 213; 214; 215; 216; 217;
 218; 219; 220; 221; 222; 223; 224; 225; 226; 227; 228; 229; 230; 231; 232;
 233; 234; 235; 236; 237; 238; 239; 240; 241; 242; 243; 244; 245; 246; 247;
 248; 249; 250; 251; 252; 253; 254; 255; 256; 257; 258; 259; 260; 261; 262;
 263; 264; 265; 266; 267; 268; 269; 270; 271; 272; 273; 274; 275; 276; 277;
 278; 279; 280; 281; 282; 283; 284; 285; 286; 287; 288; 289; 290; 291; 292;
 293; 294; 295; 296; 297; 298; 299; ...]


The key tradeoff that Xavier Leroy (creator of OCaml) points to is the
choice between running fast on small-to-medium lists (OCaml's list
libraries are optimized for this scenario), and running at all on long
lists (typically the OCaml list library fails; this prompted Jane
Street Capital to implement a Core library where *all* list operation
functions are implemented tail-recursively.
*)


(* --------------------------------------------------------------------------*)

(* Any function can be turned into a tail-recursive one

   Question: Jane Street Capital Interview
 *)

let rec map_tr f l cont = match l with
  | [] -> cont []
  | h::t -> map_tr f t (fun l -> cont ((f h)::l))

(* --------------------------------------------------------------------------*)
(* Traversing a tree and finding an element *)

type 'a tree = 
  | Empty 
  | Node of 'a tree * 'a * 'a tree

(* --------------------------------------------------------------------------*)
(* Contrasting three different version *)
(* --------------------------------------------------------------------------*)
(* VERSION 1: Using option types *)
let rec find p t = match t with 
  | Empty -> None
  | Node (l, d, r) -> 
   if  (p d) then Some d
   else (match find p l with
     | None -> find p r
     | Some d' -> Some d')

(* --------------------------------------------------------------------------*)
(* VERSION 2: Exceptions *)
exception Fail

let rec find_exc p t = match t with 
  | Empty -> raise Fail
  | Node (l,d,r) -> 
    if (p d) then Some d
    else (try find_exc p l with Fail -> find_exc p r)

let find_ex p t =  (try find_exc p t with Fail -> None)

(* --------------------------------------------------------------------------*)
(* VERSION 3: Success & failure continuation *)

let rec find_tr p t fail succeed = match t with 
  | Empty -> fail ()
  | Node(_, d, _) when p d -> succeed d
  | Node(l, _, r) ->
     find_tr p l (fun () -> find_tr p r fail succeed) succeed

(** A driver function that calls the continuation-passing style
    function and wraps the result in an option, so we could use
    pattern matching after.
 *)
let find' p t = find_tr p t (fun () -> None) (fun x -> Some x)

(* Notice: the success continuation is only used at the end!
   Can you rewrite this to use partial evaluation?
   Since p and t are specified, it should be possible for this search
   to _fail_ even without being given the success continuation!
   The weird thing about these types is that the failure continuation
   needs to accept two arguments so that its return type is compatible
   with the _overall_ return type of the function (that is, the return
   type that includes the 'waiting' for the success continuation).

   This is challenging.
 *)
let rec find_tr_gen (p : 'a -> bool) (t : 'a tree) (fail : unit -> ('a -> 'r) -> 'r) : ('a -> 'r) -> 'r =
  assert false

(* --------------------------------------------------------------------------*)

   let leaf n = Node (Empty, n, Empty)
   let lt1 = Node (leaf 3, 5, leaf 7)
   let lt2 = Node (leaf 22, 33, leaf 44)
   let tt = Node(lt1, 9, lt2) 
  
   let tt0 = Node (tt, 17, lt2)
(*
   let p = (fun x -> x = 15)

     find_tr p t (fun () -> None) 
---> find_tr p l1 (fun () -> find_tr p (Node(Empty, 15, Empty))  (fun () -> None) )
                         ------ work we still may need to do on the right ---
                         ------ let's call it CONT ------

---> find_tr p (Node (Empty,3,Empty)) (fun () -> find_tr p (Node(E, 7, E) CONT ))

--> find_tr p (Empty) (fun () -> find_tr p (Empty) (fun () -> find_tr p (Node(E, 7, E)) CONT ))

--> (fun () -> find_tr p (Empty) (fun () -> find_tr p (Node(E, 7, E)) CONT )) ()     
     *** pop the stack ! ***

... 

---> find_tr p (Node(E, 7, E)) (fun () -> find_tr p (Node(Empty, 15, Empty)) (fun () -> None))

---> find_tr p E (fun () -> find_tr p Empty (fun () -> find_tr p (Node(Empty, 15, Empty)) (fun () -> None)))

    (***** pop the last element of the stack! ***)

---> (fun () -> find_tr p Empty (fun () -> find_tr p (Node(Empty, 15, Empty)) (fun () -> None)))) ()

---> find_tr p Empty (fun () -> find_tr p (Node(Empty, 15, Empty)) (fun () -> None))

---> (fun () -> find_tr p (Node(Empty, 15, Empty)) (fun () -> None)) ()

---> find_tr p (Node(Empty, 15, Empty) (fun () -> None)

---> Some(15)

*)

(* --------------------------------------------------------------------------*)
(* Finding all elements satisfying a given property *)
(* --------------------------------------------------------------------------*)
(* VERSION 1: Straightforward recursive program                              *)
let rec findAll p t = match t with 
  | Empty -> []
  | Node(l,d,r) -> 
    if (p d) then (findAll p l) @(d ::(findAll p r))
    else
      (findAll p l) @ (findAll p r)


(* --------------------------------------------------------------------------*)
(* VERSION 2: Tail-recursive version using success continuation              *)
let rec findAll' p t sc = match t with 
  | Empty -> sc []
  | Node(l,d,r) -> 
    findAll' p l 
      (fun el ->
        findAll' p r
          (fun er ->
            if (p d) then sc (el@(d::er)) else sc (el@er)))

let rec findAll0 p t sc = match t with 
  | Empty -> sc []
  | Node(l,d,r) -> 
     (if (p d) then
       findAll0 p l (fun el -> findAll0 p r 
					(fun er ->  sc (el@(d::er)))) 
     else 
       findAll0 p l (fun el -> findAll0 p r 
					(fun er ->  sc (el@er))) 

     )


let rec findAll1 p t sc = match t with 
  | Empty -> sc []
  | Node(l,d,r) -> 
     if (p d) then
       findAll1 p l (fun el -> el @ d :: findAll1 p r sc)
     else 
       findAll1 p l (fun el -> el @ findAll1 p r sc ) 

let r = findAll' (fun x -> x mod 3 = 0) tt (fun l -> l);;

let findEvery p t = 
  findAll' p t (fun el -> match el with [] -> None | _ -> Some el)


let l = Node (Node (Empty, 2, Empty), 5, Node (Empty, 6, Empty))
let r = Node (Empty, 12, Empty)
let t = Node (Node (l, 7, Node (Empty, 8, Empty)), 11, r)

let even x = (x mod 2) = 0 
let odd x = (x mod 2) = 1 

let k = findEvery even  t

let r = findEvery odd  t

(** BONUS **)

let elim_option (none : unit -> 'b) (some : 'a -> 'b) (o : 'a option) =
  match o with
  | None -> none ()
  | Some x -> some x


(* THEOREM:
   For any functions none : unit -> 'b and some : 'a -> 'b,
   For any predicate p : 'a -> bool,
   For any tree t : 'a tree,
   we have:
     elim_option none some (find p t) = find_tr p t none some

   Proof: by induction on t.
   (To get started, consider 2 cases:
    1. t = Empty
    2. t = Node(l, d, x) along with subcases for whether p d is true.)
   EXERCISE.

   (This is a generalization of the simpler theorem
   find p t = find_tr p t (fun () -> None) (fun x -> Some x)
   which I believe can't be proven directly.
   Prove this more straightforward theorem as a consequence of the
   generalized theorem given above.)
 *)
