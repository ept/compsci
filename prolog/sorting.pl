% All cuts in this file are green cuts (i.e. just for efficiency, no effect on logic).

% Selection sort

minElement([X], X) :- !.
minElement([H|T], Min) :- minElement(T, MinT), Min is min(H, MinT).

removeFirst([H|T], H, T) :- !.
removeFirst([H|T], X, [H|RestT]) :- H \= X, removeFirst(T, X, RestT).

selSort([], []) :- !.
selSort(List, Sorted) :-
    minElement(List, Min),
    removeFirst(List, Min, Rest),
    selSort(Rest, RestSorted),
    Sorted = [Min|RestSorted].


% Alternative implementation of selection sort (by Conrad Irwin)

minElement([X],   X, [])     :- !.
minElement([H|T], H, T)      :- minElement(T, M, _ ), H =< M, !.
minElement([H|T], M, [H|T2]) :- minElement(T, M, T2), H  > M.

selSort2([], []) :- !.
selSort2(List, [Min|Sorted]) :-
    minElement(List, Min, Rest),
    selSort2(Rest, Sorted).


% Quicksort

partition([], _, [], []) :- !.
partition([H|T], Pivot, Less, [H|GreaterEqual]) :-
    H >= Pivot, partition(T, Pivot, Less, GreaterEqual), !.
partition([H|T], Pivot, [H|Less], GreaterEqual) :-
    Pivot > H,  partition(T, Pivot, Less, GreaterEqual).

quickSort([], []).
quickSort([Pivot|Rest], Sorted) :-
    partition(Rest, Pivot, LT, GTE),
    quickSort(LT, LTSorted),
    quickSort(GTE, GTESorted),
    append(LTSorted, [Pivot|GTESorted], Sorted).


% Quicksort partition in 3

partition([], _, [], [], []).
partition([H|T], Pivot, Less, Equal, [H|Greater]) :-
    H > Pivot, partition(T, Pivot, Less, Equal, Greater), !.
partition([H|T], Pivot, Less, [H|Equal], Greater) :-
    H = Pivot, partition(T, Pivot, Less, Equal, Greater), !.
partition([H|T], Pivot, [H|Less], Equal, Greater) :-
    Pivot > H, partition(T, Pivot, Less, Equal, Greater).

quickSort3([], []).
quickSort3([Pivot|Rest], Sorted) :-
    partition(Rest, Pivot, LT, EQ, GT),
    quickSort3(LT, LTSorted),
    quickSort3(GT, GTSorted),
    append([Pivot|EQ], GTSorted, GTESorted),
    append(LTSorted, GTESorted, Sorted).


% Quicksort with difference lists

% Implementation using difference list append 'dapp':
dapp(A-B, B-C, A-C).
quickSortDiffInternal1([], A-A).
quickSortDiffInternal1([Pivot|Rest], Sorted-SortedT) :-
    partition(Rest, Pivot, LT, GTE),
    quickSortDiffInternal1(LT, LTSorted-LTSortedT),
    quickSortDiffInternal1(GTE, GTESorted-GTESortedT),
    dapp(LTSorted-LTSortedT, [Pivot|GTESorted]-GTESortedT, Sorted-SortedT).

% Replacing 'dapp' by doing the unifications ourselves:
% LTSorted = Sorted, LTSortedT = [Pivot|GTESorted], GTESortedT = SortedT
quickSortDiffInternal2([], A-A).
quickSortDiffInternal2([Pivot|Rest], Sorted-SortedT) :-
    partition(Rest, Pivot, LT, GTE),
    quickSortDiffInternal2(LT, Sorted - [Pivot|GTESorted]),
    quickSortDiffInternal2(GTE, GTESorted - SortedT).

quickSortDiff(In, Out) :- quickSortDiffInternal2(In, Out-[]).


% Mergesort

merge([], A, A) :- !.
merge(A, [], A) :- A \= [], !.  % Ensure only one of the two rules matches ([], [], _)
merge([H1|T1], [H2|T2], [H1|M]) :- H1 =< H2, merge(T1, [H2|T2], M), !.
merge([H1|T1], [H2|T2], [H2|M]) :- H1  > H2, merge([H1|T1], T2, M).

% Split: add one item at a time, alternating between the two result lists.
split([], [], []) :- !.
split([A], [A], []) :- !.
split([H1,H2|T], [H1|T1], [H2|T2]) :- split(T, T1, T2).

mergeSort([], []) :- !.
mergeSort([A], [A]) :- !.
mergeSort(In, Out) :-
    In \= [], In \= [_], % prevent infinite recursion
    split(In, L1, L2),
    mergeSort(L1, S1),
    mergeSort(L2, S2),
    merge(S1, S2, Out).

%Bubble sort

swap([X,Y|Rest], [Y,X|Rest]) :- X>Y.
swap([Z|Rest], [Z|Rest1]) :- swap(Rest, Rest1).
  
bubbleSort(List, Sorted) :-
	swap(List, List1), !,
	bubbleSort(List1, Sorted).
bubbleSort(Sorted, Sorted).

%Insertion sort

insert(A, [B|C], [B|D]) :- A @> B, !, insert(A, C, D).
insert(A, C, [A|C]).

insertionSort(L, Sorted) :- insertionSort(L, [], Sorted).

insertionSort([], Acc, Acc).
insertionSort([H | T], Acc, Sorted) :- 
	insert(H, Acc, Acc1),
	insertionSort(T, Acc1, Sorted).
