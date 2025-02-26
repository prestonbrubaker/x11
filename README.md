Will's Guide to (hopefully) get a Window Up on Our Computers

This little directory has too scripts. One in C, to help us identify our specific system parameters, the other is the actual implmentation using those parameters. Of course, start with 'find_offset.c'

It can be compiled with the following commands. 

gcc find_offset.c -o find_offset -lX11 && ./find_offset



Assuming success, the return can be used to set the offset in memory for the actual root window. A successful return (my return) looks like this:

prestop@prestop-HP-Pavilion-Laptop-15-eg0xxx:~/Desktop/wills_x_server$ gcc find_offset.c -o find_offset -lX11 && ./find_offset
Actual root: 0x499
Found root window at offset: 0x1760


The offset can then be swapped in (assuming yours is different, it may not be) in the x11_window.asm script. 
See the notes within the script for more details. Have read through comments but want to dive into it deep with you later. LOVE YOU PRESTON!

To compile the x11_server.asm:

nasm -f elf64 x11_window.asm -o x11_window.o
gcc x11_window.o -o x11_window -lX11 -no-pie
