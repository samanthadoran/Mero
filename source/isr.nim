import tty
import vga

type
  registers* = object {.packed.}
    ds*: uint32
    edi*: uint32
    esi*: uint32
    ebp*: uint32
    esp*: uint32
    ebx*: uint32
    edx*: uint32
    ecx*: uint32
    eax*: uint32
    int_no*: uint32
    err_code*: uint32
    eip*: uint32
    cs*: uint32
    eflags*: uint32
    useresp*: uint32
    ss*: uint32

var i: int = 0

#TODO: This doesn't always work, sometimes it seems to be repeatedly called
proc isr_handler (regs: registers) {.exportc.} =
  if i mod 2 == 0:
    terminalWrite("Received interrupt: ")
    terminalWriteDecimal((regs.int_no))
    terminalWrite("\n")
  else:
    terminalWrite("Received interrupt: ")
    terminalWriteDecimal((regs.int_no))
    terminalWrite("\n")
  inc(i)
