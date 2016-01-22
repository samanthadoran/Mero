import tty
import merosystem, isrs, irq, math
import timer, keyboard
import paging

#TODO: This is out of date???
discard """
The multiboot spec from: https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
follows for reference.
The layout of the Multiboot header must be as follows:

Offset 	Type 	Field Name 	Note
0 	u32 	magic 	required
4 	u32 	flags 	required
8 	u32 	checksum 	required
12 	u32 	header_addr 	if flags[16] is set
16 	u32 	load_addr 	if flags[16] is set
20 	u32 	load_end_addr 	if flags[16] is set
24 	u32 	bss_end_addr 	if flags[16] is set
28 	u32 	entry_addr 	if flags[16] is set
32 	u32 	mode_type 	if flags[2] is set
36 	u32 	width 	if flags[2] is set
40 	u32 	height 	if flags[2] is set
44 	u32 	depth 	if flags[2] is set
"""

type
  TMultiboot_header = object
    magic:          uint32
    flags:          uint32
    checksum:       uint32
    headerAddress:  uint32
    loadAddress:    uint32
    loadEndAddress: uint32
    bssEndAddress:  uint32
    entryAddress:   uint32
    modeType:       uint32
    width:          uint32
    height:         uint32
    depth:          uint32

  PMultiboot_header = ptr TMultiboot_header

proc kernel_early() {.exportc.} =
  #Things we need to happen before everything else.
  gdtInstall()
  idtInstall()
  isrsInstall()
  irqInstall()
  allocInstall()

  #Don't do anything serious until all tables are initialized.
  terminalInitialize()
  keyboardInstall()
  timerInstall()

  #Once we're done, we can safely enable hardware maskable interrupts
  {.emit: """
  __asm__ __volatile__ ("sti");
  """}

proc kernel_main(pmbh: PMultiboot_header) {.exportc noReturn.} =
  #if cast[uint32](addr(page_directory[0])) mod 4 != 0:
  #  panic("Page directory not 4KB aligned!\n")
  #terminalWrite("Div by 0: ")
  #terminalWriteDecimal(1 div 0)
  #terminalWrite("\n")
  terminalWrite("Initialized the terminal...\n")
  terminalWrite("Hello, world!\n")
  terminalSetColor(makeVGAAttribute(LightGreen, Green))
  terminalWrite("Testing colors...\n")

  terminalSetColor(makeVGAAttribute(Green, Black))
  terminalWrite("Testing decimal writing with 8675309: ")
  terminalWriteDecimal(8675309)
  terminalWrite("\n")

  terminalWrite("Testing hex writing with 0xDEADBEEF: ")
  terminalWriteHex(cast[uint](0xDEADBEEF))
  terminalWrite("\n")

  #Test the use of timer's wait function
  #terminalSlowWrite("Slow it on dooooowwwwwnnnnn.....\n", 4)
  terminalSetColor(makeVGAAttribute(Red, Black))
  terminalWrite("WARNING: Escape causes debug interrupt!!!!\n")
  terminalSetColor(makeVGAAttribute(Green, Black))

  terminalWrite("Testing mallocs...\n")

  for i in 0..10:
    var xp: ptr uint32 = cast[ptr uint32](kmalloc(cast[uint32](sizeof(uint32))))
    xp[] = 777
    terminalWrite("Zzz....: ")
    terminalWriteHex(cast[uint32](xp))
    terminalWrite(": ")
    terminalWriteDecimal(xp[])
    terminalWrite("\n")
  
  terminalWrite("Testing log2(1) should be 0: ")
  terminalWriteDecimal(log2(1))
  terminalWrite("\n")

  terminalWrite("Testing 2^0 should be 1: ")
  terminalWriteDecimal(pow(2, 0))
  terminalWrite("\n")

  terminalWrite("Testing 0^1 should be 0: ")
  terminalWriteDecimal(pow(0, 1))
  terminalWrite("\n")

  #terminalWrite("Testing 0^0 should fault: ")
  #terminalWriteDecimal(pow(0, 0))
  #terminalWrite("\n")

  while true:
    discard
