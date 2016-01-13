proc outb*(port: uint16, value: uint8) =
  {.emit: """
  __asm__ __volatile__ ("outb %1, %0" : : "dN" (`port`), "a" (`value`));
  """}

proc inb*(port: uint16): uint8 =
  asm """
  inb %%dx, %%al
  :"=a" (`result`)
  :"d" (`port`)
  """
