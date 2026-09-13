# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/database.nim
#

import std/tables
import term, rule

type
  Subst* = Table[string, Term]
  Database* = seq[Rule]

# Unification and Substitution
proc walk*(t: Term, s: Subst): Term =
  if t.kind == tkVar and s.hasKey(t.name): return walk(s[t.name], s)
  return t
