#include<stdio.h>

asm(
".pushsection \".debug_gdb_scripts\",\"MS\",@progbits,1\n"
".byte 1\n"
".asciz \"test-func.py\"\n"
".popsection \n"
);

void foo_a(const char *str)
{
	printf("%s\n",str);

}
void caller_bar(void)
{
	foo_a("caller is bar!");
}
int main(int argc,char **argv)
{
	foo_a("caller is main!");
	caller_bar();
	return(0);
}
