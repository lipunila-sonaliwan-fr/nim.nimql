# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# NimQL Startup
#

:- writeln("-- Startup --").
:- consult("std/list.ql").
:- consult('std/integer.ql').

# Tests
#:- writeln("-- Tests --").
#:- consult('tst/std.ql').
#:- consult('tst/family.ql').

:- writeln("").
:- writeln("Type '? query.' to evaluate a query.").
:- writeln("     'rule.' or 'fact.' to add it to the database.").
:- writeln("     'list [<domain>]' to list facts and rules.").
:- writeln("     'consult(\"file.ql\")' to load a file into memory.").
:- writeln("     'exit', 'quit', or [Ctrl]-[C] to quit.\n").
