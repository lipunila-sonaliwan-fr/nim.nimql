#
# tst/family.ql
#

# Load parent relationships.
:- consult("tst/parent.ql").

# Add genders and rules.
sex(sarah, female).
sex(mary, female).
sex(peter, male).
sex(john, male).
grandparent(X, Y) :- parent(X, Z), parent(Z, Y).
grandmother(X, Y) :- grandparent(X, Y), sex(X, female).
grandfather(X, Y) :- grandparent(X, Y), sex(X, male).
