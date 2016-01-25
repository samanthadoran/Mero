import tty, merosystem, math
type
  Node = object
    next: ptr Node
    address: uint32
  #Node = ref NodeObj

#The minimum block size is going to be 64K for now
const order0size = 0xFA00
const maxOrder = 5

var freeLists {.noinit.}: ptr array[maxOrder + 1, ptr Node]
var endkernel {.importc: "end"}: uint32
var startkernel {.importc: "kernel_start"}: uint32
var buddyHeap: uint32

var currPlace*: uint32

#TODO: Implement a method to track sizes with address, array using address as
#index with size in it?

proc makeOrderFromOrder(finalOrder: int, beginningOrder: int): uint32 =
  #Recursively manipulate blocks until you have made the block you need

  #We are done splitting blocks, return
  if beginningOrder == finalOrder:
    result = freeLists[finalOrder].address
    freeLists[finalOrder] = freeLists[finalOrder].next
  else:
    var x, y: ptr Node
    x = freelists[beginningOrder]

    #Give y some space!
    y = cast[ptr Node](buddyHeap)
    buddyHeap = buddyHeap + cast[uint32](sizeof(Node))

    #Remove the block from beginningOrder
    freeLists[beginningOrder] = freeLists[beginningOrder].next

    discard """
    Add the size of beginningOrder to y. This math looks scary, but it is simple.
    We need to multiply order0's size by 2^(beginningOrder + 1) so that we get
    the proper offset. The plus one is required, otherwise we would get wrong
    sized block addresses.
    """
    y.address = x.address + cast[uint32](order0size) *
                cast[uint32](pow(2, (beginningOrder + 1)))

    #Move the blocks to their new free lists
    y.next = freeLists[beginningOrder - 1]
    x.next = y
    freeLists[beginningOrder - 1] = x

    if freeLists[beginningOrder - 1].next == nil:
      terminalWrite("ffs\n")

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
      result = makeOrderFromOrder(order, i)
      #Don't forget to break the loop!
      break

proc allocInstall*() =
  currPlace = cast[uint32](addr(endkernel)) + 0x2000
  buddyHeap = cast[uint32](addr(endkernel))

  #Init freelists object
  {.emit: """
  `freeLists` = `buddyHeap`;
  """}

  #Don't let anything hit the array
  buddyHeap = buddyHeap + 0x500

  #Safety precaution, 0 the array
  for i in 0 .. maxOrder:
    freeLists[i] = nil

  #Make sure we have some memory to start out with
  freeLists[maxOrder] = cast[ptr Node](buddyHeap)

  #Move the pointer along
  buddyHeap = buddyHeap + cast[uint32](sizeof(Node))

  freeLists[maxOrder].address = currPlace + 0x1000
  freeLists[maxOrder].next = nil

  if freeLists[maxOrder] == nil:
    terminalWrite("Well, max order is nil in alloc install, this is bad.\n")

proc kfree*(address: uint32) =
  discard

proc kmalloc*(size: uint32, align: uint32 = 4): uint32 =
  #TODO: THIS MUST BE ALIGNED!!!
  let order = if size <= order0size: 0 else: log2(cast[int](size)) - log2(order0size)
  if order <= maxOrder:
    result = getFreeBlock(size)
  else:
    terminalWrite("Cannot alloc block that large...")

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
