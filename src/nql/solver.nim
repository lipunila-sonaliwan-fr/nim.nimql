# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/solver.nim
#
import std/[tables, sequtils]
import database, term, integer, boolean, io

# Scope & SLD Engine
var varCounter = 0
proc refreshVars*(t: Term, mapping: var Table[string, string]): Term =
  case t.kind
  of tkVar:
    if not mapping.hasKey(t.name):
      inc varCounter
      mapping[t.name] = t.name & "_" & $varCounter
    return v(mapping[t.name])
  of tkCompound:
    return compound(t.functor, t.args.mapIt(refreshVars(it, mapping)))
  else: return t

proc unify*(t1, t2: Term, s: var Subst): bool =
  let u1 = walk(t1, s)
  let u2 = walk(t2, s)

  if u1.kind == tkVar:
    if u2.kind != tkVar or u1.name != u2.name:
      s[u1.name] = u2
    return true
  if u2.kind == tkVar:
    s[u2.name] = u1
    return true

  if u1.kind == tkAtom and u2.kind == tkAtom: return u1.name == u2.name
  if u1.kind == tkInt and u2.kind == tkInt: return u1.val == u2.val

  if u1.kind == tkCompound and u2.kind == tkCompound:
    if u1.functor != u2.functor or u1.args.len != u2.args.len: return false
    for i in 0..<u1.args.len:
      if not unify(u1.args[i], u2.args[i], s): return false
    return true

  return false

proc solve*(db: Database, goals: seq[Term], s: Subst = initTable[string, Term]()): seq[Subst] =
  result = @[]
  if goals.len == 0: return @[s]

  let goal = goals[0]
  let rest = goals[1..^1]

  if goal.kind == tkCompound and goal.functor == "is":
    try:
      let val = eval(goal.args[1], s)
      var sCopy = s
      if unify(goal.args[0], number(val), sCopy):
        return solve(db, rest, sCopy)
    except ValueError:
      return @[]

  elif goal.kind == tkCompound and goal.functor in [ "eq",  "gt", "lt", "neq", "geq", "leq" ] and goal.args.len == 2:
    let bval =
      case goal.functor
        of "eq"  : isEQ(goal.args[0], goal.args[1], s)
        of "gt"  : isGT(goal.args[0], goal.args[1], s)
        of "lt"  : isLT(goal.args[0], goal.args[1], s)
        of "geq" : isGEQ(goal.args[0], goal.args[1], s)
        of "leq" : isLEQ(goal.args[0], goal.args[1], s)
        else: isNEQ(goal.args[0], goal.args[1], s)
    if bVal:
      return solve(db, rest, s)
    else:
      return @[]

  elif goal.kind == tkCompound and goal.functor == "nonvar" and goal.args.len == 1:
    if isNonVar(goal.args[0], s):
      return solve(db, rest, s)
    else:
      return @[]

  elif goal.kind == tkCompound and goal.functor == "var" and goal.args.len == 1:
    if isVar(goal.args[0], s):
      return solve(db, rest, s)
    else:
      return @[]

  elif goal.kind == tkCompound and goal.functor == "write" and goal.args.len == 1:
    io.write(db, goal.args, s)
    return solve(db, rest, s)

  elif goal.kind == tkCompound and goal.functor == "writeln" and goal.args.len == 1:
    io.writeln(db, goal.args, s)
    return solve(db, rest, s)

  for rule in db:
    var mapping = initTable[string, string]()
    let freshHead = refreshVars(rule.head, mapping)
    let freshBody = rule.body.mapIt(refreshVars(it, mapping))

    var sCopy = s
    if unify(goal, freshHead, sCopy):
      let nextGoals = freshBody & rest
      result.add(solve(db, nextGoals, sCopy))
