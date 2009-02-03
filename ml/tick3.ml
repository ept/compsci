(* ML ASSESSED EXERCISES.  TICK 3 SUBMISSION FROM M.A. KLEPPMANN *)
(* Estimated time to complete: 20 mins. Actual time: 25 mins.
   (not including extra work for Tick 3(asterisk))               *)

(* Note that in all three solutions, it is assumed that any list
   presented as an argument is of adequate length. Match exceptions
   are not caught.                                               *)

(* PROBLEM 1.  A function last(x) that returns the last element of the list x.
   last(...):    time O(n) and space O(1)  (tail-recursive)
   hd(rev(...)): complexity of rev() is significant, 
                 probably time O(n) and space O(n)   
                 (implementation-dependent)
 *)

fun last([x]) = x | last(y::z) = last(z);

(*
   PROBLEM 2.  A function butLast(x) that returns a list containing all
               elements of x but the last.
   butLast(...):      time O(n) and space O(n)
   rev(tl(rev(...))): probably time O(n) and space O(n)
                      (implementation-dependent)
 *)

fun butLast([x]) = [] | butLast(h::t) = h::butLast(t);


(* PROBLEM 3.  A function nth(x,n) that returns the n'th element of the list x.
               (The head is counted as n=0)                                  *)

fun nth(h::t, n) = if n=0 then h else nth(t, n-1);


(****************************************************************************)

(* EXTRA STUFF FOR TICK 3(asterisk) *)

(* Function choose(k,xs) returns a list containing all possible k-element
   lists that can be drawn from xs, ignoring the order of list elements.
   Definitely not the most efficient solution, but it works.
 *)

fun choose(k,x) =
    let
        fun ch(i, pre, s) =
            if (not(null(s))) andalso (i > 0) then
                ch(i-1, pre@[hd(s)], tl(s)) @ ch(i, pre, tl(s))
            else if i = 0 then [pre] else []
    in
        ch(k, [], x)
    end;
