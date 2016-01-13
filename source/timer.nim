import merosystem
import tty
import irq

var ticks: uint32 = 0
var seconds: uint32 = 0

proc setPhase(hz: int) =
  #How many times a second should the clock tick?
  let divisor = 1193180 div hz

  outb(0x43, cast[uint8](0x36))
  outb(0x40, cast[uint8](divisor and 0xFF))
  outb(0x40, cast[uint8](divisor shr 8))

proc timerHandler*(regs: ptr registers) {.exportc.}=
  #A neat little timekeeper
  inc(ticks)
  if ticks mod 18 == 0:
    inc(seconds)
    terminalWrite("The system has been up for ")
    terminalWriteDecimal(seconds)
    terminalWrite(" seconds.\n")

proc timerInstall*(hz: int = 18) =
  #setPhase(hz)
  {.emit: """
	installHandler(((unsigned int) 0), `timerHandler`);
  """}
  terminalWrite("Timer handler installed...\n")
