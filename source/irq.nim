import merosystem
import memset

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
  return result

var irq_routines: array[0..15, proc(regs: registers)]

proc installHandler*(irq: int, handler: proc(r: registers)) =
  irq_routines[irq] = handler

proc uninstallHandler*(irq: int) =
  irq_routines[irq] = nil

proc irqRemap() =
  outb(0x20, 0x11);
  outb(0xA0, 0x11);
  outb(0x21, 0x20);
  outb(0xA1, 0x28);
  outb(0x21, 0x04);
  outb(0xA1, 0x02);
  outb(0x21, 0x01);
  outb(0xA1, 0x01);
  outb(0x21, 0x0);
  outb(0xA1, 0x0);

proc irqInstall*() =
  for i in 0..15:
    uninstallHandler(i)

  irqRemap()

  for i in 0..15:
    idtSetGate(cast[uint8](32 + i), getIrq(i), 0x08, 0x8E)

proc irqHandler*(regs: registers) {.exportc: "irq_handler"} =
  let irqIndex: uint32 = regs.int_no - 32
  var handler = irq_routines[irqIndex]
  if handler != nil:
    handler(regs)

  if regs.int_no >= cast[uint32](40):
    outb(0xA0, 0x20)
  outb(0x20, 0x20)
