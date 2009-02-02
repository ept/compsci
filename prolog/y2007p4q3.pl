replace(_, _, [], []).
replace(Old, New, [Old|In], [New|Out]) :- replace(Old, New, In, Out).
replace(Old, New, [H|In], [H|Out]) :- Old \= H, replace(Old, New, In, Out).

firstThree([L1,L2,L3|Rest], [L1,L2,L3], Rest).
cons([H|T], H, T).

textify(_, _, [], []).
textify(P, R, In, [R|Out]) :-
  firstThree(In, P, Next), textify(P, R, Next, Out).
textify(P, R, In, Out) :-
  not(firstThree(In, P, _)),
  cons(In, H, InTail), cons(Out, H, OutTail),
  textify(P, R, InTail, OutTail).

fullTextify(In, Out) :-
  textify([a,t,e], 8, In, T1),
  textify([y,o,u], u, T1, T2),
  textify([s,e,e], c, T2, Out).

:- fullTextify([s,e,e,' ',y,o,u,' ',l,a,t,e,r,' ',k,a,t,e],
  [c,' ',u,' ',l,8,r,' ',k,8]).

% Generalising to replacing N characters instead of 3 is just a matter
% of replacing firstThree (since textify itself is independent of the
% number of characters replaced).
