import tty
import vga
type
  registers* = object
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
proc isr_handler (regs: registers) {.exportc.} =
  if i mod 2 == 0:
    terminalWrite("received interrupt: even...\n")
  else:
    terminalWrite("received interrupt: odd...\n")
  inc(i)
