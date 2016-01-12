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

{.emit: """
extern void idt_load();
"""}

proc idtLoad() =
  #Wrapper function for pesky asm calls
  {.emit: """
  idt_load();
  """}
  return

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

  #ISRs go here
  memset(cast[uint8](addr(idt)), 0, cast[uint32](sizeof(idt_entry) * 256))

  idtLoad()
