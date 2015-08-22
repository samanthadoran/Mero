import tty

proc kernel_main() {.exportc.} =
  terminalInitialize()
  terminalWrite("Hello, world!\n")
