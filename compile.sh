nasm -felf64 mt19937.asm && nasm -felf64 test_asm.asm && ld mt19937.o test_asm.o -o test_asm && gcc -z noexecstack mt19937.o test_c.c -o test_c
