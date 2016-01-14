type
  gdt_entry = object {.packed.}
    limit_low*: uint16
    base_low*: uint16
    base_middle*: uint8
    access*: uint8
    granularity*: uint8
    base_high*: uint8

  gdt_ptr = object {.packed.}
    limit*: uint16
    base*: uint32

var gdt: array[0..2, gdt_entry]
var gp {.exportc.}: gdt_ptr

#Declared in boot.s
proc gdtFlush() {.importc: "gdt_flush".}

proc gdtSetGate(num: int, base: uint32, limit: uint32, access: uint8, gran: uint8) =
  gdt[num].base_low = base and 0xFFFF
  gdt[num].base_middle = (base shr 16) and 0xFF
  gdt[num].base_high = (base shr 24) and 0xFF

  gdt[num].limit_low = limit and 0xFFFF
  gdt[num].granularity = (limit shr 16) and 0x0F

  gdt[num].granularity = gdt[num].granularity or (gran and 0xF0)
  gdt[num].access = access

proc gdtInstall*() =
  #Set the gdt pointer and limit
  gp.limit = cast[uint16]((sizeof(gdt_entry) * 3) - 1)
  gp.base = cast[uint32](addr(gdt))

  #Init null descriptor
  gdtSetGate(0, 0, 0, 0, 0)

  #Init code segment
  gdtSetGate(1, 0, cast[uint32](0xFFFFFFFF), 0x9A, 0xCF)

  #Init data segment
  gdtSetGate(2, 0, cast[uint32](0xFFFFFFFF), 0x92, 0xCF)

  gdtFlush()
