# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/integer.nim
#
import std/math
import database, term

# Évaluation Arithmétique
proc eval*(t: Term, s: Subst): int =
  let walked = walk(t, s)
  case walked.kind
  of tkInt: return walked.val
  of tkCompound:
    if walked.args.len == 2:
      let left = eval(walked.args[0], s)
      let right = eval(walked.args[1], s)
      case walked.functor
      of "+": return left + right
      of "-": return left - right
      of "*": return left * right
      of "/": return left div right
      of "%": return left mod right
      of "^": return left ^ right
      else: discard
  else: discard
  raise newException(ValueError, "Erreur d'évaluation arithmétique sur : " & $walked)

proc isEQ*(t1, t2: Term, s: Subst): bool =
  let w1 = walk(t1, s)
  let w2 = walk(t2, s)
  return w1.kind == tkInt and w1.kind == w2.kind and w1.val == w2.val

proc isNEQ*(t1, t2: Term, s: Subst): bool =
  return not isEQ(t1, t2, s)

proc isGT*(t1, t2: Term, s: Subst): bool =
  let w1 = walk(t1, s)
  let w2 = walk(t2, s)
  return w1.kind == tkInt and w1.kind == w2.kind and w1.val > w2.val

proc isLT*(t1, t2: Term, s: Subst): bool =
  let w1 = walk(t1, s)
  let w2 = walk(t2, s)
  return w1.kind == tkInt and w1.kind == w2.kind and w1.val < w2.val

proc isGEQ*(t1, t2: Term, s: Subst): bool =
  let w1 = walk(t1, s)
  let w2 = walk(t2, s)
  return w1.kind == tkInt and w1.kind == w2.kind and w1.val >= w2.val

proc isLEQ*(t1, t2: Term, s: Subst): bool =
  let w1 = walk(t1, s)
  let w2 = walk(t2, s)
  return w1.kind == tkInt and w1.kind == w2.kind and w1.val <= w2.val
