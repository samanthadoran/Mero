import tty
import vga
import descriptor_tables
import isr

proc kernel_early() {.exportc.} =
  terminalInitialize()

proc kernel_main() {.exportc.} =
  terminalWrite("Hello, world!\n")
  inc(terminalRow)
  terminalColumn = 0
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing, 123...\n")

  init_descriptor_tables()

  asm """
  int $0x3
  """
