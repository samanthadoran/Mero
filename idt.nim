type
  IDTEntry = tuple
    baselo: uint16
    sel: uint16
    zero: uint8
    flags: uint8
    basehi: uint16

proc interruptHandler() =
  discard
