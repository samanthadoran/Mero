import tty
import vga
import descriptor_tables
import isr

proc kernel_early() {.exportc.} =
  terminalInitialize()
  terminalWrite("Initialized the terminal...\n")
  init_descriptor_tables()
  terminalWrite("Initialized the descriptor tables...\n")

proc kernel_main() {.exportc.} =
  terminalWrite("Hello, world!\n")
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing, 123...\n")
  terminalWrite("Testing decimal writing with 8675309: ")
  terminalWriteDecimal(8675309)
  terminalWrite("\n")
  terminalWrite("Testing hex writing with 0xDEADBEEF: ")
  terminalWriteHex(cast[uint](0xDEADBEEF))
  terminalWrite("\n")
  terminalSetColor(makeVGAAttribute(Green, Black))

  #Test multiple interrupts
  asm """
  int $0x4
  int $0x0
  """

  #Did we properly return from interrupts
  terminalWrite("Recurse Center: Never Graduate!\n")
