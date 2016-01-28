import tty, merosystem, math
type
  TreeNode = object
    #For use in the free lists
    next: ptr TreeNode

    #Hold our children
    left: ptr TreeNode
    right: ptr TreeNode

    #The address this node is holding
    value: uint32

    #Is this specific instance being used?
    used: bool

#The minimum block size is going to be 4K for now, make sure to set max Order
const order0size = 0x1000
const maxOrder = 5

var freeLists {.noinit.}: ptr array[maxOrder + 1, ptr TreeNode]
var treeRoot: ptr TreeNode

var endkernel {.importc: "end"}: uint32
var startkernel {.importc: "kernel_start"}: uint32
var buddyHeap: uint32
var endmemorymanagement*: uint32

#TODO: Implement a method to track sizes with address, array using address as
#index with size in it?

proc markAddress(address: uint32, root: ptr TreeNode, mark: bool,
                 currOrder: int, lookingOrder: int) =
  #Mark an address as either used or unused

  if currOrder == lookingOrder:
    if root.value == address:
      #We found it! Mark it!
      root.used = mark
      return
    else:
      #We are trying to mark something that couldn't have been malloced
      terminalWrite("Wrong address at lookingorder. Got ")
      terminalWriteHex(root.value)
      terminalWrite(" but expected ")
      terminalWriteHex(address)
      terminalWrite("\n")
      return

  #Navigate down the tree

  if root.value == address:
    markAddress(address, root.left, mark, currOrder - 1, lookingOrder)

  elif root.right.value <= address:
    markAddress(address, root.right, mark, currOrder - 1, lookingOrder)

  else:
    markAddress(address, root.left, mark, currOrder - 1, lookingOrder)

proc markAddress(address: uint32, mark: bool, order: int) =
  #Recursive helper function
  markAddress(address, treeRoot, mark, maxOrder, order)

proc buildTreeFromRoot(root: ptr TreeNode, rootOrder: int) =
  #Build a tree for us to play with
  if rootOrder != 0:
    root.left = cast[ptr TreeNode](buddyHeap)
    root.left.value = root.value
    root.left.used = false
    root.left.next = nil

    buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

    root.right = cast[ptr TreeNode](buddyHeap)
    root.right.value = root.value + cast[uint32](order0size) * cast[uint32](pow(2, (rootOrder - 1)))

    root.right.used = false
    root.right.next = nil

    buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

    buildTreeFromRoot(root.left, rootOrder - 1)
    buildTreeFromRoot(root.right, rootOrder - 1)

proc makeOrderFromOrder(finalOrder: int, beginningOrder: int): uint32 =
  #Recursively manipulate blocks until you have made the block you need

  #We are done splitting blocks, return
  if beginningOrder == finalOrder:
    result = freeLists[finalOrder].value

    var x = freeLists[finalOrder]
    freeLists[finalOrder] = freeLists[finalOrder].next
    x.next = nil
  else:
    var x, y: ptr TreeNode
    var initial = freeLists[beginningOrder]
    x = initial.left
    y = initial.right

    freeLists[beginningOrder] = freeLists[beginningOrder].next
    initial.next = nil

    x.next = y
    y.next = freeLists[beginningOrder - 1]
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
      result = makeOrderFromOrder(order, i)
      markAddress(result, true, order)
      #Don't forget to break the loop!
      break

proc allocInstall*() =
  buddyHeap = cast[uint32](addr(endkernel))

  #Init freelists object
  freeLists = cast[ptr array[maxOrder + 1, ptr TreeNode]](buddyHeap)
  buddyHeap = buddyHeap + cast[uint32](sizeof(array[maxOrder + 1, ptr TreeNode]))

  #Safety precaution, 0 the array
  for i in 0 .. maxOrder:
    freeLists[i] = nil

  #Give the buddys some space!
  endmemorymanagement = buddyHeap + 0x500

  #Align memory to page
  endmemorymanagement = endmemorymanagement + 4096
  while endmemorymanagement mod 4096 != 0:
    endmemorymanagement = endmemorymanagement + 1

  #Tree to keep track of frees
  treeRoot = cast[ptr TreeNode](buddyHeap)
  treeRoot.left = nil
  treeRoot.right = nil
  treeRoot.used = false
  treeRoot.value = endmemorymanagement
  treeRoot.next = nil
  buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

  #Construct the tree
  buildTreeFromRoot(treeRoot, maxOrder)
  freeLists[maxOrder] = treeRoot
  freeLists[maxOrder].next = nil


  if freeLists[maxOrder] == nil:
    terminalWrite("Well, max order is nil in alloc install, this is bad.\n")

proc kfree(address: uint32, root: ptr TreeNode, order: int) =
  #Free the memory in the tree to put back in lists
  if root.used and root.value == address:
    #We found it, give it back to the lists!
    root.used = false
    root.next = freeLists[order]
    freeLists[order] = root
    return
  else:
    #We can't go down the tree any further and this isn't the node we need
    if order == 0:
      terminalWrite("We can't free this!\n")
      return

    #Navigate the tree...
    if root.value == address:
      kfree(address, root.left, order - 1)

    elif root.right.value <= address:
      kfree(address, root.right, order - 1)

    else:
      kfree(address, root.left, order - 1)

proc kfree*(address: uint32) =
  #Helper function to call recursive
  kfree(address, treeRoot, maxOrder)
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
