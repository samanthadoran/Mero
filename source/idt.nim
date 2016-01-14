import memset

type
  idt_entry = object {.packed.}
    base_low*: uint16
    sel*: uint16
    always0*: uint8
    flags*: uint8
    base_high*: uint16

  idt_ptr = object {.packed}
    limit*: uint16
    base*: uint32

var idt: array[0..255, idt_entry]
var idtp {.exportc.}: idt_ptr

#Declared in boot.s
proc idtLoad() {.importc: "idt_load".}

proc idtSetGate*(num: uint8, base: uint32, sel: uint16, flags: uint8) =
  idt[num].base_low = base and 0xFFFF
  idt[num].base_high = (base shr 16) and 0xFFFF

  idt[num].sel = sel
  idt[num].always0 = 0
  idt[num].flags = flags

proc idtInstall*() =
  #Set the limit and base
  idtp.limit = cast[uint16](sizeof(idt) * 256) - 1
  idtp.base = cast[uint32](addr(idt))

  var ptr_idt: ptr uint8 = cast[ptr uint8](addr(idt))
  memset(ptr_idt, 0, cast[uint32](sizeof(idt_entry) * 256))

  #ISRs go here

  idtLoad()
