import merosystem
import tty

proc keyboardHandler*(regs: ptr registers) {.exportc.}=
  #A neat little keyboard thing
  terminalWrite("Got a keyboard interrupt\n")
  var scancode: uint8 = inb(0x60)

  if (scancode and 0x80) != 0:
    #Got a keyrelease
    terminalWrite("Got scancode release: ")
    terminalWriteDecimal(scancode xor 0x80)
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

  discard """
  Why not just do this? It seems simpler, after all.

  installHandler(1, keyboardHandler)

  Well, enter one of my 'favorite' parts of working on this: compiler bugs
  https://github.com/nim-lang/Nim/issues/3708
  """

  terminalWrite("Keyboard handler installed...\n")
