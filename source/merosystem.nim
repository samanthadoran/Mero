import idt, gdt
import memset, memcpy
import asmwrapper

export idt, gdt
export memset, memcpy
export asmwrapper

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
