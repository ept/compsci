load "Int";

datatype expr =
    TRANS of expr * expr * expr     (* TRANS(e, k, s) == "[[ e ]] (k, s)"       *)
  | PAIR of expr * expr             (* PAIR(e1, e2) == "(e1, e2)"               *)
  | TRIPLE of expr * expr * expr    (* TRIPLE(e1, e2, e3) == "(e1, e2, e3)"     *)
  | LAMBDA of expr * expr           (* LAMBDA(x, e) == "lambda x. e"  -- x can only be VAR, PAIR or TRIPLE *)
  | APP of expr * expr              (* APP(e1, e2) == "e1 e2"                   *)
  | SEQ of expr * expr              (* SEQ(e1, e2) == "e1; e2"                  *)
  | ASSIGN of expr * expr           (* ASSIGN(x, e) == "x := e"                 *)
  | READ of expr                    (* READ(x) == "!x"                          *)
  | STATE of ((string * expr) list) (* STATE(s) == [(key1 => val1), ...]        *)
  | GET of expr * expr              (* GET(state, LOC(x)) == state[x]           *)
  | SET of expr * expr * expr       (* SET(state, LOC(x), val) == state[x=>val] *)
  | LOC of string
  | VAR of string
  | CONST of string
  | UNIT;

val var_counter = ref 0;
fun next_var(prefix) = (var_counter := !var_counter + 1; prefix ^ Int.toString(!var_counter));

exception NotFound;

fun getState([], varName) = raise NotFound
  | getState((key, value) :: states, varName) = if key = varName then value else (getState(states, varName));

fun setState([], varName, newVal) = [(varName, newVal)]
  | setState((key, oldVal) :: states, varName, newVal) =
        if key = varName then (key, newVal) :: states
                         else (key, oldVal) :: (setState(states, varName, newVal));


(* Apply transformation to continuation passing form. *)
fun translate (TRANS(LOC(x), k, s)) = APP(k, PAIR(LOC(x), s))
  | translate (TRANS(VAR(x), k, s)) = APP(k, PAIR(VAR(x), s))
  | translate (TRANS(CONST(c), k, s)) = APP(k, PAIR(CONST(c), s))
  | translate (TRANS(LAMBDA(VAR(x), e), k, s)) = 
      let val k1 = VAR(next_var("k")) and s1 = VAR(next_var("s")) in
        APP(k, PAIR(LAMBDA(TRIPLE(VAR(x), k1, s1), TRANS(e, k1, s1)), s))
      end
  | translate (TRANS(APP(m, n), k, s)) =
      let val x1 = VAR(next_var("x")) and s1 = VAR(next_var("s"))
          and x2 = VAR(next_var("x")) and s2 = VAR(next_var("s")) in
        TRANS(m, 
            LAMBDA(PAIR(x1, s1),
                TRANS(n,
                    LAMBDA(PAIR(x2, s2), APP(x1, TRIPLE(x2, k, s2))),
                    s1)),
            s)
      end
  | translate (TRANS(READ x, k, s)) =
      let val x1 = VAR(next_var("x")) and s1 = VAR(next_var("s")) in
        TRANS(x, LAMBDA(PAIR(x1, s1), APP(k, PAIR(GET(s1, x), s1))), s)
      end
  | translate (TRANS(ASSIGN(x, v), k, s)) =
      let val x1 = VAR(next_var("x")) and s1 = VAR(next_var("s"))
          and x2 = VAR(next_var("x")) and s2 = VAR(next_var("s")) in
        TRANS(x, 
            LAMBDA(PAIR(x1, s1),
                TRANS(v,
                    LAMBDA(PAIR(x2, s2), APP(k, PAIR(UNIT, SET(s2, x1, x2)))),
                    s1)),
            s)
      end
  | translate (TRANS(SEQ(m, n), k, s)) =
      let val x1 = VAR(next_var("x")) and s1 = VAR(next_var("s"))
          and x2 = VAR(next_var("x")) and s2 = VAR(next_var("s")) in
        TRANS(m, 
            LAMBDA(PAIR(x1, s1),
                TRANS(n,
                    LAMBDA(PAIR(x2, s2), APP(k, PAIR(x2, s2))),
                    s1)),
            s)
      end
  | translate (PAIR(x, y)) = PAIR(translate x, translate y)
  | translate (TRIPLE(x, y, z)) = TRIPLE(translate x, translate y, translate z)
  | translate (LAMBDA(x, e)) = LAMBDA(x, translate e)
  | translate (APP(x, y)) = APP(translate x, translate y)
  | translate x = x;


