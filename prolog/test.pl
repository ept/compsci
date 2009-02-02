last([H],H). 
last([_|T],H) :- last(T,H). 
% this is a test assertion 
:- last([1,2,3],A), A=4.
