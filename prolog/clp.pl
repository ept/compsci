% Cryptarithmetic using Constraint Logic Programming

:- use_module(library(bounds)).

% Part 1 -- as given on problem sheet

solve1([S,E,N,D],[M,O,R,E],[M,O,N,E,Y]) :-
    Var = [S,E,N,D,M,O,R,Y],
    Var in 0..9, all_different(Var),
              1000*S + 100*E + 10*N + D +
              1000*M + 100*O + 10*R + E #=
    10000*M + 1000*O + 100*N + 10*E + Y,
    labeling([], Var).

:- findall([X,Y,Z], solve1(X,Y,Z), Sols), length(Sols, 25).


% Part 2 -- leading digit not zero

solve2([S,E,N,D],[M,O,R,E],[M,O,N,E,Y]) :-
    Var = [S,E,N,D,M,O,R,Y],
    Var in 0..9, all_different(Var),
              1000*S + 100*E + 10*N + D +
              1000*M + 100*O + 10*R + E #=
    10000*M + 1000*O + 100*N + 10*E + Y,
    S #\= 0, M #\= 0,
    labeling([], Var).

:- findall([X,Y,Z], solve2(X,Y,Z), Sols), length(Sols, 1).


% Part 3 -- arbitrary base

solve3(Base,[S,E,N,D],[M,O,R,E],[M,O,N,E,Y]) :-
    Base2 is Base*Base,
    Base3 is Base*Base2,
    Base4 is Base*Base3,
    MaxDigit is Base - 1,
    Var = [S,E,N,D,M,O,R,Y],
    Var in 0..MaxDigit, all_different(Var),
              Base3*S + Base2*E + Base*N + D +
              Base3*M + Base2*O + Base*R + E #=
    Base4*M + Base3*O + Base2*N + Base*E + Y,
    S #\= 0, M #\= 0,
    labeling([], Var).

:- findall([X,Y,Z], solve3(16,X,Y,Z), Sols), length(Sols, 28).

% Part 4 -- count number of solutions

count(Base,N) :- findall([X,Y,Z], solve3(Base,X,Y,Z), Sols), length(Sols, N).

% Part 5 -- number of solutions by base

countBases(sol(Base,N)) :- between(1,50,Base), count(Base,N).
solsByBase(List) :- findall(X, countBases(X), List).

:- solsByBase(List), List = [
    sol(1, 0), sol(2, 0), sol(3, 0), sol(4, 0), sol(5, 0), sol(6, 0), sol(7, 0), sol(8, 0), sol(9, 0),
    sol(10, 1), sol(11, 3), sol(12, 6), sol(13, 10), sol(14, 15), sol(15, 21), sol(16, 28), sol(17, 36),
    sol(18, 45), sol(19, 55), sol(20, 66), sol(21, 78), sol(22, 91), sol(23, 105), sol(24, 120), sol(25, 136),
    sol(26, 153), sol(27, 171), sol(28, 190), sol(29, 210), sol(30, 231), sol(31, 253), sol(32, 276), sol(33, 300),
    sol(34, 325), sol(35, 351), sol(36, 378), sol(37, 406), sol(38, 435), sol(39, 465), sol(40, 496), sol(41, 528),
    sol(42, 561), sol(43, 595), sol(44, 630), sol(45, 666), sol(46, 703), sol(47, 741), sol(48, 780), sol(49, 820),
    sol(50, 861)].


% Note -- the solutions above do not take carries into account. The following code from
% http://www.cs.mu.oz.au/255/Manual/clpbounds.html does deal with carries
% and has one solution:

send([[S,E,N,D], [M,O,R,E], [M,O,N,E,Y]])  :-
              Digits   =  [S,E,N,D,M,O,R,Y],
              Carries  =  [C1,C2,C3,C4],
              Digits  in  0..9,
              Carries in  0..1,

              M                #=              C4,
              O  +  10  *  C4  #=  M  +  S  +  C3,
              N  +  10  *  C3  #=  O  +  E  +  C2,
              E  +  10  *  C2  #=  R  +  N  +  C1,
              Y  +  10  *  C1  #=  E  +  D,

              M  #>=  1,
              S  #>=  1,
              all_different(Digits),
              label(Digits).

