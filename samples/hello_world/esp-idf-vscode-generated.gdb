target remote :3333
symbol-file ./build/hello-world.elf
mon reset halt
flushregs
thb app_main