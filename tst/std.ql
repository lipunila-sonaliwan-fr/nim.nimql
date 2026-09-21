#
# tst/std.ql
#

# std/integer.ql
?- pgcd(624,408, PGCDis24).
?- sum(5,SUMis16,21).
?- mul(4,5,MULis21,1).
?- sumrange(2,5,SUMRANGEis14).

# std/list.ql
?- length([1,2,3,4,5],Lis5).
?- last([1,2,3],Lis3).
?- append([1,2],[3,4],RisKO).
?- reverse([1,2,3],[],RisKO).
:- writeln('-> true').
?- member(2, [1,2,3]).
?- member(b, [a,b,c]).
:- writeln('-> false').
?- member(4, [1,2,3]).
?- member(d, [a,b,c]).

# is(_X) :- _X, write('YES'), !.
# is(_X) :- write('NO'), fail.
