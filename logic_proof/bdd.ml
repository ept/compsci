infix 5 &&;
infix 4 ||;
infix 3 -->;
infix 2 <->;

datatype expr = op &&  of expr*expr |
                op ||  of expr*expr |
                op --> of expr*expr |
                op <-> of expr*expr |
                op !   of expr      |
                VAR    of string;

datatype bdd  = NODE   of string*bdd*bdd |
                T     | 
                F;


fun compareBDD(NODE(av,at,af), NODE(bv,bt,bf)) =
               av=bv andalso compareBDD(at,bt) andalso
                             compareBDD(af,bf)
  | compareBDD(T, T) = true
  | compareBDD(F, F) = true
  | compareBDD(_, _) = false;


fun reduceBDD(a as NODE(v,t,f)) = if compareBDD(t,f) then t else a
  | reduceBDD(a)                = a;


fun mergeBDD(func, a as NODE(av,at,af), b as NODE(bv,bt,bf)) =
        if av=bv then reduceBDD(NODE(av, func(at, bt), func(af, bf))) else
        if av<bv then reduceBDD(NODE(av, func(at, b ), func(af, b ))) else
                      reduceBDD(NODE(bv, func(a , bt), func(a , bf)))
  | mergeBDD(func, a, b) = func(a ,b);


fun bddNOT(F)   = T
  | bddNOT(T)   = F
  | bddNOT(NODE(v,t,f)) = NODE(v, bddNOT t, bddNOT f);

fun bddAND(F,_) = F
  | bddAND(_,F) = F
  | bddAND(T,a) = a
  | bddAND(a,T) = a
  | bddAND(a,b) = mergeBDD(bddAND,a,b);

fun bddOR (T,_) = T
  | bddOR (_,T) = T
  | bddOR (F,a) = a
  | bddOR (a,F) = a
  | bddOR (a,b) = mergeBDD(bddOR, a,b);

fun bddIMP(F,_) = T
  | bddIMP(_,T) = T
  | bddIMP(T,a) = a
  | bddIMP(a,F) = bddNOT(a)
  | bddIMP(a,b) = mergeBDD(bddIMP,a,b); 

fun bddIFF(F,a) = bddNOT(a)
  | bddIFF(a,F) = bddNOT(a)
  | bddIFF(T,a) = a
  | bddIFF(a,T) = a
  | bddIFF(a,b) = mergeBDD(bddIFF,a,b);


fun buildBDD (l &&  r) = mergeBDD(bddAND, buildBDD l, buildBDD r)
  | buildBDD (l ||  r) = mergeBDD(bddOR , buildBDD l, buildBDD r)
  | buildBDD (l --> r) = mergeBDD(bddIMP, buildBDD l, buildBDD r)
  | buildBDD (l <-> r) = mergeBDD(bddIFF, buildBDD l, buildBDD r)
  | buildBDD (  !r   ) = bddNOT(buildBDD r)
  | buildBDD (VAR(a) ) = NODE(a, T, F);


val p = VAR "p";
val q = VAR "q";
val r = VAR "r";
val s = VAR "s";

val test1 = (p || q) --> r;
val test2 = (p --> r) && (q --> r);

compareBDD(buildBDD test1, buildBDD test2);

