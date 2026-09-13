# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# sample1.ql
#

:- kill log.
:- kill logn.
:- kill logspc.
:- kill logvar.
:- kill sumrange.
logspc(S) :- gt(S, 0), write(" "), S1 is S - 1, logspc(S1).
logspc(S) :- eq(S, 0), write(" ").
logvar(R) :- nonvar(R), write(R).
logvar(R) :- var(R), write('R?').
log(A, B, R, M, S)   :- logspc(S), write(M), write("("), write(A), write(","), write(B), write(","), logvar(R), write(")").
logn(A, B, R, M, S)  :- log(A, B, R, M, S), writeln("").
sumrange(A, B, R, S) :- writeln(""), log(A, B, R, "=> eq : ", S), eq(A, B), writeln(" [true]"), R is B, logn(A, B, R, "<-    = ", S).
sumrange(A, B, R, S) :- writeln(""), log(A, B, R, "=> lt : ", S), lt(A, B), writeln(" [true]"), B1 is B - 1, log(A, B1, R, "   -> sumrange", S), S1 is S + 6, sumrange(A, B1, R1, S1), R is B + R1, logn(A, B, R, "<-    = ", S).

?-sumrange(2, 5, R, 0).
