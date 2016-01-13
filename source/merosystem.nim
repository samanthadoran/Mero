import tty
import idt, gdt
import memset, memcpy
import asmwrapper

export idt, gdt
export memset, memcpy
export asmwrapper


type
  registers* = object
    #Data selector
    gs*, fs*, es*, ds*: uint32

    #Extended registers
    edi*, esi*, ebp*, esp*, ebx*, edx*, ecx*, eax*: uint32

    #Pushed by push byte
    int_no*, err_code*: uint32

    #Pushed by iret
    eip*, cs*, eflags*, useresp*, ss*: uint32

proc writeRegisters*(regs: ptr registers){.exportc.} =
  #Annoying function to visually debug the register stack frame from irqs and isrs
  terminalWrite("gs: ")
  terminalWriteDecimal(regs.gs)
  terminalWrite("\n")

  terminalWrite("fs: ")
  terminalWriteDecimal(regs.fs)
  terminalWrite("     ")

  terminalWrite("es: ")
  terminalWriteDecimal(regs.es)
  terminalWrite("\n")

  terminalWrite("ds: ")
  terminalWriteDecimal(regs.ds)
  terminalWrite("     ")

  terminalWrite("edi: ")
  terminalWriteDecimal(regs.edi)
  terminalWrite("\n")

  terminalWrite("esi: ")
  terminalWriteDecimal(regs.esi)
  terminalWrite("     ")

  terminalWrite("ebp: ")
  terminalWriteDecimal(regs.ebp)
  terminalWrite("\n")

  terminalWrite("esp: ")
  terminalWriteHex(regs.esp)
  terminalWrite("     ")

  terminalWrite("ebx: ")
  terminalWriteDecimal(regs.ebx)
  terminalWrite("\n")

  terminalWrite("edx: ")
  terminalWriteDecimal(regs.edx)
  terminalWrite("     ")

  terminalWrite("ecx: ")
  terminalWriteDecimal(regs.ecx)
  terminalWrite("\n")

  terminalWrite("eax: ")
  terminalWriteDecimal(regs.eax)
  terminalWrite("     ")

  terminalWrite("int_no: ")
  terminalWriteDecimal(regs.int_no)
  terminalWrite("\n")

  terminalWrite("err_code: ")
  terminalWriteDecimal(regs.err_code)
  terminalWrite("     ")

  terminalWrite("eip: ")
  terminalWriteDecimal(regs.eip)
  terminalWrite("\n")

  terminalWrite("cs: ")
  terminalWriteDecimal(regs.cs)
  terminalWrite("     ")

  terminalWrite("eflags: ")
  terminalWriteDecimal(regs.eflags)
  terminalWrite("\n")

  terminalWrite("useresp: ")
  terminalWriteDecimal(regs.useresp)
  terminalWrite("     ")

  terminalWrite("ss: ")
  terminalWriteDecimal(regs.ss)
  terminalWrite("\n")
