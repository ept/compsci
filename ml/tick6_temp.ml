(* ML ASSESSED EXERCISES.  TICK 6 SUBMISSION FROM M.A. KLEPPMANN *)
(* put some time estimate here *)

(* Declarations made in the question sheet *)

datatype stream = Item of int * (unit -> stream);
fun cons(x,xs) = Item(x,xs);
fun head(Item(i,_)) = i;
fun tail(Item(_,xf)) = xf();
fun makeints n = cons(n, fn() => makeints(n+1));
fun maps f xs = cons( f(head xs), fn() => maps f (tail xs));

fun nth(Item(i,_), 1) = i
  | nth(Item(_,x), n) = nth(x(), n-1);

val squares = maps (fn n => n*n) (makeints 1);
nth(squares, 49);

fun filters f (Item(i,x)) = if (f i) then
  Item(i, fn() => filters f (x())) else filters f (x());

val not_div_by_2_or_3 = filters 
  (fn i => ((i mod 2) > 0) andalso ((i mod 3) > 0))
  (makeints 1);

(* Tick 6* *)

fun map2 f (Item(x,xs)) (Item(y,ys)) =
  Item(f(x,y), (fn() => map2 f (xs()) (ys())));

fun fibs() =
  cons(1, fn() =>
    cons(1, fn() => map2 op+ (fibs()) (tail(fibs())) ));

nth(fibs(), 49);

fun merge (Item(x,xs), Item(y,ys)) =
  if x < y then Item(x, fn() => merge(xs(), Item(y,ys))) else
  if x > y then Item(y, fn() => merge(Item(x,xs), ys())) else
                Item(x, fn() => merge(xs(), ys()));

fun timestwo n () = Item(2*n, timestwo (2*n));
val two_to_the_i = Item(1, timestwo 1);

load "Int";

fun get n (Item(x,xf)) = if n=0 then [x] else x::(get (n-1) (xf()));
fun printll 0 _ = ""
  | printll n (Item(x,xf)) = Int.toString(x) ^ (printll (n-1) (xf()));

fun vindaloo pow_3 (Item(next,nextf)) () =
  let val nextpow2 = Item(next,    vindaloo  pow_3 (nextf()))
      val nextpow3 = Item(pow_3*3, vindaloo (pow_3*3)
                     (maps (fn n=>n*pow_3*3) (timestwo 1 ())))
  in (
print("vindaloo " ^ (Int.toString pow_3) ^ " Item(" ^ (Int.toString(next)) ^ ", fn () => " ^ (Int.toString(head(nextf()))) ^ ")\n");
print "nextpow2 = [" ^ (printll 10 nextpow2) ^ "]\n";
print "nextpow3 = [" ^ (printll 10 nextpow3) ^ "]\n";
(* ******************************* if 3*pow_3 < next then ( print "woof"; merge(nextpow3, nextpow2) ) else nextpow2 ) *)
merge(nextpow3, nextpow2) )
  end;

val mystream = vindaloo 1 two_to_the_i ();

val pow3 = maps (fn n=>n*pow_3*3) two_to_the_i

(*      val nextpow3 = maps (fn n=>n*pow_3*3)
                     (Item(1, vindaloo (pow_3*3) (timestwo 1 ())) *)
