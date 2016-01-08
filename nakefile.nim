import nake
import os

#Thank yout to https://github.com/dom96/nimkernel for the example of how to set this up!

const
  CC = "i686-elf-gcc"
  asmC = "i686-elf-as"

task "clean", "Removes build files.":
  removeFile("boot.o")
  removeFile("gdt.o")
  removeFile("crti.o")
  removeFile("crtn.o")
  removeFile("interrupt.o")
  removeFile("mero.bin")
  removeDir("nimcache")
  echo "Done."

task "build", "Builds the operating system.":
  echo "Compiling..."
  direShell "nim c -d:release --gcc.exe:$1 kernel" % CC

  echo "Assembling..."
  direShell asmC, "boot.s -o boot.o"
  direShell asmC, "crtn.s -o crtn.o"
  direShell asmC, "crti.s -o crti.o"
  direShell "nasm -felf32 gdt.s -o gdt.o"
  direShell "nasm -felf32 interrupt.s -o interrupt.o"

  echo "Linking..."

  direShell CC, "-T linker.ld -o mero.bin -ffreestanding -O2 -nostdlib *.o nimcache/*.o"

task "run-qemu", "Runs the operating system using QEMU.":
  if not existsFile("main.bin"): runTask("build")
  direShell "qemu-system-i386 -kernel mero.bin"

task "run-bochs", "Runs the operating system using bochs.":
  echo("Updating image...")
  direShell "sudo losetup /dev/loop99 floppy.img"
  direShell "sudo mount /dev/loop99 /mnt"
  direShell "sudo cp kernel.bin /mnt/kernel"
  direShell "sudo umount /dev/loop99"
  direShell "sudo losetup -d /dev/loop99"

  echo("Running bochs...")
  direShell "sudo /sbin/losetup /dev/loop99 floppy.img"
  direShell "sudo bochs -f bochsrc.txt"
  direShell "sudo /sbin/losetup -d /dev/loop99"
