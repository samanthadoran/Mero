import merosystem
import tty
import irq

var ticks {.volatile.}: uint32 = 0
var seconds: uint32 = 0
var minutes: uint32 = 0

proc setPhase(hz: int) =
  #How many times a second should the clock tick?
  let divisor = 1193180 div hz

  outb(0x43, cast[uint8](0x36))
  outb(0x40, cast[uint8](divisor and 0xFF))
  outb(0x40, cast[uint8](divisor shr 8))

proc wait*(ticksToWait: uint32) =
  let tickToWaitFor = ticks + ticksToWait
  while ticks < tickToWaitFor:
    {.emit: """
    __asm__ __volatile__ ("sti//hlt//cli");
    """}

proc writeUptime() =
  let terminalColumnOld = terminalColumn
  let terminalRowOld = terminalRow
  terminalRow = 23
  terminalColumn = 60
  terminalWrite("UPTIME: ")
  terminalWriteDecimal(minutes)
  terminalWrite(":")
  if seconds mod 60 < 10:
    terminalWriteDecimal(0)
  terminalWriteDecimal(seconds mod 60)
  terminalWrite("\n")
  terminalRow = terminalRowOld
  terminalColumn = terminalColumnOld
  moveCursor(terminalColumn, terminalRow)

proc timerHandler*(regs: ptr registers) {.exportc.}=
  #A neat little timekeeper
  inc(ticks)
  if ticks mod 18 == 0:
    inc(seconds)
    if seconds mod 60 == 0:
      inc(minutes)
  writeUptime()

proc timerInstall*(hz: int = 18) =
  #setPhase(hz)
  {.emit: """
	installHandler(((unsigned int) 0), `timerHandler`);
  """}

  discard """
  Why not just do this? It seems simpler, after all.

  installHandler(0, timerHandler)

  Well, enter one of my 'favorite' parts of working on this: compiler bugs
  https://github.com/nim-lang/Nim/issues/3708
  """

  terminalWrite("Timer handler installed...\n")
