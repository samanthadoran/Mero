import tty
import idt, gdt
import memory
import asmwrapper

export idt, gdt
export memory
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
  terminalWriteHex(regs.gs)
  terminalWrite("     ")

  terminalWrite("fs: ")
  terminalWriteHex(regs.fs)
  terminalWrite("     ")

  terminalWrite("es: ")
  terminalWriteHex(regs.es)
  terminalWrite("\n")

  terminalWrite("ds: ")
  terminalWriteHex(regs.ds)
  terminalWrite("     ")

  terminalWrite("edi: ")
  terminalWriteHex(regs.edi)
  terminalWrite("     ")

  terminalWrite("esi: ")
  terminalWriteHex(regs.esi)
  terminalWrite("\n")

  terminalWrite("ebp: ")
  terminalWriteHex(regs.ebp)
  terminalWrite("     ")

  terminalWrite("esp: ")
  terminalWriteHex(regs.esp)
  terminalWrite("     ")

  terminalWrite("ebx: ")
  terminalWriteHex(regs.ebx)
  terminalWrite("\n")

  terminalWrite("edx: ")
  terminalWriteHex(regs.edx)
  terminalWrite("     ")

  terminalWrite("ecx: ")
  terminalWriteHex(regs.ecx)
  terminalWrite("     ")

  terminalWrite("eax: ")
  terminalWriteHex(regs.eax)
  terminalWrite("\n")

  terminalWrite("int_no: ")
  terminalWriteHex(regs.int_no)
  terminalWrite("     ")

  terminalWrite("err_code: ")
  terminalWriteHex(regs.err_code)
  terminalWrite("     ")

  terminalWrite("eip: ")
  terminalWriteHex(regs.eip)
  terminalWrite("\n")

  terminalWrite("cs: ")
  terminalWriteHex(regs.cs)
  terminalWrite("     ")

  terminalWrite("eflags: ")
  terminalWriteHex(regs.eflags)
  terminalWrite("     ")

  terminalWrite("useresp: ")
  terminalWriteHex(regs.useresp)
  terminalWrite("\n")

  terminalWrite("ss: ")
  terminalWriteHex(regs.ss)
  terminalWrite("\n")
