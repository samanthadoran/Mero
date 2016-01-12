proc outb*(port: uint16, value: uint8) =
  {.emit: """
  asm volatile ( "outb %0, %1" : : "a"(`value`), "Nd"(`port`) );
  """}

proc inb*(port: uint16): uint8 =
  asm """
  inb %%dx, %%al
  :"=a" (`result`)
  :"d" (`port`)
  """
