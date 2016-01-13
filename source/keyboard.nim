import merosystem
import tty

proc keyboardHandler*(regs: ptr registers) {.exportc.}=
  #A neat little keyboard thing
  terminalWrite("Got a keyboard interrupt\n")
  var scancode: uint8 = inb(0x60)

  if (scancode and 0x80) != 0:
    #Got a modifier key
    terminalWrite("Got scancode release: ")
    terminalWriteDecimal(scancode)
    terminalWrite("\n")
  else:
    terminalWrite("Got scancode push: ")
    terminalWriteDecimal(scancode)
    terminalWrite("\n")

proc keyboardInstall*() =
  #Install they keyboard handler on irq1
  {.emit: """
	installHandler(((unsigned int) 1), `keyboardHandler`);
  """}
  terminalWrite("Keyboard handler installed...\n")
