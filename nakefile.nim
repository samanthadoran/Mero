import nake
import os

#Thank yout to https://github.com/dom96/nimkernel for the example of how to set this up!

const
  CC = "/home/samantha/crossCompiler/build/bin/i686-elf-gcc"
  asmC = "/home/samantha/crossCompiler/build/bin/i686-elf-as"

task "clean", "Removes build files.":
  removeFile("boot.o")
  removeFile("kernel.bin")
  removeDir("nimcache")
  echo "Done."

task "build", "Builds the operating system.":
  echo "Compiling..."
  direShell "nim c -d:release --gcc.exe:$1 kernel" % CC

  echo "Assembling..."
  direShell asmC, "boot.s -o boot.o"
  direShell asmC, "crtn.s -o crtn.o"
  direShell asmC, "crti.s -o crti.o"

  echo "Linking..."

  direShell CC, "-T linker.ld -o kernel.bin -ffreestanding -O2 -nostdlib boot.o crtn.o crti.o nimcache/system.o nimcache/unsigned.o nimcache/vga.o nimcache/tty.o nimcache/kernel.o"

task "run", "Runs the operating system using QEMU.":
  if not existsFile("main.bin"): runTask("build")
  direShell "qemu-system-i386 -kernel kernel.bin"