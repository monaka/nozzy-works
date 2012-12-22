import gdb
class MyBreakpoint (gdb.Breakpoint):
	""" test for break the world """
	def __init__ (self):
		super(MyBreakPoint,self).__init__ ("open",gdb.BP_BREAKPOINT)

	def stop (self):
		inf_val = gdb.parse_and_eval("$ax")
		print
