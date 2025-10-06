# Low-level Mersenne Twister

This is an implementation of the Mersenne Twister MT19937 pseudorandom number generator in x86-64 assembly.

# License and Copyright

All files in this repository are released under the [MIT License](https://mit-license.org) as per the included [license](https://github.com/jolejarz/x86-64-mt19937/blob/main/LICENSE.txt) file.

# Files

The repository contains the following files.

* **mt19937.asm**: This is the library for the Mersenne Twister MT19937 pseudorandom number generator.
* **test.asm**: This program demonstrates the use of the library. It sets the seed to 1, calculates the first 10 pseudorandom numbers, and prints them.
* **compile.sh**: This script compiles the object files and links them.
