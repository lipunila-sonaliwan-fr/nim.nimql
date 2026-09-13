# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/parser.ql
#
import std/[parseutils, linenoise, ]
import term, rule

proc parseExpr*(code: string, idx: var int): Term

# Syntactic Parser
proc skipTrivia*(code: string, idx: var int) =
  while idx < code.len:
    if code[idx] in {' ', '\t', '\r', '\n'}:
      inc idx
    elif code[idx] == '#':
      while idx < code.len and code[idx] != '\n':
        inc idx
    else:
      break

# Parses a Prolog list: [], [a, b, c], or [Head | Tail]
# Internally, a list is represented by compound cells (".", [Head, Tail])
# and ends with the atom "[]".
proc parseList(code: string, idx: var int): Term =
  inc idx # Passer '['
  code.skipTrivia(idx)

  if idx < code.len and code[idx] == ']':
    inc idx
    return atom("[]")

  var elements: seq[Term] = @[]
  var tail = atom("[]")

  while true:
    code.skipTrivia(idx)
    elements.add(parseExpr(code, idx))
    code.skipTrivia(idx)

    if idx < code.len and code[idx] == ',':
      inc idx
      continue
    elif idx < code.len and code[idx] == '|':
      inc idx
      code.skipTrivia(idx)
      tail = parseExpr(code, idx)
      code.skipTrivia(idx)
    break

  if idx < code.len and code[idx] == ']':
    inc idx

  result = tail
  for i in countdown(elements.high, 0):
    result = compound(".", [elements[i], result])

proc parseArgs*(code: string, idx: var int): seq[Term] =
  result = @[]
  inc idx # Passer '('
  while idx < code.len:
    code.skipTrivia(idx)
    result.add(parseExpr(code, idx))
    code.skipTrivia(idx)
    if idx < code.len and code[idx] == ',': inc idx
    elif idx < code.len and code[idx] == ')':
      inc idx
      break

proc parseAtomOrCompound*(code: string, idx: var int): Term =
  code.skipTrivia(idx)
  var token = ""

  if idx < code.len and code[idx] == '[':
    return parseList(code, idx)

  if idx < code.len and code[idx] in {'0'..'9'}:
    var val = 0
    idx += code.parseInt(val, idx)
    return number(val)

  if idx < code.len and code[idx] == '\'':
    inc idx
    while idx < code.len and code[idx] != '\'':
      token.add(code[idx])
      inc idx
    if idx < code.len and code[idx] == '\'':
      inc idx
    return atom(token)

  if idx < code.len and code[idx] == '"':
    inc idx
    while idx < code.len and code[idx] != '"':
      token.add(code[idx])
      if code[idx] == '\\' and (idx + 1) < code.len and code[idx + 1] == '"':
        inc idx
        token.add(code[idx])
      inc idx

    if idx < code.len and code[idx] == '"':
      inc idx
    return text(token)

  if idx < code.len and code[idx] in {'A'..'Z', '_'}:
    while idx < code.len and code[idx] in {'a'..'z', 'A'..'Z', '0'..'9', '_'}:
      token.add(code[idx])
      inc idx
    return v(token)

  if idx < code.len and code[idx] in {'a'..'z'}:
    while idx < code.len and code[idx] in {'a'..'z', 'A'..'Z', '0'..'9', '_'}:
      token.add(code[idx])
      inc idx
    code.skipTrivia(idx)
    if idx < code.len and code[idx] == '(':
      let args = parseArgs(code, idx)
      return compound(token, args)
    return atom(token)

  raise newException(ValueError, "Erreur de syntaxe vers : " & code[idx..min(idx+10, code.high)])

proc parseExpr*(code: string, idx: var int): Term =
  var left = parseAtomOrCompound(code, idx)
  while true:
    code.skipTrivia(idx)
    if idx < code.len and code[idx] in {'+', '-', '*', '/', '%', '^'}:
      let op = $code[idx]
      inc idx
      let right = parseAtomOrCompound(code, idx)
      left = compound(op, [left, right])
    else:
      break
  return left

proc parseTerm*(code: string, idx: var int): Term =
  var left = parseExpr(code, idx)
  code.skipTrivia(idx)
  if idx + 2 <= code.len and code[idx..<idx+2] == "is":
    idx += 2
    let right = parseExpr(code, idx)
    return compound("is", [left, right])

  return left

proc parseRule*(line: string): Rule =
  var idx = 0
  let head = parseTerm(line, idx)
  line.skipTrivia(idx)

  if idx + 2 <= line.len and line[idx..<idx+2] == ":-":
    idx += 2
    var body: seq[Term] = @[]
    while idx < line.len and line[idx] != '.':
      body.add(parseTerm(line, idx))
      line.skipTrivia(idx)
      if idx < line.len and line[idx] == ',': inc idx
    return Rule(head: head, body: body)

  return Rule(head: head, body: @[])
