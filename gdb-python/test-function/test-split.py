#!/usr/bin/env /usr/bin/python
data="""
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x000000000040052a in caller_bar 
                                                   at chkfunc.c:17
2       breakpoint     keep y   0x0000000000400518 in foo_a at chkfunc.c:12
3       breakpoint     keep y   0x0000000000400545 in main at chkfunc.c:21
4       breakpoint     keep y   0x00000000004003b8 <_init>
5       breakpoint     keep y   0x00000000004003e0 <puts@plt>
6       breakpoint     keep y   0x00000000004003e0 <puts@plt>
7       breakpoint     keep y   0x00000000004003f0 <__libc_start_main@plt>
8       breakpoint     keep y   0x00000000004003f0 <__libc_start_main@plt>
9       breakpoint     keep y   0x0000000000400400 <_start>
10      breakpoint     keep y   0x000000000040042c <call_gmon_start>
11      breakpoint     keep y   0x0000000000400450 <deregister_tm_clones>
12      breakpoint     keep y   0x0000000000400480 <register_tm_clones>
13      breakpoint     keep y   0x00000000004004c0 <__do_global_dtors_aux>
14      breakpoint     keep y   0x00000000004004e0 <frame_dummy>
15      breakpoint     keep y   0x0000000000400560 <__libc_csu_fini>
16      breakpoint     keep y   0x0000000000400570 <__libc_csu_init>
17      breakpoint     keep y   0x00000000004005fc <_fini>
"""

lines=data.splitlines()

ptrs=[]

for aline in lines[2:]:
	tokens=aline.split()
	if len(tokens) >5 :
		ptrs.append(r'*'+tokens[4])		

for ptr in ptrs:
	print ptr

