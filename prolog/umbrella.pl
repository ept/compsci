% take(L,H,T) unifies iff H is a member of list L and T is the list without H
take([H|T],H,T). 
take([H|T],R,[H|S]) :- take(T,R,S).

% list permutation
perm([],[]). 
perm(List,[H|T]) :- take(List,H,R), perm(R,T).

% Umbrella problem
speed(andy, 1).
speed(brenda, 2).
speed(carl, 5).
speed(dana, 10).

returnJourney(InHouse, InCar, GoOut, Return1, Return2, InHouseNext, InCarNext, Time) :-
    take(InHouse, GoOut, InHouse2),
    take([GoOut|InCar], Return1, InCar2),
    take(InCar2, Return2, InCarNext),
    InHouseNext = [Return1, Return2 | InHouse2],
    speed(GoOut, OutTime),
    speed(Return1, Return1Time),
    speed(Return2, Return2Time),
    Time is OutTime + max(Return1Time, Return2Time).

travels(X, Y, X, Y, 0, []).
travels(InHouse, InCar, InHouseFinal, InCarFinal, TotalTime, Log) :-
    returnJourney(InHouse, InCar, GoOut, Return1, Return2, InHouseNext, InCarNext, Time),
    travels(InHouseNext, InCarNext, InHouseFinal, InCarFinal, TotalTimeNext, LogNext),
    Log = [out(GoOut), return(Return1, Return2) | LogNext],
    TotalTime is Time + TotalTimeNext.

solve(Log, Time) :-
    perm([andy, brenda, carl, dana], Everybody),
    travels([andy], [brenda, carl, dana], Everybody, [], Time, Log).

iterative([Time|Log], Time) :- solve(Log, Time).
iterative(Log, Time) :- LongerTime is Time + 1, iterative(Log, LongerTime).
iterative(Log) :- iterative(Log, 0).

