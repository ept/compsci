load "Int";
load "Binarymap";

datatype 'a state = STATE of (string, 'a) Binarymap.dict;

datatype expr =
    TRANS of expr * expr * expr     (* TRANS(e, k, s) == "[[ e ]] (k, s)"     *)
  | PAIR of expr * expr             (* PAIR(e1, e2) == "(e1, e2)"             *)
  | TRIPLE of expr * expr * expr    (* TRIPLE(e1, e2, e3) == "(e1, e2, e3)"   *)
  | LAMBDA of expr * expr           (* LAMBDA(x, e) == "lambda x. e"  -- x can only be VAR, PAIR or TRIPLE *)
  | APP of expr * expr              (* APP(e1, e2) == "e1 e2"                 *)
  | SEQ of expr * expr              (* SEQ(e1, e2) == "e1; e2"                *)
  | ASSIGN of expr * expr           (* ASSIGN(x, e) == "x := e"               *)
  | READ of expr                    (* READ(x) == "!x"                        *)
  | LOC of string
  | VAR of string
  | CONST of string;

val var_counter = ref 0;
fun next_var(prefix) = (var_counter := !var_counter + 1; prefix ^ Int.toString(!var_counter));

fun translate (TRANS(VAR(x), k, s)) = APP(k, PAIR(VAR(x), s))
  | translate (TRANS(CONST(c), k, s)) = APP(k, PAIR(CONST(c), s))
  | translate (TRANS(LAMBDA(VAR(x), e), k, s)) = 
      let val k1 = VAR(next_var("k")) and s1 = VAR(next_var("s")) in
        APP(k, PAIR(LAMBDA(TRIPLE(VAR(x), k1, s1), TRANS(e, k1, s1)), s))
      end
  | translate x = x;


(* Returns true if the expression may require bracketing. *)
fun isFragile (APP(_,_))    = true
  | isFragile (LAMBDA(_,_)) = true
  | isFragile (SEQ(_,_))    = true
  | isFragile (ASSIGN(_,_)) = true
  | isFragile  _            = false;

fun prettyPrint (TRANS(e, k, s))      = "[[ " ^ (prettyPrint e) ^ " ]] (" ^ (prettyPrint k) ^ ", " ^ (prettyPrint s) ^ ")"
  | prettyPrint (PAIR(e1, e2))        = "(" ^ (prettyPrint e1) ^ ", " ^ (prettyPrint e2) ^ ")"
  | prettyPrint (TRIPLE(e1, e2, e3))  = "(" ^ (prettyPrint e1) ^ ", " ^ (prettyPrint e2) ^ ", " ^ (prettyPrint e3) ^ ")"
  | prettyPrint (LAMBDA(x, e))        = "^" ^ (prettyPrint x) ^ ". " ^ (prettyPrint e)
  | prettyPrint (APP(m, n))           = (maybeBrackets m) ^ " " ^ (maybeBrackets n)
  | prettyPrint (SEQ(m, n))           = (maybeBrackets m) ^ "; " ^ (maybeBrackets n)
  | prettyPrint (ASSIGN(x, e))        = (maybeBrackets x) ^ " := " ^ (maybeBrackets e)
  | prettyPrint (READ x)              = "!" ^ (maybeBrackets x)
  | prettyPrint (VAR x)               = x
  | prettyPrint (CONST c)             = c
and maybeBrackets m =
    let val fragile = isFragile m
      in (if fragile then "(" else "") ^ (prettyPrint m) ^ (if fragile then ")" else "") end;


val example = TRANS(LAMBDA(VAR("x"), VAR("x")), VAR("k"), VAR("s"));
print ("\n\nExample:\n\n" ^ prettyPrint(example) ^ "\n\n  -->\n\n" ^ prettyPrint(translate(example)) ^ "\n");

