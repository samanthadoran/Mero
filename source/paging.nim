import memory, merosystem, tty

#These are defined in paging.s
proc enablePaging*() {.importc: "enablePaging"}
proc loadPageDirectory*(address: uint32) {.importc: "loadPageDirectory"}

#Use pointers to arrays so that we can align, this would be easier if nim exposed
#the align attribute.
var pageDirectory: ptr array[1024, uint32]
var firstPageTable: ptr array[1024, uint32]

proc initPaging*() =
  #Initialize basic paging...

  #THESE MUST BE 4K ALIGNED!!! Use kmalloc because it does this for us
  pageDirectory = cast[ptr array[1024, uint32]](kmalloc(cast[uint32](sizeof(array[1024, uint32]))))
  firstPageTable = cast[ptr array[1024, uint32]](kmalloc(cast[uint32](sizeof(array[1024, uint32]))))

  #Set supervisor mode
  for i in 0 .. <len(pageDirectory[]):
    #Read/write supervisor mode page
    pageDirectory[i] = 0x00000002

    #Map read/write present supervisor mode pagetable
    firstPageTable[i] = cast[uint32](i * 0x1000) or 3

  #It's super important that this be dereferenced!
  pageDirectory[0] = cast[uint32](addr(firstPageTable[])) or 3

  #Move the address of the directory into CR3
  #It's super important that this be dereferenced!
  loadPageDirectory(cast[uint32](addr(pageDirectory[])))

  #Set the paging bit in CR0 (bit 31)
  enablePaging()