(* true if e contains VAR(x), otherwise false *)
fun freeVar(VAR(x), y) = (x = y)
  | freeVar(PAIR(e, f), x) = (freeVar(e, x)) orelse (freeVar(f, x))
  | freeVar(TRIPLE(e, f, g), x) = (freeVar(e, x)) orelse (freeVar(f, x)) orelse (freeVar(g, x))
  | freeVar _ = false;


(* Substitute an expression for all occurrences of a particular variable.
   substitute(e, x, m) == e[x/m] *)
fun substitute (VAR(x), y, m) = if x = y then m else VAR(x)
  | substitute (PAIR(e, f), x, m) = PAIR(substitute(e, x, m), substitute(f, x, m))
  | substitute (TRIPLE(e, f, g), x, m) = TRIPLE(substitute(e, x, m), substitute(f, x, m), substitute(g, x, m))
  | substitute (LAMBDA(e, f), x, m) = if freeVar(e, x) then LAMBDA(e, f) else LAMBDA(e, substitute(f, x, m))
  | substitute (APP(e, f), x, m) = APP(substitute(e, x, m), substitute(f, x, m))
  | substitute (GET(e, f), x, m) = GET(substitute(e, x, m), substitute(f, x, m))
  | substitute (SET(e, f, g), x, m) = SET(substitute(e, x, m), substitute(f, x, m), substitute(g, x, m))
  | substitute (x, _, _) = x;


(* Perform beta reduction (e.g. for simplification). *)
fun reduce (APP(LAMBDA(VAR(x), e), f)) = substitute(e, x, f)
  | reduce (APP(LAMBDA(PAIR(VAR(x), VAR(y)), e), PAIR(f, g))) = substitute(substitute(e, x, f), y, g)
  | reduce (APP(LAMBDA(TRIPLE(VAR(x), VAR(y), VAR(z)), e), TRIPLE(f, g, h))) =
      substitute(substitute(substitute(e, x, f), y, g), z, h)
  | reduce (GET(STATE(s), LOC(x))) = getState(s, x)
  | reduce (SET(STATE(s), LOC(x), e)) = STATE(setState(s, x, e))
  | reduce (PAIR(e, f)) = PAIR(reduce e, reduce f)
  | reduce (TRIPLE(e, f, g)) = TRIPLE(reduce e, reduce f, reduce g)
  | reduce (LAMBDA(e, f)) = LAMBDA(e, reduce f)
  | reduce (APP(e, f)) = APP(reduce e, reduce f)
  | reduce (GET(e, f)) = GET(reduce e, reduce f)
  | reduce (SET(e, f, g)) = SET(reduce e, reduce f, reduce g)
  | reduce x = x;


(* Returns true if the expression may require bracketing. *)
fun isFragile (APP(_,_))    = true
  | isFragile (LAMBDA(_,_)) = true
  | isFragile (SEQ(_,_))    = true
  | isFragile (ASSIGN(_,_)) = true
  | isFragile (READ(_))     = true
  | isFragile  _            = false;

(* Join several strings with a separator. *)
fun join separator [] = ""
  | join separator [x] = x
  | join separator (x::xs) = x ^ separator ^ (join separator xs);


