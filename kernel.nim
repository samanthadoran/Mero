import tty

proc kernel_early() {.exportc} =
  terminalInitialize()

proc kernel_main() {.exportc.} =
  #terminalInitialize()
  terminalWrite("Hello, world!\n")
