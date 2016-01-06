type
  gdt_entry* = object {.packed.}
    limit_low*: uint16
    base_low*: uint16
    base_middle*: uint8
    access*: uint8
    granularity*: uint8
    base_high*: uint8

  gdt* = object {.packed.}
    limit*: uint16
    base*: uint32

  gdt_ptr_t* = ptr gdt



var gdt_ptr: gdt_ptr_t

var gdt_entries: array[0 .. 5, gdt_entry]

#Forgive me for this, I just couldn't figure it out
{.emit: """
extern void gdt_flush(u32int);
"""}

proc gdt_set_gate(num: int32, base: uint32, limit: uint32, access: uint8, gran: uint8) =
  gdt_entries[num].base_low = (base and 0xFFFF)
  gdt_entries[num].base_middle = (base shr 16) and 0xFF
  gdt_entries[num].base_high = (base shr 24) and 0xFF

  gdt_entries[num].limit_low = limit and 0xFFFF
  gdt_entries[num].granularity = (limit shr 16) and 0xFF

  gdt_entries[num].granularity = (gdt_entries[num].granularity) or (gran and 0xF0)
  gdt_entries[num].access = access

proc init_gdt() =
  gdt_ptr.limit = cast[uint16](sizeof(gdt_entry) * 5) - 1
  gdt_ptr.base = cast[uint32](addr(gdt_entries))
  gdt_set_gate(0, 0, 0, 0, 0)                # Null segment
  gdt_set_gate(1, 0, cast[uint32](0xFFFFFFFF), 0x9A, 0xCF) # Code segment
  gdt_set_gate(2, 0, cast[uint32](0xFFFFFFFF), 0x92, 0xCF) # Data segment
  gdt_set_gate(3, 0, cast[uint32](0xFFFFFFFF), 0xFA, 0xCF) # User mode code segment
  gdt_set_gate(4, 0, cast[uint32](0xFFFFFFFF), 0xF2, 0xCF) # User mode data segments))

  #I wishI could have found a more elegant solution than this kludge
  {.emit: """
  gdt_flush(&`gdt_ptr`);
  """}

proc init_descriptor_tables() =
  init_gdt()
