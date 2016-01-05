import unsigned

type
  gdt_entry* = object {.packed.}
    limit_low*: uint16
    base_low*: uint16
    bae_middle*: uint8
    access*: uint8
    granularity*: uint8
    base_high*: uint8

  gdt* = object {.packed.}
    limit*: uint16
    base*: uint32

  gdt_ptr_t* = ptr gdt

var gdt_ptr: gdt_ptr_t

var gdt_entries: array[0 .. 5, gdt_entry]
