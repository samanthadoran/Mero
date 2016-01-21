import nake
import os

#Thank yout to https://github.com/dom96/nimkernel for the example of how to set this up!

const
  CC = "i686-elf-gcc"
  asmC = "nasm -felf32"

task "clean", "Removes build files.":
  removeFile("boot.o")
  removeFile("interrupts.o")
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
  direShell asmc, "i686-asm/boot.s -o boot.o"
  direShell "i686-elf-as i686-asm/crtn.s -o crtn.o"
  direShell "i686-elf-as i686-asm/crti.s -o crti.o"

  echo "Linking..."

  direShell CC, "-T linker.ld -o mero.bin -ffreestanding -O2 -nostdlib *.o source/nimcache/*.o"

task "run-qemu", "Runs the operating system using QEMU.":
  #if not existsFile("mero.bin"): runTask("build")
  runTask("build")
  direShell "qemu-system-i386 -kernel mero.bin"

task "run-bochs", "Runs the operating system using bochs.":
  runTask("build")
  echo("Updating image...")
  direShell "sudo losetup /dev/loop0 floppy.img"
  direShell "sudo mount /dev/loop0 /mnt"
  direShell "sudo cp mero.bin /mnt/kernel"
  direShell "sudo umount /dev/loop0"
  direShell "sudo losetup -d /dev/loop0"

  echo("Running bochs...")
  direShell "sudo /sbin/losetup /dev/loop0 floppy.img"
  direShell "sudo bochs -q -f bochsrc.txt"
  direShell "sudo /sbin/losetup -d /dev/loop0"
