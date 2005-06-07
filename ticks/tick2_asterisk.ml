(*  ML ASSESSED EXERCISES.    TICK 2 SUBMISSION FROM M.A. KLEPPMANN.   *)
(*  Estimated time to complete: 15 mins. Actual time: 20 mins.         *)

(* EXTRA STUFF FOR EXERCICE 2(asterisk) *)

(* PROBLEM 1.  Two functions to calculate the sum to n terms of
   1 + 1/2 + 1/4 + ... + 1/2^(n-1)                                 *)

(* recursive: *)
fun sumt_rec(n) =
    let
        fun f(i,a) = if i=1 then a else a + f(i-1, a/2.0)
    in
        f(n,1.0)
    end;

(* interative, including general factor x: *)
fun sumt_it(x,n) =
    let
        fun f(fac,i,a,s) = if i=0 then s else f(fac, i-1, a/2.0, s+fac*a)
    in
        f(x, n, 1.0, 0.0)
    end;


(* PROBLEM 2.  Approximation of e to n terms (iterative function). *)

fun eapprox(n) =
    let
        fun f(i,a,s) = 
            if i=0 then s
            else f(i-1, a*(n-i+1), s + 1.0/real(a))
    in
        f(n-1, 1, 1.0)
    end;


(* PROBLEM 3.  Exponential function e^z, approximated to n terms. *)

fun exp(z,n) =
    let
        fun f(i,a,b,s) =
            if i=0 then s
            else f(i-1, a*(n-i+1), b*z, s + b/real(a))
    in
        f(n-1, 1, z, 1.0)
    end;
