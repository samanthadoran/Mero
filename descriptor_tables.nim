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
    sel*: uint16
    always0*: uint8
    flags*: uint8
    base_high*: uint8

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
var idt_entries: array[0 .. 255, idt_entry]

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
extern void idt_flush(u32int);
"""}

proc getISR(isr: int): uint32 =
  {.emit: """
  switch(`isr`) {
    case 0:
      return (u32int)isr0;
      break;
    case 1:
      return (u32int)isr1;
      break;
    case 2:
      return (u32int)isr2;
      break;
    case 3:
      return (u32int)isr3;
      break;
    case 4:
      return (u32int)isr4;
      break;
    case 5:
      return (u32int)isr5;
      break;
    case 6:
      return (u32int)isr6;
      break;
    case 7:
      return (u32int)isr7;
      break;
    case 8:
      return (u32int)isr8;
      break;
    case 9:
      return (u32int)isr9;
      break;
    case 10:
      return (u32int)isr10;
      break;
    case 11:
      return (u32int)isr11;
      break;
    case 12:
      return (u32int)isr12;
      break;
    case 13:
      return (u32int)isr13;
      break;
    case 14:
      return (u32int)isr14;
      break;
    case 15:
      return (u32int)isr15;
      break;
    case 16:
      return (u32int)isr16;
      break;
    case 17:
      return (u32int)isr17;
      break;
    case 18:
      return (u32int)isr18;
      break;
    case 19:
      return (u32int)isr19;
      break;
    case 20:
      return (u32int)isr20;
      break;
    case 21:
      return (u32int)isr22;
      break;
    case 22:
      return (u32int)isr22;
      break;
    case 23:
      return (u32int)isr23;
      break;
    case 24:
      return (u32int)isr24;
      break;
    case 25:
      return (u32int)isr25;
      break;
    case 26:
      return (u32int)isr26;
      break;
    case 27:
      return (u32int)isr27;
      break;
    case 28:
      return (u32int)isr28;
      break;
    case 29:
      return (u32int)isr29;
      break;
    case 30:
      return (u32int)isr30;
      break;
    case 31:
      return (u32int)isr31;
      break;
  }
  """}

proc gdt_flush(gdt_ptr: gdt_ptr_t) =
  {.emit: """
  gdt_flush(&(u32int)`gdt_ptr`)
  """}

proc idt_flush(idt_ptr: idt_ptr_t) =
  {.emit: """
  idt_flush(&(u32int)`gdt_ptr`)
  """}

proc gdt_set_gate(num: int32, base: uint32, limit: uint32, access: uint8, gran: uint8) =
  gdt_entries[num].base_low = (base and 0xFFFF)
  gdt_entries[num].base_middle = (base shr 16) and 0xFF
  gdt_entries[num].base_high = (base shr 24) and 0xFF

  gdt_entries[num].limit_low = limit and 0xFFFF
  gdt_entries[num].granularity = (limit shr 16) and 0xFF

  gdt_entries[num].granularity = (gdt_entries[num].granularity) or (gran and 0xF0)
  gdt_entries[num].access = access

proc idt_set_gate(num: uint8, base: uint32, sel: uint16, flags: uint8) =
  idt_entries[num].base_low = (base and 0xFFFF)
  idt_entries[num].base_high = cast[uint8]((base shr 16) and 0xFFFF)

  idt_entries[num].sel = sel
  idt_entries[num].always0 = 0

  #An or will be added here when going to user mode
  idt_entries[num].flags = flags

proc init_idit() =
  idt_ptr.limit = cast[uint16](sizeof(idt_entry) * 256) - 1
  idt_ptr.base = cast[uint32](addr(idt_entries))

  #A lack of memset makes me sad.
  for i in 0 .. < len(idt_entries):
    idt_entries[i].base_low = 0
    idt_entries[i].sel = 0
    idt_entries[i].always0 = 0
    idt_entries[i].flags = 0
    idt_entries[i].base_high = 0

  for i in 0..31:
    idt_set_gate(cast[uint8](i), getISR(i) , cast[uint16](0x08), cast[uint8](0x8E))

  idt_flush(idt_ptr)

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
  init_idt()
