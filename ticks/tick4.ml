(* ML ASSESSED EXERCISES.  TICK 4 SUBMISSION FROM M.A. KLEPPMANN *)
(* Estimated time: 3h. Actual time: 1h 30m.
   -- not including extra work for Tick 4*  *)

(* startpoints(pairs, z) returns a list of all nodes that have elements of
   'pairs' leading to the node 'z'. *)

fun startpoints(pairs, z) =
   let fun
      sp([],       _, acc) = acc
    | sp((x,y)::l, z, acc) = if y=z then sp(l, z, x::acc) else sp(l, z, acc)
   in
      sp(pairs, z, [])
   end;


(* endpoints(z, pairs) returns a list of all nodes that can be reached
   from the node 'z' via an element of 'pairs'. *)

fun endpoints(z, pairs) =
   let fun
      sp([],       _, acc) = acc
    | sp((x,y)::l, z, acc) = if x=z then sp(l, z, y::acc) else sp(l, z, acc)
   in
      sp(pairs, z, [])
   end;


(* allpairs(list1, list2) returns a list of pairs, in which each element
   of 'list1' is paired with each element of 'list2'. *)

fun allpairs([],    ys) = []
  | allpairs(x::xs, ys) =
    let fun
         pair(a,    []) = []
       | pair(a, b::bs) = (a,b)::pair(a, bs)
    in
         pair(x, ys) @ allpairs(xs, ys)
    end;


(* (exists f list) is a curried function that returns true if the conditional
   function 'f' is true for at least one of the elements of 'list'.
   (taken from Foundations of Computer Science lecture notes) *)

fun exists p []      = false
  | exists p (x::xs) = (p x) orelse exists p xs;


(* merge(list1, list2) merges the two lists so that each element of each list
   exists exactly once in the final list. The elements of the lists must be
   pairs. *)

fun merge([],          list) = list
  | merge((n1,n2)::ns, list) =
        if exists (fn (a,b) => ((a=n1) andalso (b=n2))) list then
           merge(ns,          list) else
           merge(ns, (n1,n2)::list);


(* addnew((x,y), poss) adds a new route (x,y) to a list of possible routes
   ('poss'). 'poss' is assumed to be complete. All nodes that previously had
   a route to node 'x' will afterwards also be connected to all nodes that could
   previously be reached from 'y'. *)

fun addnew((x,y), poss) =
    merge( allpairs( x::startpoints(poss, x),  y::endpoints(y, poss) ),
           poss );


(* routes(list) makes any set of routes (specified as a list of pairs)
   complete. (definition of complete: see question sheet) *)

fun routes []             = []
  | routes ((x,y)::pairs) = addnew((x,y), routes(pairs));
