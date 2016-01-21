import merosystem
import memory
import tty

{.emit: """
extern void irq0();
extern void irq1();
extern void irq2();
extern void irq3();
extern void irq4();
extern void irq5();
extern void irq6();
extern void irq7();
extern void irq8();
extern void irq9();
extern void irq10();
extern void irq11();
extern void irq12();
extern void irq13();
extern void irq14();
extern void irq15();
"""}

proc getIrq(i: int): uint32 =
  #Get the address of an irq
  {.emit: """
  switch(`i`) {
  case 0:
    `result` = irq0;
    break;
  case 1:
    `result` = irq1;
    break;
  case 2:
    `result` = irq2;
    break;
  case 3:
    `result` = irq3;
    break;
  case 4:
    `result` = irq4;
    break;
  case 5:
    `result` = irq5;
    break;
  case 6:
    `result` = irq6;
    break;
  case 7:
    `result` = irq7;
    break;
  case 8:
    `result` = irq8;
    break;
  case 9:
    `result` = irq9;
    break;
  case 10:
    `result` = irq10;
    break;
  case 11:
    `result` = irq11;
    break;
  case 12:
    `result` = irq12;
    break;
  case 13:
    `result` = irq13;
    break;
  case 14:
    `result` = irq14;
    break;
  case 15:
    `result` = irq15;
    break;
  }
  """}

#Store handlers for various irqs
var irq_routines: array[0..15, proc(regs: ptr registers)]

proc installHandler*(irq: int, handler: proc(r: ptr registers) = nil){.exportc.} =
  #Add a handler..
  {.emit: """
  `irq_routines`[`irq`] = `handler`;
  """}

proc uninstallHandler*(irq: int) =
  #Remove handler
  irq_routines[irq] = nil

proc irqRemap() =
  #Prevent irqs from overlapping on PIC
  outb(0x20, 0x11)
  outb(0xA0, 0x11)
  outb(0x21, 0x20)
  outb(0xA1, 0x28)
  outb(0x21, 0x04)
  outb(0xA1, 0x02)
  outb(0x21, 0x01)
  outb(0xA1, 0x01)
  outb(0x21, 0x00)
  outb(0xA1, 0x00)

proc irqInstall*() =
  #Lazily do this instead of memset
  for i in 0..15:
    uninstallHandler(i)

  #Remove conflicts with IRQ 0 - IRQ 8
  irqRemap()
  for i in 0..15:
    idtSetGate(cast[uint8](32 + i), getIrq(i), cast[uint16](0x08), cast[uint8](0x8E))

proc irqHandler*(regs: ptr registers) {.exportc: "irq_handler"} =
  #Handle various irqs

  #Subtract by 32 to take into account we remapped
  let irqIndex: uint32 = (regs.int_no) - 32

  #DO NOT DELETE NOINIT
  var handler{.noinit.}: proc(regs: ptr registers) = irq_routines[irqIndex]

  #If we have a handler, use it
  if handler != nil:
    handler(regs)

  #If the int_no we got is above 39, send a response to the slave pic on 0xA0
  if irqIndex + 32 >= cast[uint32](40):
    outb(0xA0, 0x20)

  #Either way, send a response to the master pic
  outb(0x20, 0x20)
