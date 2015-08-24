.global isr_wrapper
.align 4

isr_wrapper:
  pushad
  cld
  call interruptHandler
  popad
  iret
