# Low-level Mersenne Twister

This is an implementation of the Mersenne Twister MT19937 pseudorandom number generator in x86-64 assembly. It is compiled using NASM and runs on Linux.

# License and Copyright

All files in this repository are released under the [MIT License](https://mit-license.org) as per the included [license](https://github.com/jolejarz/x86-64-mt19937/blob/main/LICENSE.txt) file.

# Files

The repository contains the following files.

* **mt19937.asm**: This is the library for the Mersenne Twister MT19937 pseudorandom number generator.
* **test.asm**: This program demonstrates the use of the library. It sets the seed to 1, calculates the first 10 pseudorandom numbers, and prints them.
* **compile.sh**: This script compiles the object files and links them.

# Functions

The API in mt19937.asm consists of the following functions.

## mt19937_init

This function initializes the generator using the seed specified in EAX.

## mt19937_get

This function calculates the next pseudorandom number and returns it in R8D.
