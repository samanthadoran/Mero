import tty, merosystem, math
type
  NodeObj = object
    next: Node
    address: uint32
  Node = ref NodeObj

var freeLists {.noinit.}: array[10, Node]

#The minimum block size is going to be 64K for now
const order0size = 0xFA00
const maxOrder = 9
var endkernel {.importc: "end"}: uint32
var startkernel {.importc: "kernel_start"}: uint32

var currPlace*: uint32 = cast[uint32](addr(endkernel))

#TODO: Implement log2(int) and pow(int, int) for sizing calculations
#Implement a method to track sizes with address, array using address as index
#with size in it?
#log2 int could just use bsr, pow will just have to be iterative

proc makeOrderFromOrder(finalOrder: int, beginningOrder: int): uint32 =
  #Recursively manipulate blocks until you have made the block you need

  #We are done splitting blocks, return
  if beginningOrder == finalOrder:
    result = freeLists[finalOrder].address
    freeLists[finalOrder] = freeLists[finalOrder].next
  else:
    var x, y: Node
    x = freelists[beginningOrder]

    #Remove the block from beginningOrder
    freeLists[beginningOrder] = freeLists[beginningOrder].next

    #Add the size of beginningOrder to y
    y.address = x.address + cast[uint32](pow(2, (log2(order0size) + beginningOrder)))

    #Move the blocks to their new free lists
    y.next = freeLists[beginningOrder - 1]
    x.next = y
    freeLists[beginningOrder - 1] = x

    #Recursively call until we are at the desired size.
    result = makeOrderFromOrder(finalOrder, beginningOrder - 1)

proc getFreeBlock(size: uint32): uint32 =
  #Return an address to a free block
  #Get the order based upon our order0size
  let order = if size <= order0size: 0 else: log2(cast[int](size)) - log2(order0size)

  #Iterate until we have a free block to work with
  for i in order ..  maxOrder:
    #If there is a free block of order i...
    if freeLists[i] != nil:
      #Manipulate it and store free blocks appropriately
      result = makeOrderFromOrder(order, i)

proc allocInstall*() =
  currPlace = cast[uint32](addr(endkernel)) + 0x1000
  #Init freelists object
  #freeLists[9] =

proc kfree(address: uint32) =
  discard

proc kmalloc*(size: uint32, align: uint32 = 4): uint32 =
  #TODO: THIS MUST BE ALIGNED!!!
  result = getFreeBlock(size)
  discard """
  if currPlace mod align != 0:
    currPlace = currPlace + 1

  result = currPlace
  currPlace = size + result
  """

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
