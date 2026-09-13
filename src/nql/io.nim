# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/io.nim
#
import database, term

proc write*(db: Database, args: seq[Term], s: Subst) =
  let t = walk(args[0], s)
  stdout.write($t)
  flushFile(stdout)

proc writeln*(db: Database, args: seq[Term], s: Subst) =
  let t = walk(args[0], s)
  echo $t
