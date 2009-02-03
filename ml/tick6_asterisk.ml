(* ML ASSESSED EXERCISES.  TICK 6* SUBMISSION FROM M.A. KLEPPMANN *)

(* Declarations made in the question sheet *)
datatype stream = Item of int * (unit -> stream);
fun cons(x,xs) = Item(x,xs);
fun head(Item(i,_)) = i;
fun tail(Item(_,xf)) = xf();
fun makeints n = cons(n, fn() => makeints(n+1));
fun maps f xs = cons( f(head xs), fn() => maps f (tail xs));

(* Tick 6* *)

(* nth(stream, n) returns the n'th element of the stream. *)

fun nth(Item(i,_), 1) = i
  | nth(Item(_,x), n) = nth(x(), n-1);

(* Get: return n items from the stream as an ML list. *)

fun get n (Item(x,xf)) = if n=0 then [x] else x::(get (n-1) (xf()));

(* map2: map a (int*int->int) function onto two int streams *)

fun map2 f (Item(x,xs)) (Item(y,ys)) =
  Item(f(x,y), (fn() => map2 f (xs()) (ys())));

(* fibonacci numbers as given in the question sheet *)

fun fibs() =
  cons(1, fn() =>
    cons(1, fn() => map2 op+ (fibs()) (tail(fibs())) ));

(* merge two ascending streams into one, removing duplicates *)

fun merge (Item(x,xs), Item(y,ys)) =
  if x < y then Item(x, fn() => merge(xs(), Item(y,ys))) else
  if x > y then Item(y, fn() => merge(Item(x,xs), ys())) else
                Item(x, fn() => merge(xs(), ys()));


(* a stream containing all numbers of the form 2^i*3^j *)

fun times2 x = x*2;
fun times3 x = x*3;
fun times5 x = x*5;

fun powers23() = Item(1, fn() =>
  merge(maps times2 (powers23()),
        maps times3 (powers23())));

(* a stream containing all numbers of the form 2^i*3^j*5^k *)

fun powers235() = Item(1, fn() =>
  merge(
  merge(maps times2 (powers235()),
        maps times3 (powers235())),
        maps times5 (powers235())));

