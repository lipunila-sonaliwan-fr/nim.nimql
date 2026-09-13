# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/engine.nim
#
import std/[tables, strutils, sequtils, os, linenoise]
import database, term, rule, parser, solver, io

let (path, name, _) = splitFile(paramStr(0))
let startupFile = path & "/" & name & ".ql"

proc loadFile*(path: string, db: var Database)

proc init*(db: var Database) =
  if fileExists(startupFile):
    loadFile(startupFile, db)

proc executeQuery*(db: Database, queryString: string) =
  var idx = 0
  try:
    let queryGoal = parseTerm(queryString, idx)
    let solutions = solve(db, @[queryGoal])

    if solutions.len == 0:
      echo "false."
    else:
      for sol in solutions:
        var hasVars = false
        for k, valTerm in sol:
          if not k.contains("_"):
            hasVars = true
            echo "  ", k, " = ", walk(valTerm, sol)
        if not hasVars:
          echo "true."
  except Exception as e:
    echo "Erreur : ", e.msg

proc executeCommand*(db: var Database, rawInput: string) =
  var input = rawInput.strip()

  if input.len == 0:
    return
  elif input in ["exit", "quit"]:
    return

  elif input.startsWith("consult"):
    var arg = input[7..^1].strip()
    if arg.endsWith("."):
      arg = arg[0..^2].strip()
    if arg.startsWith("(") and arg.endsWith(")"):
      arg = arg[1..^2].strip()
    let filePath = arg.strip(chars={'\'', '"', ' '})
    loadFile(filePath, db)
    return

  elif input == "list" or input.startsWith("list "):
    var domain = ""
    let parts = input.split(Whitespace, 1)
    if parts.len > 1:
      domain = parts[1].strip().strip(chars={'.', ';', '(', ')'})

    var count = 0
    for r in db:
      let headName = case r.head.kind
        of tkAtom: r.head.name
        of tkCompound: r.head.functor
        else: ""

      if domain == "" or headName == domain:
        let bodyStr = if r.body.len > 0: " :- " & r.body.mapIt($it).join(", ") else: ""
        echo "  ", r.head, bodyStr, "."
        inc count
    if count == 0:
      echo "No fact or rule found", (if domain != "": " for the domain '" & domain & "'" else: ""), "."
    return

  elif input.startsWith("kill "):
    let parts = input.split(Whitespace, 1)
    if parts.len > 1:
      let domain = parts[1].strip().strip(chars={'.', ';', '(', ')'})
      let initialLen = db.len
      db.keepItIf(
          case it.head.kind
            of tkAtom: it.head.name != domain
            of tkCompound: it.head.functor != domain
            else: false
      )
      let removed = initialLen - db.len
      echo "Deleted : ", removed, " fact(s) or rule(s) for the domain '", domain, "'."
    else:
      echo "Usage: kill <domain>"
    return

  elif input.startsWith("writeln"):
    var arg = input[7..^1].strip()
    if arg.endsWith("."):
      arg = arg[0..^2].strip()
    if arg.startsWith("(") and arg.endsWith(")"):
      var idx = 0
      io.writeln(db, parseArgs(arg, idx), initTable[string, Term]())
    else:
      echo "Syntax error : ", arg

  elif input.startsWith("write"):
    var arg = input[5..^1].strip()
    if arg.endsWith("."):
      arg = arg[0..^2].strip()
    if arg.startsWith("(") and arg.endsWith(")"):
      var idx = 0
      io.writeln(db, parseArgs(arg, idx), initTable[string, Term]())
    else:
      echo "Syntax error : ", arg

  elif input.startsWith("?"):
    var queryStr = input[1..^1].strip()
    if queryStr.startsWith("-"):
      queryStr = queryStr[1..^1].strip()
    executeQuery(db, queryStr)
  else:
    try:
      let r = parseRule(input)
      db.add(r)
      echo "Added : ", r.head, (if r.body.len > 0: " :- " & r.body.mapIt($it).join(", ") else: "")
    except Exception as e:
      echo "Syntax error : ", e.msg

proc loadFile*(path: string, db: var Database) =
  if path.len > 0 and fileExists(path):
    let content = readFile(path)
    var addedCount = 0
    for rawLine in content.splitLines():
      let line = rawLine.strip()
      if line.len > 0 and not line.startsWith("#"):
        if line.startsWith(":-"):
          let cmd = line[2..^1].strip()
          executeCommand(db, cmd)
        elif line.startsWith("?-"):
          var queryStr = line[2..^1].strip()
          if queryStr.endsWith("."):
            queryStr = queryStr[0..^2].strip()
          executeQuery(db, queryStr)
        else:
          db.add(parseRule(line))
          inc addedCount
    if path != startupFile:
      echo "File '", path, "' successfully accessed (", addedCount, " rules added)."
  else:
    echo "Error: the file '", path, "' does not exist or invalid path."
