# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# std/integer.ql
#

# pgcd/3
pgcd(X,X,X).
pgcd(X,Y,R):- lt(X,Y), Y1 is Y-X, pgcd(X,Y1,R).
pgcd(X,Y,R):- gt(X,Y), pgcd(Y,X,R).

# sum/3
sum(A, B, C) :- nonvar(A), nonvar(B), C is A + B.
sum(A, B, C) :- nonvar(A), nonvar(C), B is C - A.
sum(A, B, C) :- nonvar(B), nonvar(C), A is C - B.

# sumrange/3
sumrange(A, B, Z) :- eq(A, B), Z is B.
sumrange(A, B, Z) :- lt(A, B), B1 is B - 1, sumrange(A, B1, Z1), Z is B + Z1.

# mul/3
mul(A, B, C) :- nonvar(A), nonvar(B), C is A * B.
mul(A, B, C) :- nonvar(A), nonvar(C), B is C / A.
mul(A, B, C) :- nonvar(B), nonvar(C), A is C / B.

# mul/4
mul(A, B, C, D) :- nonvar(A), nonvar(B), nonvar(C), D is 0 - 1 * A * B + C.
mul(A, B, C, D) :- nonvar(A), nonvar(B), nonvar(D), C is A * B + D.
mul(A, B, C, D) :- nonvar(A), nonvar(C), nonvar(D), B is C - D / A.
mul(A, B, C, D) :- nonvar(B), nonvar(C), nonvar(D), A is C - D / B.
