{.push stack_trace: off, profiler:off.}
import tty
import vga

proc rawoutput(s: string) =
  let terminalOldRow = terminalRow
  let terminalOldColumn = terminalColumn
  let terminalOldColor = terminalColor
  terminalSetColor(makeVGAAttribute(Red, White))
  terminalRow = 24
  terminalColumn = 0

  terminalWrite(s)

  terminalRow = terminalOldRow
  terminalColumn = terminalOldColumn
  terminalSetColor(terminalOldColor)

proc panic*(s: string) =
  rawoutput(s)
  while true:
    discard

{.pop.}
