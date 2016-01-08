type
  #VGA data helpers
  VidMem*   = ptr array[0..65_000, VGAEntry]
  VGAColor* = enum
    Black        = 0,
    Blue         = 1,
    Green        = 2,
    Cyan         = 3,
    Red          = 4,
    Magenta      = 5,
    Brown        = 6,
    LightGrey    = 7,
    DarkGrey     = 8,
    LightBlue    = 9,
    LightGreen   = 10,
    LightCyan    = 11,
    LightRed     = 12,
    LightMagenta = 13,
    LightBrown   = 14,
    White        = 15
  VGAEntry*     = distinct uint16
  VGAAttribute* = distinct uint8

const
  #Initial vga environment
  VGAWidth*  = 80
  VGAHeight* = 25
  VGAMem*    = cast[VidMem](0xB8000)

proc makeVGAAttribute*(foreground: VGAColor, background: VGAColor): VGAAttribute =
  #Make a specific forground and background attribute
  return (ord(foreground).uint8 or (ord(background).uint8 shl 4)).VGAAttribute

proc makeVGAEntry*(c: char, attribute: VGAAttribute): VGAEntry =
  #Apply an attribute to a character to make an entry
  var c16: uint16 = ord(c).uint16
  var color16: uint16 = ord(attribute).uint16
  return (c16 or (color16 shl 8)).VGAEntry
