import tty
import vga
import unsigned

proc kernel_early() {.exportc.} =
  terminalInitialize()

proc kernel_main() {.exportc.} =
  terminalWrite("Hello, world!\n")
  inc(terminalRow)
  terminalColumn = 0
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing, 123...\n")
