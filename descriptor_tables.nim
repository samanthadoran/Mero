type
  gdt_entry* = object {.packed.}
    limit_low*: uint16
    base_low*: uint16
    base_middle*: uint8
    access*: uint8
    granularity*: uint8
    base_high*: uint8
  idt_entry* = object {.packed.}
    base_low*: uint16
    sel: uint16
    always0: uint8
    flags: uint8
    base_hi: uint8

  gdt* = object {.packed.}
    limit*: uint16
    base*: uint32

  idt* = object {.packed}
    limit*: uint16
    base*: uint32

  gdt_ptr_t* = ptr gdt
  idt_ptr_t* = ptr idt

var gdt_ptr: gdt_ptr_t
var idt_ptr: idt_ptr_t

var gdt_entries: array[0 .. 5, gdt_entry]

#Forgive me for this, I just couldn't figure it out
{.emit: """
extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr16();
extern void isr17();
extern void isr18();
extern void isr19();
extern void isr20();
extern void isr21();
extern void isr22();
extern void isr23();
extern void isr24();
extern void isr25();
extern void isr26();
extern void isr27();
extern void isr28();
extern void isr29();
extern void isr30();
extern void isr31();

extern void gdt_flush(u32int);
"""}

proc probe_isr(isr: int) =
  {.emit: """
  switch(`isr`) {
    case 0:
      isr0();
      break;
    case 1:
      isr1();
      break;
    case 2:
      isr2();
      break;
    case 3:
      isr3();
      break;
    case 4:
      isr4();
      break;
    case 5:
      isr5();
      break;
    case 6:
      isr6();
      break;
    case 7:
      isr7();
      break;
    case 8:
      isr8();
      break;
    case 9:
      isr9();
      break;
    case 10:
      isr10();
      break;
    case 11:
      isr11();
      break;
    case 12:
      isr12();
      break;
    case 13:
      isr13();
      break;
    case 14:
      isr14();
      break;
    case 15:
      isr15();
      break;
    case 16:
      isr16();
      break;
    case 17:
      isr17();
      break;
    case 18:
      isr18();
      break;
    case 19:
      isr19();
      break;
    case 20:
      isr20();
      break;
    case 21:
      isr22();
      break;
    case 22:
      isr22();
      break;
    case 23:
      isr23();
      break;
    case 24:
      isr24();
      break;
    case 25:
      isr25();
      break;
    case 26:
      isr26();
      break;
    case 27:
      isr27();
      break;
    case 28:
      isr28();
      break;
    case 29:
      isr29();
      break;
    case 30:
      isr30();
      break;
    case 31:
      isr31();
      break;
  }
  """}

proc gdt_flush(gdt_ptr: gdt_ptr_t) =
  {.emit: """
  gdt_flush(&`gdt_ptr`)
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
  gdt_flush(gdt_ptr)

proc init_idt() =
  discard

proc init_descriptor_tables() =
  init_gdt()
  #init_idt()
