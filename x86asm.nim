proc outb*(port: uint16, value: uint8) =
  asm """
  outb %%al, %%dx
  :
  :"a"(`value`), "d"(`port`)
  """

proc inb*(port: uint16): uint8 =
  asm """
  inb %%al, %%dx
  :"=a"(`result`)
  :"d"(`port`)
  """
