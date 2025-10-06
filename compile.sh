nasm -felf64 mt19937.asm && nasm -felf64 test.asm && ld mt19937.o test.o -o test
