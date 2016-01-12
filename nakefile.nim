import nake
import os

#Thank yout to https://github.com/dom96/nimkernel for the example of how to set this up!

const
  CC = "i686-elf-gcc"
  asmC = "nasm -felf32"

task "clean", "Removes build files.":
  removeFile("boot.o")
  removeFile("gdt.o")
  removeFile("crti.o")
  removeFile("crtn.o")
  removeFile("interrupt.o")
  removeFile("mero.bin")
  removeDir("source/nimcache")
  removeDir("nimcache")
  echo "Done."

task "build", "Builds the operating system.":
  echo "Compiling..."
  direShell "nim c -d:release --gcc.exe:$1 source/kernel" % CC

  echo "Assembling..."
  direShell asmC, "i686-asm/boot.s -o boot.o"

  echo "Linking..."

  direShell CC, "-T linker.ld -o mero.bin -ffreestanding -O2 -nostdlib *.o source/nimcache/*.o"

task "run-qemu", "Runs the operating system using QEMU.":
  if not existsFile("mero.bin"): runTask("build")
  direShell "qemu-system-i386 -kernel mero.bin"

task "run-bochs", "Runs the operating system using bochs.":
  echo("Updating image...")
  direShell "sudo losetup /dev/loop99 floppy.img"
  direShell "sudo mount /dev/loop99 /mnt"
  direShell "sudo cp kernel.bin /mnt/kernel"
  direShell "sudo umount /dev/loop99"
  direShell "sudo losetup -d /dev/loop99"

  echo("Running bochs...")
  direShell "sudo /sbin/losetup /dev/loop0 floppy.img"
  direShell "sudo bochs -f bochsrc.txt"
  direShell "sudo /sbin/losetup -d /dev/loop0"
