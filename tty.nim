import vga

#Using globals until get alloc working
var terminalRow*: int
var terminalColumn*: int
var terminalColor*: VGAAttribute
var terminalBuffer*: VidMem

proc terminalInitialize*() =
  #Initialize the terminal
  terminalRow = 0
  terminalColumn = 0
  terminalColor = makeVGAAttribute(LightGrey, Black)
  terminalBuffer = VGAMem

  for y in 0 .. <VGAHeight:
    for x in 0 .. <VGAWidth:
      let index = y * VGAWidth + x
      terminalBuffer[index] = makeVGAEntry(' ', terminalColor)

proc terminalSetColor*(color: VGAAttribute) =
  #Set the color of foreground and background of the terminal
  terminalColor = color

proc terminalPutEntryAt*(c: char, color: VGAAttribute, x: int, y: int) =
  #Put a vgaentry at x, y
  let index = y * VGAWidth + x
  terminalBuffer[index] = makeVGAEntry(c, color)

proc terminalPutChar*(c: char) =
  #Write a character to the current terminal positio
  terminalPutEntryAt(c, terminalColor, terminalColumn, terminalRow)
  inc(terminalColumn)
  if terminalColumn == VGAWidth:
    terminalColumn = 0
    inc(terminalRow)
    if terminalRow == VGAHeight:
      terminalRow = 0

proc terminalWrite*(data: string) =
  #Write a string to the terminal
  for i in 0 .. <len(data):
    terminalPutChar(data[i])
