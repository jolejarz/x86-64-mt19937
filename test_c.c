#include <stdio.h>

extern void mt19937_init(int);
extern unsigned int mt19937_get();

int main()
{
	// Initialize the generator.
	mt19937_init(1);

	// Print the first 10 pseudorandom numbers.
	for (int i=0; i<10; i++) printf("%u\n",mt19937_get());

	return 0;
}
