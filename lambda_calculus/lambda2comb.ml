(*
 * Convert a lambda calculus expression into an equivalent combinator expression.
 * Pretty-prints terms at various stages of their evolution.
 * (c) Martin Kleppmann <martin@kleppmann.de>, 2008-03-08
 *)

datatype expr =
    CONST of string
  | VAR of string
  | LAM of string * expr
  | APP of expr * expr
  | S | K | Y | I | B | C;

(* Tests whether a given expression (second argument) contains a particular
   free variable (first argument). *)
fun hasFreeVar x (VAR y) = x = y
  | hasFreeVar x (LAM(y,m)) = if x = y then false else (hasFreeVar x m)
  | hasFreeVar x (APP(m,n)) = (hasFreeVar x m) orelse (hasFreeVar x n)
  | hasFreeVar _ _ = false;

(* Tests whether two given expressions are syntactically equal. *)
fun exprEqual (CONST x)  (CONST y)  = x = y
  | exprEqual (VAR x)    (VAR y)    = x = y
  | exprEqual (LAM(x,m)) (LAM(y,n)) = (x = y) andalso (exprEqual m n)
  | exprEqual (APP(a,b)) (APP(c,d)) = (exprEqual a c) andalso (exprEqual b d)
  | exprEqual  a          b         = a = b;

(* David Turner's advanced translation from lambda calculus to combinators
   (may need to be applied multiple times in order to complete -- this is done
   by the lambdaToComb function). *)
fun conversionStep (LAM(x, CONST y)) = APP(K, CONST y)
  | conversionStep (LAM(x, VAR y)) = if x = y then I else APP(K, VAR y)
  | conversionStep (LAM(x, LAM(y, m))) =
        let val n = LAM(y, m) in
        if (hasFreeVar x n) then (LAM(x, conversionStep n)) else (APP(K, conversionStep n)) end
  | conversionStep (LAM(x, APP(a, b))) =
        let val varLeft  = hasFreeVar x a
            and varRight = hasFreeVar x b
        in if varLeft then
                if varRight then APP(APP(S, LAM(x, a)), LAM(x, b))
                            else APP(APP(C, LAM(x, a)), b)
           else
                if varRight then APP(APP(B, a), LAM(x, b))
                            else APP(K, APP(a, b))
        end
  | conversionStep (APP(m, n)) = APP(conversionStep m, conversionStep n)
  | conversionStep m = m;

(* Translate a lambda calculus expression into a combinator expression.
   Applies conversionStep repeatedly until no change in the expression is detected. *)
fun lambdaToComb ex =
        let val ex2 = conversionStep ex
        in if (exprEqual ex ex2) then ex2 else (lambdaToComb ex2) end;

(* Returns true if the lambda expression is just a constant or a variable, false otherwise. *)
fun isPrimitive (APP(_,_)) = false
  | isPrimitive (LAM(_,_)) = false
  | isPrimitive  _         = true;

(* Returns true if the lambda expression is a constant or a variable,
    or if the outermost node is a function application. False otherwise. *)
fun isPrimOrApp (APP(_,_)) = true
  | isPrimOrApp x = isPrimitive x;

(* Pretty-prints a lambda or combinator expression. *)
fun prettyPrint (CONST c) = c
  | prettyPrint (VAR x) = x
  | prettyPrint (LAM(x,m)) = "^" ^ x ^ ". " ^ (prettyPrint m)
  | prettyPrint (APP(m,n)) = (maybeBrackets1 m) ^ " " ^ (maybeBrackets2 n)
  | prettyPrint S = "S"
  | prettyPrint K = "K"
  | prettyPrint Y = "Y"
  | prettyPrint I = "I"
  | prettyPrint B = "B"
  | prettyPrint C = "C"
and maybeBrackets1 m =
        let val primM = isPrimOrApp m
        in (if primM then "" else "(") ^ (prettyPrint m) ^ (if primM then "" else ")") end
and maybeBrackets2 m =
        let val primM = isPrimitive m
        in (if primM then "" else "(") ^ (prettyPrint m) ^ (if primM then "" else ")") end;

(* Pretty-prints the conversion from a lambda expression to a combinator expression,
   step by step. *)
fun printSteps (ex, str) =
        let val ex2 = conversionStep ex
        in if (exprEqual ex ex2) then str
           else (printSteps (ex2, str ^ "\n" ^ (prettyPrint ex2) ^ "\n")) end;

(* EXAMPLE OF USE *)

(* A very verbose definition of the factorial function in lambda calculus *)

val fact =
    APP(
        Y,
        LAM("f",
            LAM("x", 
                APP(
                    APP(
                        APP(
                            CONST "if",
                            APP(
                                APP(
                                    CONST "=",
                                    VAR "x"
                                ),
                                CONST "0"
                            )
                        ),
                        CONST "1"
                    ),
                    APP(
                        APP(
                            CONST "*",
                            VAR "x"
                        ),
                        APP(
                            VAR "f",
                            APP(
                                APP(
                                    CONST "-",
                                    VAR "x"
                                ),
                                CONST "1"
                            )
                        )
                    )
                )
            )
        )
     );

(* Print the original lambda calculus expression *)
print ("\n\nThe factorial function in lambda calculus:\n"
  ^ (prettyPrint fact) ^ "\n\n"
  ^ (printSteps(fact, "Translating into combinators, step by step:\n")) ^ "\n\n");

