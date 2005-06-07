(* ML ASSESSED EXERCISES.  TICK 5 SUBMISSION FROM M.A. KLEPPMANN *)
(* Estimated time: 1h. Actual time: 40 mins. *)

(* Part 1: A function f(m) that returns another function which adds
   m onto a given parameter. *)

fun plus(m:int) = (fn n => m+n);

(* This is equivalent to writing: *)

fun plus m n: int = m+n;

val succ = plus 1;

(* succ is now a function that returns the successor to its argument
   passed, i.e. the argument plus 1. *)

fun add(m,n): int = m+n;

(* Add differs from plus in that it is not curried. It takes only one
   argument, which must be a pair of two ints. It is not possible to
   make it return another function / to call it with only one parameter. *)

(* Part 3: The nfold function as defined in the question sheet. *)

fun nfold f x 0 = x | nfold f x n = f(nfold f x (n-1));

(* Now Part 2:
   Computing sums, products and powers in a vastly inefficient way. *)

fun sum(a,b) = nfold (fn n => n+1) a b;

fun product(a,b) = nfold (fn n => n+a) 0 b;
(* or, to be a bit crazier: *)
fun product_slow(a,b) = nfold (fn n => sum(n,a)) 0 b;

fun power(a,b) = nfold (fn n => n*a) 1 b;
(* or, to complete the craziness: *)
fun power_slow(a,b) = nfold (fn n => product_slow(n,a)) 1 b;
