# -*- coding: utf-8 -*-
import re

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
    def __init__(self, spec,binary_info,stack):
        super(_CallTracerLoadBinaryBreakpoint, self).__init__(spec, 
                                                    gdb.BP_BREAKPOINT,
                                                    internal = False)
        self.silent=True
        self._last_loaded=""
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
        loaded_candidate=self._retrive_loaded_binary()
        if loaded_candidate != self._last_loaded:
            self._last_loaded = loaded_candidate
            print "Loading: %s" % self._last_loaded
            if self._binary_info.has_key(self._last_loaded) == True:
                for func_spec in self._binary_info[self._last_loaded]:
                    _CallTracerBreakpoint(func_spec,func_spec,self._stack)

        return False

class _BreakSetupFromFile(gdb.Command):
    """ set up trace point from file """
    def __init__(self):
        super(_BreakSetupFromFile, self).__init__('setuptracepointfromfile',
                                                  gdb.COMMAND_OBSCURE)
        self._stack=[]
        self._most_recently_loaded_binary=""

    def _load_binary_lst(self,filename):
        binary_trace_info={};
        token_state=r'FindOutHeader'
        binary_token_regrex=re.compile(r'^[Bb]inary:\s*([^\s]+)')
        record_sep_regrex=re.compile(r'^\s*$')
        comment_regrex=re.compile(r'^#')
        with open(filename) as fh:
            for ln in fh.readlines():
                ln = ln.strip('\r\n')
                if comment_regrex.search(ln):
                    continue
                if token_state == 'FindOutHeader':
                    found=binary_token_regrex.search(ln)
                    if found:
                        library_name=found.group(1)
                        if binary_trace_info.has_key('program_name') == False:
                            binary_trace_info['program_name']=library_name
                            print "setup program_name"

                        binary_trace_info[library_name]=[];
                        token_state='FindOutFuncs'
                    continue
                elif token_state == 'FindOutFuncs':
                    found=record_sep_regrex.search(ln)
                    if found:
                        token_state='FindOutHeader'
                        continue
                    else:
                        binary_trace_info[library_name].append(ln)

        return binary_trace_info;

    def _setup_program_breaks(self):
        program_name=self._binary_trace_info['program_name']
        for func_spec in self._binary_trace_info[program_name]:
            _CallTracerBreakpoint(func_spec,func_spec,self._stack)
            
    def invoke(self, arg, from_tty):
        self._binary_trace_info=self._load_binary_lst("binary.lst")
        # setup loader breaks
        gdb.execute("set pagination off")
        _CallTracerLoadBinaryBreakpoint("_dl_debug_state",
                                        self._binary_trace_info,
                                        self._stack)
        self._setup_program_breaks()        
        print "prepare from file done!"

_BreakSetupFromFile()
