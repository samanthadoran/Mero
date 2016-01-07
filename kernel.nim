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
  terminalSetColor(makeVGAAttribute(Green, Black))
  for i in 0..21:
    terminalWrite("Recurse Center: Never Graduate!\n")

  #asm """
  #int $0x3
  #"""
