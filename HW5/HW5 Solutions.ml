(* TODO: Write some tests for neighbours. Consider creating a graph first,
and then writing your tests based on it *)

(* Reminder: If a test case requires multiple arguments, use a tuple:
let myfn_with_2_args_tests = [
  ((arg1, arg1), (expected_output))
]
*)

(*test graph*)
let a = {nodes = ["a"; "b"; "c"; "d"; "e"];
         edges = [("a", "d", 50); ("a", "c", 40); ("d", "c", 60); ("b", "a" ,20)]} 
(* We've added a type annotation here so that the compiler can help
   you write tests of the correct form. *) 
let neighbours_tests: ((string graph * string) * (string * weight) list) list = [
  ((a, "c"), ([]));
  ((a, "e"), ([])); 
  ((a, "b"), ([("a", 20)]));
  ((a, "d"), ([("c", 60)])); 
  ((a, "a"), ([("d", 50); ("c", 40)]));
]

(* TODO: Implement neighbours. *)
let neighbours (g: 'a graph) (vertex: 'a) : ('a * weight) list =
  let m = g.edges in
  let rec neighbours' edges (acc: ('a*weight) list) =
    match edges with
    | [] -> acc
    | (v1, v2, w)::xs -> if v1 = vertex then neighbours' xs ((v2, w)::acc)
        else neighbours' xs acc
  in neighbours' m [] ;;

(* TODO: Implement find_path. *)
let find_path (g: 'a graph) (a: 'a) (b: 'a) : ('a list * weight) =
  let check (node: 'a) (visited: 'a list) = List.exists (fun s->s=node) visited
  in let m = g.edges in
  let rec find_inner edges a_inner (visited: 'a list) weight_acc =
    match edges with
    | [] -> raise Fail
    | (v1, v2, w)::xs -> 
        if v1 = a_inner then 
          if v2 = b then (visited@[v2], weight_acc+w)
          else if (check v2 visited) then find_inner xs a_inner visited weight_acc
          else
            try find_inner m v2 (visited@[v2]) (weight_acc+w) with
              Fail-> (find_inner xs a_inner visited weight_acc) 
        else find_inner xs a_inner visited weight_acc
  in find_inner m a [a] 0 ;;


(* TODO: Implement find_path'. *)
let find_path' (g: 'a graph) (a: 'a) (b: 'a) : ('a list * weight) =
  let check node visited = List.exists (fun s->s=node) visited
  in let m = g.edges in
  let rec find_inner' edges a_inner visited weight_acc fc sc = 
    match edges with
    | [] -> fc visited weight_acc
    | (v1, v2, w)::xs -> 
        if v1 = a_inner then
          if v2 = b then sc visited v2 weight_acc w
          else if (check v2 visited) then 
            find_inner' xs a_inner visited weight_acc fc sc
          else find_inner' m v2 (visited@[v2]) (weight_acc+w)
              (fun visited_list weigtht -> 
                 find_inner' xs a_inner visited weight_acc fc sc) sc
        else find_inner' xs a_inner visited weight_acc fc sc 
  in find_inner' m a [a] 0 
    (fun visited_list weight -> raise Fail) 
    (fun visited_list lastNode weight_acc 
      lastWeight -> (visited_list@[lastNode], weight_acc+lastWeight))
  
(* TODO: Implement find_all_paths *) 
let find_all_paths (g: 'a graph) (a: 'a) (b: 'a) : ('a list * weight) list =
  let check node visited = List.exists (fun s->s=node) visited in 
  let aux_node edge paths = 
    let (a, w) = edge in List.map (fun (list, v) -> (a::list), w+v) paths 
  in let m = g.edges in 
  let rec find_all' edges a_inner prev paths =
    match edges with
    | [] -> paths
    | (v1, v2, w)::xs -> 
        if v1 = a_inner then 
          if v2 = b then find_all' xs a_inner prev [([a_inner;b], w)]
          else if (check v2 prev) then find_all' xs a_inner prev paths
          else (aux_node (a_inner, w) (find_all' m v2 (prev@[v2]) []))@(find_all' xs a_inner (prev@[a_inner]) paths) 
        else find_all' xs a_inner prev paths
  in find_all' m a [a] [] ;;


(* TODO: Implement find_shortest_path *)
let find_shortest_path (g: 'a graph) (a: 'a) (b: 'a) : ('a list * weight) option = 
  let all = find_all_paths g a b in
  let sorted = List.sort (fun (a1, w1)->fun (a2, w2)-> compare w1 w2) all in
  match sorted with
  | [] -> None
  | x::_ -> Some x 