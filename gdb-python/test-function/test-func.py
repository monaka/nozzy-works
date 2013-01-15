# -*- coding: utf-8 -*-
# coding:utf-8
import gdb
class CallerIs (gdb.Function):
	""" test Caller is specified caller """
	def __init__(self):
		super (CallerIs, self).__init__("caller_is")
	def invoke(self, name, nframes = 1):
		frame = gdb.newest_frame ()
		while nframes > 0:
			frame = frame.older ()
			nframes = nframes - 1
		return frame.name () == name.string ()

CallerIs()

class CheckStr(gdb.Command):
	""" gdb.value checking """
	def __init__(self):
		super(CheckStr,self).__init__("checkstr",gdb.COMMAND_OBSCURE)
	def invoke (self,arg, from_tty):
		str_arg_val=gdb.parse_and_eval("str");
		print "str="+str_arg_val.string();

CheckStr()

class _LPrintfBreakpoint(gdb.Breakpoint):
	def __init__(self, spec, command):
		super(_LPrintfBreakpoint, self).__init__(spec, gdb.BP_BREAKPOINT,
							 internal = False)
		self.command = command

	def stop(self):
		gdb.execute(self.command)
		return False

class _LPrintfCommand(gdb.Command):
	"""Log some expressions at a location, using 'printf'.
	Usage: lprintf LINESPEC, FORMAT [, ARG]...
	Insert a breakpoint at the location given by LINESPEC.
	When the breakpoint is hit, do not stop, but instead pass
	the remaining arguments to 'printf' and continue.
	This can be used to easily add dynamic logging to a program
	without interfering with normal debugger operation."""

	def __init__(self):
		super(_LPrintfCommand, self).__init__('lprintf',
						      gdb.COMMAND_DATA,
						      # Not really the correct
						      # completer, but ok-ish.
						      gdb.COMPLETE_SYMBOL)

	def invoke(self, arg, from_tty):
		print "_LPrintfCommmand arg="+str(arg)
		(remaining, locations) = gdb.decode_line(arg)
		if remaining is None:
			raise gdb.GdbError('printf format missing')
		remaining = remaining.strip(',')
		if locations is None:
			raise gdb.GdbError('no matching locations found')
		msg="_LPrintfCommmand remaining="+str(remaining)
		for loc in locations:
			msg=msg+" locations="+str(loc)
			print msg
		spec = arg[0:- len(remaining)]
		_LPrintfBreakpoint(spec, 'printf ' + remaining)

_LPrintfCommand()

class _CallTracerFinishBreakpoint(gdb.FinishBreakpoint):
	def __init__(self, name, stack):
		super(_CallTracerFinishBreakpoint, self).__init__(internal=True)
		self._stack_ptr=stack
		self._name=name
		self.silent=True
	def stop(self):
		print (" " * (len(self._stack_ptr)))+"<="+self._name
		self._stack_ptr.pop()
		return False
	def out_of_scope(self):
		print "Abnormal jump out frame"
		print (" " * (len(self._stack_ptr)))+"<="+self._name
		self._stack_ptr.pop()
		return False


class _CallTracerBreakpoint(gdb.Breakpoint):
	def __init__(self, spec, name, stack):
		super(_CallTracerBreakpoint, self).__init__(spec, 
							    gdb.BP_BREAKPOINT,
							    internal = False)
		self._stack_ptr=stack
		self._name=name
		self.silent=True
	def stop(self):
		self._stack_ptr.append(self._name)
		print (" " * (len(self._stack_ptr)))+"=>"+self._name
		try:
			_CallTracerFinishBreakpoint(self._name, self._stack_ptr)
		except:
			print "uh? cant put finish break on "+self._name
		return False

class _PrepareCallTracer(gdb.Command):
	""" prepare call tracer for c """
	def __init__(self):
		super(_PrepareCallTracer, self).__init__('prepcalltracer',
							 gdb.COMMAND_OBSCURE)
		self._stack=[]
	def _retrive_ptrs(self):
		info=gdb.execute("info break",False, True)
		info_lines=info.splitlines()
		ptrs={}
		for idx in range(0,len(info_lines[1:])):
			tokens=info_lines[idx+1].split()
			if len(tokens) > 5:
				if ptrs.has_key(tokens[4]) == False:
					ptrs[tokens[4]]=" ".join(tokens[5:])
		return ptrs

	def invoke(self, arg, from_tty):
		gdb.execute("rbreak",False, True)
		break_info=self._retrive_ptrs()
		gdb.execute("delete",False, True)
		gdb.execute("set pagination off")
		for addr,name in break_info.iteritems():
			_CallTracerBreakpoint(r'*'+addr,
					      name,self._stack)
		print "prepare done!"

_PrepareCallTracer()

