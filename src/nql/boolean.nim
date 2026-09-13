# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/boolean.nim
#

import database, term

# Checks whether a term resolved via s is still a variable.
proc isVar*(t: Term, s: Subst): bool =
  let walked = walk(t, s)
  return walked.kind == tkVar

# Inverse predicate: true if the term is NOT a free variable.
proc isNonVar*(t: Term, s: Subst): bool =
  return not isVar(t, s)
