# CC BY-NC-SA 4.0 - jean-marc "jihem" quere 2026
# nql/rule.nim
#
import term

type
  Rule* = object
    head*: Term
    body*: seq[Term]
