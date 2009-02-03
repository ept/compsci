(* ML ASSESSED EXERCISES.  TICK 6 SUBMISSION FROM M.A. KLEPPMANN *)
(* Estimated time: 30 mins; actual time: 30 mins. *)

(* Declarations made in the question sheet *)

datatype stream = Item of int * (unit -> stream);
fun cons(x,xs) = Item(x,xs);
fun head(Item(i,_)) = i;
fun tail(Item(_,xf)) = xf();
fun makeints n = cons(n, fn() => makeints(n+1));
fun maps f xs = cons( f(head xs), fn() => maps f (tail xs));

(* Question 3: A function nth(stream, int n) that returns the
   n'th element of the stream. *)

fun nth(Item(i,_), 1) = i
  | nth(Item(_,x), n) = nth(x(), n-1);

val squares = maps (fn n => n*n) (makeints 1);

(* Question 4: A function `filters' that returns a stream
   containing all stream elements for which the given function
   is true. *)

fun filters f (Item(i,x)) = if (f i) then
  Item(i, fn() => filters f (x())) else filters f (x());

val not_div_by_2_or_3 = filters 
  (fn i => ((i mod 2) > 0) andalso ((i mod 3) > 0))
  (makeints 1);
