import merosystem
import tty

var ticks: uint32 = 0
var seconds: uint32 = 0

proc setPhase(hz: int) =
  let divisor = 1193180 div hz

  outb(0x43, 0x36)
  outb(0x40, divisor & 0xFF)
  outb(0x40, divisor shr 8)

proc timerHandler*(regs: registers) =
  inc(ticks)

  if ticks mod 18 == 0:
    inc(seconds)
    terminalWrite("The system has been up for ")
    terminalWriteDecimal(seconds)
    terminalWrite(" seconds.\n")

proc timerInstall*(hz: int) =
  if hz != 0:
    setPhase(hz)
  installHandler(0, timerHandler)
