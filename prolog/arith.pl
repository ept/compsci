prim(1, i).
prim(Num, s(PrePrim)) :- PreNum is Num - 1, prim(PreNum, PrePrim).

plus(i, B, s(B)).
plus(s(A), B, s(C)) :- plus(A, B, C).

mult(i, B, B).
mult(s(A), B, CplusB) :- plus(B, C, CplusB), mult(A, B, C).

