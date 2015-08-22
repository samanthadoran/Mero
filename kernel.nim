import tty
import unsigned
proc kernel_early() {.exportc.} =
  terminalInitialize()

proc kernel_main() {.exportc.} =
  terminalWrite("Hello, world!\n")
  for i in 0..<len("asdf"):
    terminalPutChar("asdf"[i])
