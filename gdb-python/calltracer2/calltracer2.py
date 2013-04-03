import re

class _MediatorForCallTracer(object):
    """ mediator for updating state of calltracer """
    def __init__(self):
        self._signals = {}

    def signal(self,signal_name,*args, **kw):
        for handler in self._signals.get(signal_name,[]):
            handler(*args, **kw)

    def connect(self, signal_name, receiver):
        handlers = self._signals.setdefault(signal_name,[])
        handlers.append(receiver)

    def disconnect(self, signal_name, receiver):
        handlers[signal_name].remove(receiver)

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

class _ReAnalyzeCallTracer(gdb.Command):
    """ reanalyze symbol for calltracer """
    def __init__(self):
        super(_ReAnalyzeCallTracer, self).__init__('reanalyzecalltracer',
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
        break_info=self._retrive_ptrs()
        gdb.execute("delete",False, True)
        gdb.execute("set pagination off")
        for addr,name in break_info.iteritems():
            _CallTracerBreakpoint(r'*'+addr,
                                  name,self._stack)
_ReAnalyzeCallTracer()

class _PrepareCallTracer(gdb.Command):
    """ prepare call tracer for c """
    def __init__(self):
        super(_PrepareCallTracer, self).__init__('prepcalltracer',
                                                 gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_tty):
        gdb.execute("rbreak",False, True)
        gdb.execute("reanalyzecalltracer",False, True)
        print "prepare done!"

_PrepareCallTracer()

class _CallTracerLoadBinaryBreakpoint(gdb.Breakpoint):
    def __init__(self, spec,binary_info,stack,most_recently_loaded):
        super(_CallTracerLoadBinaryBreakpoint, self).__init__(spec, 
                                                    gdb.BP_BREAKPOINT,
                                                    internal = False)
        self.silent=True
        self._most_recently_loaded=most_recently_loaded
        self._record_regrex=re.compile(r'^0x[^/]+(.+)$')
        self._binary_info=binary_info
        self._stack=stack

    def _retrive_loaded_binary(self):
        info=gdb.execute("info sharedLibrary",False, True)
        info_lines=info.splitlines()
        for idx in range(len(info_lines)-1,0,-1):
            loaded_binary=self._record_regrex.search(
                info_lines[idx].strip('\r\n'))
            if loaded_binary:
                break
        return loaded_binary.group(1)

    def stop(self):
        print "break in loader"
        loaded_candidate=_retrive_loaded_binary()
        if loaded_candidate != self._most_recently_loaded:
            self._most_recently_loaded = loaded_candidate
            if self._binary_info[self._most_recently_loaded]:
                for func_spec in self._binary_info[self._most_recently_loaded]:
                    _CallTracerBreakpoint(func_spec,func_spec,self._stack)

        return False

class _BreakSetupFromFile(gdb.Command):
    """ set up trace point from file """
    def __init__(self):
        super(_BreakSetupFromFile, self).__init__('setuptracepoint',
                                                  gdb.COMMAND_OBSCURE)
        self._stack=[]
        self._most_recently_loaded_binary=""

    def _load_binary_lst(self,filename):
        with open("binary.lst") as fh:
            
    def invoke(self, arg, from_tty):
        self._binary_trace_info=_load_binary_lst("binary.lst")
        # setup loader breaks
        gdb.execute("set pagination off")
        print "prepare from file done!"

_BreakSetupFromFile()
