import merosystem
import tty
import irq

var ticks {.volatile.}: uint32 = 0
var seconds: uint32 = 0
var minutes: uint32 = 0

proc setPhase(frequency: uint16) =
  #How many times a second should the clock tick?
  #let divisor = 1193180 div frequency
  let divisor: uint16 = cast[uint16](cast[uint32](1193180) div frequency)

  outb(0x43, cast[uint8](0x36))
  outb(0x40, cast[uint8](divisor and 0xFF))
  outb(0x40, cast[uint8](divisor shr 8) and 0xFF)

proc wait*(ticksToWait: uint32) =
  let tickToWaitFor = ticks + ticksToWait
  while ticks < tickToWaitFor:
    {.emit: """
    __asm__ __volatile__ ("sti//hlt//cli");
    """}

proc writeUptime() =
  let terminalColumnOld = terminalColumn
  let terminalRowOld = terminalRow
  terminalRow = 24
  terminalColumn = 60
  terminalWrite("UPTIME: ")
  terminalWriteDecimal(minutes)
  terminalWrite(":")
  if seconds mod 60 < 10:
    terminalWriteDecimal(0)
  terminalWriteDecimal(seconds mod 60)
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

proc timerInstall*(frequency: uint16 = 18) =
  #setPhase(frequency)
  {.emit: """
	installHandler(((unsigned int) 0), `timerHandler`);
  """}

  discard """
  Why not just do this? It seems simpler, after all.

  installHandler(0, timerHandler)

  Well, enter one of my 'favorite' parts of working on this: compiler bugs
  https://github.com/nim-lang/Nim/issues/3708
  """
