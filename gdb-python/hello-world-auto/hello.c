#include <stdio.h>

asm(
".pushsection \".debug_gdb_scripts\",\"MS\",@progbits,1\n"
".byte 1\n"
".asciz \"hello-world.py\"\n"
".popsection \n"
);

int main(int argc,char **argv)
{
	printf("hello world");
}
