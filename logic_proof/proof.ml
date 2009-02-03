datatype atom = P|Q|R;
datatype formula = AND  of formula*formula
                 | OR   of formula*formula
                 | NOT  of formula 
                 | IMPL of formula*formula 
                 | IFF  of formula*formula 
                 | ATOM of atom;
datatype interpr = CONS of atom*bool*interpr | NIL;

fun nnf (AND (f,g)) = AND (nnf f, nnf g)
  | nnf (OR  (f,g)) = OR  (nnf f, nnf g)
  | nnf (NOT (AND (f,g))) = OR (nnf (NOT(f)), nnf (NOT(g)))
  | nnf (NOT (OR  (f,g))) = AND(nnf (NOT(f)), nnf (NOT(g)))
  | nnf (NOT (NOT (f  ))) = nnf f
  | nnf (NOT (ATOM(a  ))) = NOT(ATOM(a))
  | nnf (NOT (f  )) = nnf (NOT(nnf f))
  | nnf (IMPL(f,g)) = OR  (nnf (NOT(f)), nnf g)
  | nnf (IFF (f,g)) = AND (nnf (IMPL(f,g)), nnf (IMPL(g,f)))
  | nnf (f)         = f;

fun boolVal(a, CONS(b, v, n)) = if a = b then v else boolVal(a, n) | boolVal(a, NIL) = false;

fun satisfies(i, AND (f,g)) = satisfies(i, f) andalso satisfies(i, g)
  | satisfies(i, OR  (f,g)) = satisfies(i, f) orelse  satisfies(i, g)
  | satisfies(i, NOT (f)  ) = not (satisfies(i, f))
  | satisfies(i, ATOM(a)  ) = boolVal(a, i)
  | satisfies(i, f)         = satisfies(i, nnf f);

val test = IFF(ATOM(P), ATOM(Q));
val testint = CONS(P, true, CONS(Q, false, NIL));
val testint2 = CONS(P, true, CONS(Q, true, NIL));

satisfies(testint, nnf test);
satisfies(testint2, nnf test);
