% list(L) is true if L is a list.
list([]).
list([_|_]).

% eg. take([a,b], a, [b])
take([H|T],H,T). 
take([H|T],R,[H|S]) :- take(T,R,S).

% list permutations
perm([],[]). 
perm(List,[H|T]) :- take(List,H,R), perm(R,T).

% Implement a clause choose(N,L,R,S) that chooses N items from L and puts them in R with the 
% remaining elements in L left in S.
% Returns all possible orderings of the N chosen elements.
choose(0, L, [],    L).
choose(M, L, [E|R], S) :- N is M-1, take(L, E, L1), choose(N, L1, R, S).


% n-queens:

% list of numbers 1 to N:
numbers(1, [1]) :- !.
numbers(N, [N|L]) :- Next is N - 1, numbers(Next, L).

downwardDiagonal(Position, [Row|Rows]) :- P1 is Position - 1, (P1 = Row; downwardDiagonal(P1, Rows)).
upwardDiagonal(Position,   [Row|Rows]) :- P1 is Position + 1, (P1 = Row;   upwardDiagonal(P1, Rows)).
findIntersection(L) :- findIntersection([], L).
findIntersection(Before, [This|After]) :-
  downwardDiagonal(This, Before); upwardDiagonal(This, Before);
  downwardDiagonal(This, After ); upwardDiagonal(This, After );
  findIntersection([This|Before], After).
checkDiagonals(Rows) :- findIntersection(Rows), !, fail.
checkDiagonals(_).

nQueens(N, Rows) :- numbers(N, Numbers), perm(Numbers, Rows), checkDiagonals(Rows).
