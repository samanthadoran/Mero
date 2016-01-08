import tty
import vga
import descriptor_tables
import isr

proc kernel_early() {.exportc.} =
  init_descriptor_tables()
  terminalInitialize()

proc kernel_main() {.exportc.} =
  terminalWrite("Hello, world!\n")
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing, 123...\n")
  terminalWrite("Testing decimal writing with 8675309: ")
  terminalWriteDecimal(8675309)
  terminalWrite("\n")
  terminalSetColor(makeVGAAttribute(Green, Black))

  #Test multiple interrupts
  asm """
  int $0x3
  int $0x4
  """

  #Did we properly return from interrupts
  terminalWrite("Recurse Center: Never Graduate!\n")
