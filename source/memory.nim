import tty, merosystem, math
type
  Node = object
    next: ptr Node
    address: uint32

  TreeNode = object
    left: ptr TreeNode
    right: ptr TreeNode
    value: uint32
    used: bool

#The minimum block size is going to be 4K for now, make sure to set max Order
const order0size = 0x1000
const maxOrder = 5

var freeLists {.noinit.}: ptr array[maxOrder + 1, ptr Node]
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
    return

  if root.right.value == address:
    markAddress(address, root.right, mark, currOrder - 1, lookingOrder)
    return

  if root.right.value <= address:
    if root.right.left != nil:
      if root.right.left.value <= address:
        markAddress(address, root.right, mark, currOrder - 1, lookingOrder)
        return

  if root.left.value <= address:
    markAddress(address, root.left, mark, currorder - 1, lookingOrder)
    return

proc markAddress(address: uint32, mark: bool, order: int) =
  #Recursive helper function
  markAddress(address, treeRoot, mark, maxOrder, order)

proc buildTreeFromRoot(root: ptr TreeNode, rootOrder: int) =
  #Build a tree for us to play with
  if rootOrder != 0:
    root.left = cast[ptr TreeNode](buddyHeap)
    root.left.value = root.value
    root.left.used = false

    buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

    root.right = cast[ptr TreeNode](buddyHeap)
    root.right.value = root.value + cast[uint32](order0size) * cast[uint32](pow(2, (rootOrder - 1)))

    root.right.used = false

    buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

    buildTreeFromRoot(root.left, rootOrder - 1)
    buildTreeFromRoot(root.right, rootOrder - 1)

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
                cast[uint32](pow(2, (beginningOrder - 1)))

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

  if order != 0:
    terminalWrite("We requested not order 0?\n")

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
  freeLists = cast[ptr array[maxOrder + 1, ptr Node]](buddyHeap)
  buddyHeap = buddyHeap + cast[uint32](sizeof(array[maxOrder + 1, ptr Node]))

  #Safety precaution, 0 the array
  for i in 0 .. maxOrder:
    freeLists[i] = nil

  #Make sure we have some memory to start out with
  freeLists[maxOrder] = cast[ptr Node](buddyHeap)

  #Move the pointer along
  buddyHeap = buddyHeap + cast[uint32](sizeof(Node))

  #Give the buddys some space!
  endmemorymanagement = buddyHeap + 0x500

  #Align memory to page
  endmemorymanagement = endmemorymanagement + 4096
  while endmemorymanagement mod 4096 != 0:
    endmemorymanagement = endmemorymanagement + 1

  freeLists[maxOrder].address = endmemorymanagement
  freeLists[maxOrder].next = nil

  #Tree to keep track of frees
  treeRoot = cast[ptr TreeNode](buddyHeap)
  treeRoot.left = nil
  treeRoot.right = nil
  treeRoot.used = false
  treeRoot.value = endmemorymanagement
  buddyHeap = buddyHeap + cast[uint32](sizeof(TreeNode))

  #Construct the tree
  buildTreeFromRoot(treeRoot, maxOrder)


  if freeLists[maxOrder] == nil:
    terminalWrite("Well, max order is nil in alloc install, this is bad.\n")

proc kfree(address: uint32, root: ptr TreeNode, order: int) =
  #Free the memory in the tree to put back in lists
  if root.used and root.value == address:
    #We found it, give it back to the lists!
    root.used = false
    var tmpNode: ptr Node = cast[ptr Node](buddyHeap)
    buddyHeap = buddyHeap + cast[uint32](sizeof(Node))
    tmpNode.address = address
    tmpNode.next = freeLists[order]
    freeLists[order] = tmpNode
    return
  else:
    #We can't go down the tree any further and this isn't the node we need
    if order == 0:
      terminalWrite("We can't free this!\n")
      return

    #Navigate the tree...
    if root.value == address:
      kfree(address, root.left, order - 1)
      return

    if root.right.value == address:
      kfree(address, root.right, order - 1)
      return

    if root.right.value <= address:
      if root.right.left != nil:
        if root.right.left.value <= address:
          kfree(address, root.right, order - 1)
          return

    if root.left.value <= address:
      kfree(address, root.left, order - 1)
      return

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