(* Pretty-print an expression. *)
fun prettyPrint (TRANS(e, k, s))      = "[[" ^ (prettyPrint e) ^ "]](" ^ (prettyPrint k) ^ ", " ^ (prettyPrint s) ^ ")"
  | prettyPrint (PAIR(e1, e2))        = "<" ^ (prettyPrint e1) ^ ", " ^ (prettyPrint e2) ^ ">"
  | prettyPrint (TRIPLE(e1, e2, e3))  = "<" ^ (prettyPrint e1) ^ ", " ^ (prettyPrint e2) ^ ", " ^ (prettyPrint e3) ^ ">"
  | prettyPrint (LAMBDA(x, e))        = "^" ^ (prettyPrint x) ^ ". " ^ (prettyPrint e)
  | prettyPrint (APP(m, n))           = (maybeBrackets m) ^ " " ^ (maybeBrackets n)
  | prettyPrint (SEQ(m, n))           = (maybeBrackets m) ^ "; " ^ (maybeBrackets n)
  | prettyPrint (ASSIGN(x, e))        = (maybeBrackets x) ^ " := " ^ (maybeBrackets e)
  | prettyPrint (READ x)              = "!" ^ (maybeBrackets x)
  | prettyPrint (STATE s)             = "{" ^ (join ", " (map (fn(k,v) => k ^ " => " ^ (prettyPrint v)) s)) ^ "}"
  | prettyPrint (GET(s, x))           = (maybeBrackets s) ^ "[" ^ (prettyPrint x) ^ "]"
  | prettyPrint (SET(s, x, v))        = (maybeBrackets s) ^ "[" ^ (prettyPrint x) ^ " => " ^ (prettyPrint v) ^ "]"
  | prettyPrint (LOC x)               = x
  | prettyPrint (VAR x)               = x
  | prettyPrint (CONST c)             = c
  | prettyPrint UNIT                  = "()"
and maybeBrackets m =
    let val fragile = isFragile m
      in (if fragile then "(" else "") ^ (prettyPrint m) ^ (if fragile then ")" else "") end;


(* Translates an expression completely into continuation passing form, printing
   out each step of the conversion along the way. *)
fun printTranslationSteps (expr, str) =
    let val expr2 = translate expr
    in if expr = expr2 then (expr2, str)
       else (printTranslationSteps (expr2, str ^ "\n" ^ (prettyPrint expr2) ^ "\n")) end;


(* Takes an expression in continuation passing form, and reduces it to normal form,
   printing out each reduction step along the way. *)
fun printReductionSteps (expr, str) =
    let val expr2 = reduce expr
    in if expr = expr2 then (expr2, str)
       else (printReductionSteps (expr2, str ^ "\n" ^ (prettyPrint expr2) ^ "\n")) end;


val example = TRANS(APP(LAMBDA(VAR("x"), VAR("x")), CONST("1")), VAR("k"), STATE([]));

val (translated, translation_steps) = printTranslationSteps(example, prettyPrint(example) ^ "\n");
val (reduced, reduction_steps) = printReductionSteps(translated, translation_steps);

val example2 = TRANS(ASSIGN(LOC("y"), CONST("2")), VAR("k"), STATE([("y",CONST("1"))]));

val (translated2, translation_steps2) = printTranslationSteps(example2, prettyPrint(example2) ^ "\n");
val (reduced2, reduction_steps2) = printReductionSteps(translated2, translation_steps2);

val example3 =
    TRANS(
        SEQ(
            ASSIGN(                     (* f := (^x. y := x; 2) *)
                LOC("f"),
                LAMBDA(VAR("x"), SEQ(ASSIGN(LOC("y"), VAR("x")), CONST("2")))
            ),
            ASSIGN(                     (* y := ((!f)(42)) *)
                LOC("y"),
                APP(READ(LOC("f")), CONST("42"))
            )
        ),
        VAR("k"),
        STATE([("y",CONST("1"))])
    );

val (translated3, translation_steps3) = printTranslationSteps(example3, prettyPrint(example3) ^ "\n");
val (reduced3, reduction_steps3) = printReductionSteps(translated3, translation_steps3);

print ("\n\nExample 1: constant 1 applied to identity function\n\n" ^ reduction_steps);
print ("\n\nExample 2: simple variable assignment\n\n" ^ reduction_steps2);
print ("\n\nExample 3: a contrived sequence of assignments\n\n" ^ reduction_steps3);
