# -*- coding: utf-8 -*-

class _Php5ExecuterHook(gdb.Breakpoint):
    """ peeking execution """
    def __init__(self,mode,*args):
        super(_Php5ExecuterHook, self).__init__("zend_vm_execute.h:356",
                                               gdb.BP_BREAKPOINT,
                                               internal=False)
        self._phpfile=(gdb.parse_and_eval("zend_get_executed_filename")).dereference()
        self._phpfunc=(gdb.parse_and_eval("get_active_function_name")).dereference()
        self._phplineno=(gdb.parse_and_eval("zend_get_executed_lineno")).dereference()
        self._mode=mode
        if (mode == "break"):
            

    def _get_exec_info(self):
        filename=((str(self._phpfile())).partition(' '))[2]
        funcname=((str(self._phpfunc())).partition(' '))[2]
        lineno=int(self._phplineno())
        return (funcname,filename,lineno)

    def stop(self):
        if (self._mode == "trace"):
            print "%s in %s:%d" % (self._get_exec_info())
            return False
        elif (self._mode == "break"):
            (funcname,filename,lineno) == self._get_exec_info()
            

class _SetupAnalyzePhp5Executer(gdb.Command):
    """ setup php5 executer tracer """
    def __init__(self):
        super(_SetupAnalyzePhp5Executer, self).__init__('setupphp5executer',
                                                  gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_ttyp):
        gdb.execute("set pagination off")
        _Php5ExecuterHook("trace")


class _BreakpointOnPHP(gdb.Command):
    """ setup breakpoint on PHP Source """
    def __init__(self):
        super(__BreakpointOnPHP, self).__init__('breakphp',
                                                  gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_ttyp):
        gdb.execute("set pagination off")
        _Php5ExecuterHook("break")


_SetupAnalyzePhp5Executer()
