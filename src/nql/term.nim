# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/term.nim
#
import std/[strutils, sequtils]

type
  TermKind* = enum
    tkAtom, tkVar, tkCompound, tkInt, tkString

  Term* = ref object
    case kind*: TermKind
    of tkAtom, tkVar:
      name*: string
    of tkInt:
     val*: int
    of tkString:
     text*: string
    of tkCompound:
      functor*: string
      args*: seq[Term]

# Term constructors.
proc atom*(name: string): Term = Term(kind: tkAtom, name: name)
proc v*(name: string): Term = Term(kind: tkVar, name: name)
proc number*(val: int): Term = Term(kind: tkInt, val: val)
proc text*(val: string): Term = Term(kind: tkString, text: val)
proc compound*(functor: string, args: openArray[Term]): Term =
  Term(kind: tkCompound, functor: functor, args: @args)

# Return the term as a string (for display).
proc `$`*(t: Term): string =
  case t.kind
  of tkAtom:
    if t.name.anyIt(it in {' ', '\t', '\r', '\n', '(', ')', ',', '.', ':', '-' }):
      "'" & t.name & "'"
    else:
      t.name
  of tkVar: t.name
  of tkInt: $t.val
  of tkString: t.text
  of tkCompound:
    if t.functor == "." and t.args.len == 2:
      # Affichage des listes [a, b, c] ou [a, b | T]
      var items: seq[string] = @[]
      var cur = t
      while cur.kind == tkCompound and cur.functor == "." and cur.args.len == 2:
        items.add($cur.args[0])
        cur = cur.args[1]
      if cur.kind == tkAtom and cur.name == "[]":
        "[" & items.join(", ") & "]"
      else:
        "[" & items.join(", ") & "|" & $cur & "]"
    elif t.args.len == 2 and t.functor in ["+", "-", "*", "is"]:
      $t.args[0] & " " & t.functor & " " & $t.args[1]
    else:
      t.functor & "(" & t.args.mapIt($it).join(", ") & ")"
