# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# std/list.ql
#

# member/2
member(X, [X|_]).
member(X, [_|T]) :- member(X, T).

# append/2
append([], L, L).
append([H|T], L, [H|R]) :- append(T, L, R).

# length/2
length([], 0).
length([_|T], N) :- length(T, N1), N is N1 + 1.

# reverse/2
reverse(L, R) :- reverse(L, [], R).
reverse([], Acc, Acc).
reverse([H|T], Acc, R) :- reverse(T, [H|Acc], R).

# last/2
last([X], X).
last([_|T], X) :- last(T, X).
