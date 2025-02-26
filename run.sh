#!/bin/bash
nasm -f elf64 x11_window.asm -o x11_window.o
gcc x11_window.o -o x11_window -lX11 -no-pie
./x11_window
