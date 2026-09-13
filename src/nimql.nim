# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nimql.nim - Nim Query Language is similar to Prolog with CLI, REPL and .ql file support.
# nim c -r -d:release nimql.nim
import std/[strutils, os, linenoise]
import nql/[database, engine]

var caught = false
proc handler() {.noconv.} =
  stdout.write("\b\b  \b\b")
  flushFile(stdout)
  if caught:
    echo "\n"
    quit()
  else:
    caught = true

proc startRepl(db: var Database) =
  let historyFile = getHomeDir() / ".nimql_history"
  discard historyLoad((cstring)historyFile)

  while true:
    caught = false

    let linePtr = linenoise.readLine(" > ")

    if linePtr == nil:
      break

    let input = ($linePtr).strip()

    linenoise.free(linePtr)

    if input in ["exit", "quit"]:
      break
    if input.len == 0:
      continue

    discard historyAdd((cstring)input)
    discard historySave((cstring)historyFile)

    executeCommand(db, input)

proc main() =
  let args = commandLineParams()
  var db: Database = @[]

  echo "   _._                 "
  echo " o|- -|o    NimQL vß.3 "
  echo "  ( l )   sonaliwan.fr "
  echo "    =                  \n"

  setControlCHook(handler)
  engine.init(db)

  if args.len > 0:
    let filePath = args[0]
    if fileExists(filePath):
      loadFile(filePath, db)
    else:
      echo "Error: the file '", filePath, "' does not exist."
      quit(1)

  if args.len >= 2:
    executeQuery(db, args[1])
  else:
    startRepl(db)

when isMainModule:
  main()
