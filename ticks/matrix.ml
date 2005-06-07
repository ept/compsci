(* use moscow ml *)
(* not sure if transpose is correct *)

fun idmatrix n =
  Array.tabulate(n, (fn i =>
    Array.tabulate(n, (fn j => if i=j then 1.0 else 0.0))));

fun transpose m =
  Array.tabulate(Array.length(Array.sub(m,0)), (fn i =>
    Array.tabulate(Array.length(m), (fn j => Array.sub(Array.sub(m,j),i)))));

fun mtolist m = let
    fun mtolx(_,~1) = [] | mtolx(a,n) = (Array.sub(a,n))::mtolx(a,n-1);
    fun mtoly(_,~1) = [] 
      | mtoly(a,n) = (mtolx(Array.sub(a,n), Array.length(Array.sub(a,n))-1))::
                                                mtoly(a,n-1)
  in mtoly(m, Array.length(m) - 1) end;

val test = Array.tabulate(3, (fn i =>
  Array.tabulate(3, (fn j => real(i*3+j)))));
