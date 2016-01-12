{.emit: """
typedef unsigned int   u32int;
typedef          int   s32int;
typedef unsigned short u16int;
typedef          short s16int;
typedef unsigned char  u8int;
typedef          char  s8int;
"""}

proc memset*(begin: ptr uint8, value: uint8, size: uint32) {.exportc} =
  {.emit: """
  u8int * tmp = `begin`;
  u32int len = `size`;
  for(; len != 0; len--)
    *tmp = `value`;
  """}
  return
