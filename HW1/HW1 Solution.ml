(* Question 1 *)
(* TODO: Write your own tests for the fact function.
         See the provided tests for double, above, for how to write test cases.
         Remember that you should NOT test cases for n < 0.
*)
(* TODO: Correct these tests for the fact function. *)
let fact_tests = [
  (0, 1.);
  (1, 1.);
  (2, 2.);
  (5, 120.);
  (8, 40320.)
]

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*) 
let rec fact (n: int): float = match n with
  | 0 -> 1.0
  | _ -> float n *. fact (n - 1)


(* TODO: Write your own tests for the binomial function.
         See the provided tests for fact, above, for how to write test cases.
         Remember that we assume that  n >= k >= 0; you should not write test cases where this assumption is violated.
*)
let binomial_tests = [
  (* Your test cases go here. Correct the incorrect test cases for the function. *)
  ((0, 0), 1.);
  ((1, 0), 1.);
  ((2, 0), 1.);
  ((5, 2), 10.);
  ((5, 5), 1.);
  ((10,1), 10.);
  ((10,2), 45.);
  ((12, 4), 495.)
]

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*)
let binomial (n: int) (k:int) =
  if n < 0 then domain ()
  else (if k = n then 1.
        else fact n /. (fact k  *. fact (n-k)))


(* TODO: Write a good set of tests for ackerman. *)
let ackerman_tests = [
  (* Your test cases go here *)
  ((0, 0), 1);
  ((0, 1), 2);
  ((0, 8), 9);
  ((1, 0), 2);
  ((2, 0), 3);
  ((3, 0), 5);
  ((1, 1), 3);
  ((1, 3), 5);
  ((2, 1), 5)
]

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*)
let ackerman (n, k)  =
  if n < 0 || k < 0 then domain ()
  else (let rec ack n k = match (n,k) with
      | (0 , _ ) -> k + 1 
      | (_ , 0 ) -> ack (n-1) 1
      | (_ , _ ) -> ack (n-1) (ack n (k-1))
     in ack n k)


(* Question 2: is_prime *)

(* TODO: Write a good set of tests for is_prime. *)
let is_prime_tests = [
(* Your tests go here *)
  (2, true);
  (3, true);
  (4, false);
  (5, true);
  (9, false); 
  (14, false);
  (17, true)
  
]

(* TODO: Correct this implementation so that it compiles and returns
         the correct answers.
*)
let is_prime n = 
  if n < 2 then domain() 
  else (let rec check x =
          if x = 1 then true
          else if (n mod x = 0) then false
          else check (x-1) 
        in
        check (n-1))
           


(* Question 3: Newton-Raphson method for computing the square root
*)

let square_root_tests = [
  (0.0625, 0.25);
  (1., 1.);
  (4., 2.);
  (6.25, 2.5);
  (16., 4.);
  (67.24, 8.2)
]

let update a x = ((a/.x)+.x)/.2.
               
let square_root a = 
  let rec findroot x acc = 
    if (abs_float (x -. update a x) < acc) then update a x
    else findroot (update a x) epsilon_float 
  in
  if a > 0.0 then
    findroot 1.0 epsilon_float
  else domain ()

 
(* Question 4: Fibonacci*)

(* TODO: Write a good set of tests for fib_tl. *)
let fib_tl_tests = [
  (0, 1);
  (1, 1);
  (2, 2);
  (5, 8);
  (10, 89);
  (21, 17711)
]

(* TODO: Implement a tail-recursive helper fib_aux. *)
let rec fib_aux n a b =
  if n = 1 then b
  else fib_aux (n-1) b (a+b) 
    

(* TODO: Implement fib_tl using fib_aux. *)
let fib_tl n =
  if n < 0 then domain()
  else if n = 0 then 1 
  else fib_aux n 1 1
 