import tty
var endkernel {.importc: "end"}: uint32
var startkernel {.importc: "kernel_start"}: uint32

var currPlace*: uint32 = cast[uint32](addr(endkernel))

proc makeOderFromBlock(finalOrder: int, beginningOrder: int): uint32 =
  #Make a block into the requested order
  discard """
  if finalOrder == beginningOrder:
    result = freelists[i]
    freelists[i] = result.next
  else:
    #Split and add to free lists
    result = freelists[finalOrder]
    freelists[finalOrder] = result.next
  """

proc getFreeBlock(size: uint32): uint32 =
  #Return an address to a free block
  discard """
  let order = log2(size) - log2(order0size)
  for i in order .. < maxOrder:
    #If there is a free block of order i...
    if freeLists[i] != nil:
      #Manipulate it and store free blocks appropriately
      result = makeOrderFromBlock(order, i)
  """

proc allocInstall*() =
  currPlace = cast[uint32](addr(endkernel))

proc kmalloc*(size: uint32, align: uint32 = 4): uint32 =
  #TODO: THIS MUST BE ALIGNED!!!
  if currPlace < 0x1000:
    terminalWrite("Uh oh...\n")
    while true:
      discard

  if currPlace mod align != 0:
    currPlace = currPlace + 1

  result = currPlace
  currPlace = size + result

proc memcpy*(destination: pointer, source: pointer, size: uint32) {.exportc.} =
  var dstu8 = cast[ptr uint8](destination)
  var srcu8 = cast[ptr uint8](source)

  for i in 0 .. <size:
    dstu8 = cast[ptr uint8](cast[uint32](dstu8) + i)
    srcu8 = cast[ptr uint8](cast[uint32](srcu8) + i)
    dstu8[] = srcu8[]

  discard

proc memset*(begin: pointer, value: uint8, size: uint32) {.exportc.} =
  #Experimental memset operation
  var tBegin = cast[ptr uint8](begin)
  for i in 0 .. <size:
    tBegin = cast[ptr uint8](cast[uint32](tBegin) + i)
    tBegin[] = 0
