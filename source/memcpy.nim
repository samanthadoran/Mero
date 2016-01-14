{.emit: """
typedef unsigned int   u32int;
typedef          int   s32int;
typedef unsigned short u16int;
typedef          short s16int;
typedef unsigned char  u8int;
typedef          char  s8int;
"""}

proc memcpy*(destination: ptr uint8, source: uint8, size: uint32) {.exportc} =
  {.emit: """
  u8int * dst = `destination`;
  u8int * src = `source`;
  u32int len = `size`;
  for(int i = 0; i < len; ++i)
    dst[i] = src[i];
  """}
  return
