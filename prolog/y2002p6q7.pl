% dff(D, 0, Q, Q).
% dff(D, 1, Q, D).

and(0, 0, 0).
and(0, 1, 0).
and(1, 0, 0).
and(1, 1, 1).

or(0, 0, 0).
or(0, 1, 1).
or(1, 0, 1).
or(1, 1, 1).

not(0, 1).
not(1, 0).

circuit(s(Q1, Q2, Q3), s(D1, D2, D3)) :-
  not(Q1, NQ1),
  not(Q2, NQ2),
  not(Q3, NQ3),
  and( Q1,  Q2, Q1andQ2),
  and(NQ1, NQ2, NQ1andNQ2),
  and(NQ1,  Q3, NQ1andQ3),
  and( Q2, NQ3, Q2andNQ3),
  and( Q1,  Q3, Q1andQ3),
  and(NQ2, NQ3, NQ2andNQ3),
  or(Q1andQ2, NQ1andNQ2, D1),
  or(NQ1andQ3, Q2andNQ3, D2),
  or(Q1andQ3, NQ2andNQ3, D3).

testcc(0, Init, [Init]).
testcc(N, Init, [D,Q|L]) :- N > 0, Next is N-1,
  circuit(Q, D), testcc(Next, Init, [Q|L]).


% Alternative - more verbose:

testcc(0, Init, [Init]).
testcc(N, Init, Output) :- N > 0, Next is N-1,
  Output = [CircuitOut|PreviousSteps],
  PreviousSteps = [CircuitIn|_],
  circuit(CircuitIn, CircuitOut),
  testcc(Next, Init, PreviousSteps).


% Could also use match/fail instead of atoms 1/0 to indicate truth?
% and(A, B) :- A, B.
% or(A, B) :- A; B.
% not: can use inbuilt predicate.
% e.g. and(true, fail). --> fail.
% However, not clear how to implement state triple?
