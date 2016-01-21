import merosystem, tty

#cstrings for now because nim strings are apparently a pain
var exceptionMessages {.noinit.}: array[0..31, cstring]

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
"""}

proc getIsr(i: int): uint32 =
  {.emit: """
  switch(`i`) {
  case 0:
    `result` = isr0;
    break;
  case 1:
    `result` = isr1;
    break;
  case 2:
    `result` = isr2;
    break;
  case 3:
    `result` = isr3;
    break;
  case 4:
    `result` = isr4;
    break;
  case 5:
    `result` = isr5;
    break;
  case 6:
    `result` = isr6;
    break;
  case 7:
    `result` = isr7;
    break;
  case 8:
    `result` = isr8;
    break;
  case 9:
    `result` = isr9;
    break;
  case 10:
    `result` = isr10;
    break;
  case 11:
    `result` = isr11;
    break;
  case 12:
    `result` = isr12;
    break;
  case 13:
    `result` = isr13;
    break;
  case 14:
    `result` = isr14;
    break;
  case 15:
    `result` = isr15;
    break;
  case 16:
    `result` = isr16;
    break;
  case 17:
    `result` = isr17;
    break;
  case 18:
    `result` = isr18;
    break;
  case 19:
    `result` = isr19;
    break;
  case 20:
    `result` = isr20;
    break;
  case 21:
    `result` = isr21;
    break;
  case 22:
    `result` = isr22;
    break;
  case 23:
    `result` = isr23;
    break;
  case 24:
    `result` = isr24;
    break;
  case 25:
    `result` = isr25;
    break;
  case 26:
    `result` = isr26;
    break;
  case 27:
    `result` = isr27;
    break;
  case 28:
    `result` = isr28;
    break;
  case 29:
    `result` = isr29;
    break;
  case 30:
    `result` = isr30;
    break;
  case 31:
    `result` = isr31;
  }
  """}

#TODO: Write copyString or genericAssign

proc isrsInstall*() =
  for i in 0..31:
    idtSetGate(cast[uint8](i), getIsr(i), 0x08, 0x8E)
  exceptionMessages[0] = "Division by zero!\0"
  exceptionMessages[1] = "Debug!\0"
  exceptionMessages[2] = "Non maskable interrupt!\0"
  exceptionMessages[3] = "INT 3!\0"
  exceptionMessages[4] = "INTO!\0"
  exceptionMessages[5] = "Out of Bounds!\0"
  exceptionMessages[6] = "Bad opcode!\0"
  exceptionMessages[7] = "Co-processor unavailable!\0"
  exceptionMessages[8] = "Double Fault!\0"
  exceptionMessages[9] = "Co-processor segment overrun!\0"
  exceptionMessages[10] = "Bad TSS!\0"
  exceptionMessages[11] = "Segment not present!\0"
  exceptionMessages[12] = "Stack fault!\0"
  exceptionMessages[13] = "General Protection Fault!\0"
  exceptionMessages[14] = "Page fault!\0"
  exceptionMessages[15] = "Reserved!\0"
  exceptionMessages[16] = "Floating point exception!\0"
  exceptionMessages[17] = "Alignment Check!\0"
  exceptionMessages[18] = "Machine Check!\0"
  exceptionMessages[19] = "Reserved!\0"
  exceptionMessages[20] = "Reserved!\0"
  exceptionMessages[21] = "Reserved!\0"
  exceptionMessages[22] = "Reserved!\0"
  exceptionMessages[23] = "Reserved!\0"
  exceptionMessages[24] = "Reserved!\0"
  exceptionMessages[25] = "Reserved!\0"
  exceptionMessages[26] = "Reserved!\0"
  exceptionMessages[27] = "Reserved!\0"
  exceptionMessages[28] = "Reserved!\0"
  exceptionMessages[29] = "Reserved!\0"
  exceptionMessages[30] = "Reserved!\0"
  exceptionMessages[31] = "Reserved!\0"

proc fault_handler(regs: ptr registers){.exportc.} =
  #Handle isr

  #If it's an exception...
  if regs.int_no < 32:
    #Halt and notify the user
    terminalWrite("\n================================================================================")
    terminalWrite("Got exception ")
    terminalWriteDecimal(regs.int_no)
    terminalWrite(": ")
    terminalWrite(exceptionMessages[regs.int_no])
    terminalWrite("\n")
    terminalWrite("================================================================================")
    writeRegisters(regs)
    panic("EXCEPTION!!!!")
