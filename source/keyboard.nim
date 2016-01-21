import merosystem
import tty

proc scanCodeToAscii(scancode: uint8):char =
  case scancode
  of 0x00:
    return chr(0)
  of 14:
    return chr(8)
  of 16:
    return 'q'
  of 17:
    return 'w'
  of 18:
    return 'e'
  of 19:
    return 'r'
  of 20:
    return 't'
  of 21:
    return 'y'
  of 22:
    return 'u'
  of 23:
    return 'i'
  of 24:
    return 'o'
  of 25:
    return 'p'
  of 57:
    return ' '
  else:
    return chr(0)

proc keyboardHandler*(regs: ptr registers) {.exportc.}=
  #A neat little keyboard thing
  #terminalWrite("Got a keyboard interrupt\n")
  var scancode: uint8 = inb(0x60)

  if (scancode and 0x80) != 0:
    discard
    #Got a keyrelease
    #terminalWrite("Got scancode release: ")
    #terminalWriteDecimal(scancode xor 0x80)
    #terminalWrite("\n")
    #terminalWrite("Scancode equates to: ")
    #let character: char = scanCodeToAscii(scancode xor 0x80)
    #if ord(character) != 0:
    #  terminalPutChar(character)
    #else:
    #  terminalWrite("Unrecognized scancode...")
    #terminalWrite("\n")
  else:
    #terminalWrite("Got scancode push: ")
    #terminalWriteDecimal(scancode)
    #terminalWrite("\n")
    #terminalWrite("Scancode equates to: ")
    let character: char = scanCodeToAscii(scancode)
    if ord(character) != 0:
      terminalPutChar(character)
    else:
      terminalWrite("GOT DEBUG SIGNAL!!!\n")
      terminalWriteDecimal(1 div 0)
      terminalWrite("Unrecognized scancode...")
    #terminalWrite("\n")

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
