(*  ML ASSESSED EXERCISES.    TICK 2 SUBMISSION FROM M.A. KLEPPMANN.   *)
(*  Estimated time to complete: 10 mins. Actual time: 25 mins.         *)

(* PROBLEM 1.  A recursive factorial function  facr(n) *)

fun facr(n) = if n=0 then 1 else n*facr(n-1);


(* PROBLEM 2.  An interative factorial function  faci(n) *)

fun faci(n) =
    let
        fun f(i,a) = if i=0 then a else f(i-1, i*a)
    in
        f(n,1)
    end;
