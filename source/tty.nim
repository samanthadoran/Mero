import vga, asmwrapper

proc terminalWrite*(data: string) {.exportc.}
proc terminalWriteDecimal*(num: uint)
proc terminalWriteDecimal*(num: int)
proc terminalWriteHex*(num: uint) {.exportc.}
proc terminalPutEntryAt*(c: char, color: VGAAttribute, x: int, y: int)

import timer

#Using globals until get alloc working
var terminalRow*: int
var terminalColumn*: int
var terminalColor*: VGAAttribute
var terminalBuffer* {.noinit.}: VidMem

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

proc moveCursor*(x: int, y: int) =
  #Moves the cursor to the specified x, y
  let index: uint16 = cast[uint16](y * VGAWidth + x)

  outb(cast[uint16](0x3D4), cast[uint8](14))
  outb(cast[uint16](0x3D5), cast[uint8](index shr 8))
  outb(cast[uint16](0x3D4), cast[uint8](15))
  outb(cast[uint16](0x3D5), cast[uint8](index))

proc scrollTerminal*() =
  #Scroll the terminal to give room for additional input

  #Don't scroll until we need to
  if terminalRow < VGAHeight:
    return

  #Imagine the screen buffer as a 2d grid for clarity
  for y in 0 .. <VGAHeight - 1:
    for x in 0 .. <VGAWidth:
      terminalBuffer[y * VGAWidth + x] = terminalBuffer[(y + 1) * VGAWidth + x]

  #Clear the last line
  for i in 0 .. <VGAWidth:
    terminalPutEntryAt(' ', terminalColor, i, VGAHeight - 1)

  #Reset cursor position
  terminalRow = VGAHeight - 1
  terminalColumn = 0

proc terminalSetColor*(color: VGAAttribute) =
  #Set the color of foreground and background of the terminal
  terminalColor = color

proc terminalPutEntryAt*(c: char, color: VGAAttribute, x: int, y: int) =
  #Put a vgaentry at x, y
  let index = y * VGAWidth + x
  terminalBuffer[index] = makeVGAEntry(c, color)

proc terminalPutChar*(c: char) =
  #Write a character to the current terminal position
  if ord(c) == 10:
    terminalColumn = 0
    inc(terminalRow)
  else:
    terminalPutEntryAt(c, terminalColor, terminalColumn, terminalRow)
    inc(terminalColumn)
    if terminalColumn == VGAWidth:
      terminalColumn = 0
      inc(terminalRow)

  scrollTerminal()
  moveCursor(terminalColumn, terminalRow)

proc terminalWrite*(data: string) =
  #Write a string to the terminal
  for i in 0 .. <len(data):
    terminalPutChar(data[i])

proc terminalSlowWrite*(data: string, ticksToWait: uint32) =
  #Write a string to the terminal -- slowly
  for i in 0 .. <len(data):
    terminalPutChar(data[i])
    wait(ticksToWait)

proc terminalWriteDecimal*(num: uint) =
  #Properly add a negative for less than zero
  if num < 0:
    terminalPutChar('-')
  if num == 0:
    terminalPutChar('0')
    return

  discard """
  Nim likes to replace array[0..n, char] with a cstring.. this won't do as we
  cannot include <string.h>. So, while reversing the string using arrays would
  have worked, using a similar method of swapping the terminal buffer entries
  will work just as well
  """

  let cursorStart = terminalColumn
  var endNumIndex = -1

  var numCopy = num
  while numCopy != 0:
    #Add the number to the ascii code for 0
    terminalPutChar(chr(cast[uint](48) + (numCopy mod 10)))
    #Lose the rightmost digit
    numCopy = numCopy div 10

    inc(endNumIndex)

  for i in 0..endNumIndex div 2:
    #Swap in memory
    let first = terminalBuffer[terminalRow*VGAWidth + cursorStart + i]
    let last = terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i]

    terminalBuffer[terminalRow*VGAWidth + cursorStart + i] = last
    terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i] = first

proc terminalWriteDecimal*(num: int) =
  #Properly add a negative for less than zero
  if num < 0:
    terminalPutChar('-')
  if num == 0:
    terminalPutChar('0')
    return

  discard """
  Nim likes to replace array[0..n, char] with a cstring.. this won't do as we
  cannot include <string.h>. So, while reversing the string using arrays would
  have worked, using a similar method of swapping the terminal buffer entries
  will work just as well
  """

  let cursorStart = terminalColumn
  var endNumIndex = -1

  var numCopy = num
  while numCopy != 0:
    #Add the number to the ascii code for 0
    terminalPutChar(chr(48 + (numCopy mod 10)))
    #Lose the rightmost digit
    numCopy = numCopy div 10

    inc(endNumIndex)

  for i in 0..endNumIndex div 2:
    #Swap in memory
    let first = terminalBuffer[terminalRow*VGAWidth + cursorStart + i]
    let last  = terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i]

    terminalBuffer[terminalRow*VGAWidth + cursorStart + i] = last
    terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i] = first

proc terminalWriteHex*(num: uint) =
  terminalWrite("0x")

  if num == 0:
    terminalWrite("0")
    return

  discard """
  Nim likes to replace array[0..n, char] with a cstring.. this won't do as we
  cannot include <string.h>. So, while reversing the string using arrays would
  have worked, using a similar method of swapping the terminal buffer entries
  will work just as well
  """

  let cursorStart = terminalColumn
  var endNumIndex = -1

  var numCopy = num
  while numCopy != 0:
    let place = numCopy mod 16
    numCopy = numCopy div 16
    if place > cast[uint](9):
      terminalPutChar(chr((cast[uint](65) + place - 10)))
    else:
      terminalPutChar(chr(cast[uint](48) + place))

    inc(endNumIndex)

  for i in 0..endNumIndex div 2:
    #Swap in memory
    let first = terminalBuffer[terminalRow*VGAWidth + cursorStart + i]
    let last  = terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i]

    terminalBuffer[terminalRow*VGAWidth + cursorStart + i ] = last
    terminalBuffer[terminalRow*VGAWidth + cursorStart + endNumIndex - i] = first
