import tty
import vga
import merosystem, isrs, irq
import timer, keyboard

type
  TMultiboot_header = object
  PMultiboot_header = ptr TMultiboot_header

proc kernel_early() {.exportc.} =
  gdtInstall()
  idtInstall()
  isrsInstall()
  irqInstall()
  terminalInitialize()
  keyboardInstall()
  timerInstall()
  {.emit: """
  __asm__ __volatile__ ("sti");
  """}

proc kernel_main() {.exportc noReturn.} =
  terminalWrite("Initialized the terminal...\n")
  terminalWrite("Hello, world!\n")
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing colors...\n")

  terminalSetColor(makeVGAAttribute(Green, Black))
  terminalWrite("Testing decimal writing with 8675309: ")
  terminalWriteDecimal(8675309)
  terminalWrite("\n")

  terminalWrite("Testing hex writing with 0xDEADBEEF: ")
  terminalWriteHex(cast[uint](0xDEADBEEF))
  terminalWrite("\n")

  #Test the use of timer's wait function
  terminalSlowWrite("Slow it on dooooowwwwwnnnnn.....\n", 4)

  #terminalWrite("Testing div by 0: ")
  #terminalWriteDecimal(1 div 0)
  #terminalWrite("\n")

  while true:
    discard
