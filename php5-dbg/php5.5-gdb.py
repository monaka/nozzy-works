# -*- coding: utf-8 -*-

class _Php5ExecuterHook(gdb.Breakpoint):
    """ peeking execution """
    def __init__(self,spec):
        super(_Php5ExecuterHook, self).__init__(spec,
                                               gdb.BP_BREAKPOINT,
                                               internal=False)
        self._phpfile=(gdb.parse_and_eval("zend_get_executed_filename")).dereference()
        self._phpfunc=(gdb.parse_and_eval("get_active_function_name")).dereference()
        self._phplineno=(gdb.parse_and_eval("zend_get_executed_lineno")).dereference()
    def _get_exec_info(self):
        filename=((str(self._phpfile())).partition(' '))[2]
        funcname=((str(self._phpfunc())).partition(' '))[2]
        lineno=int(self._phplineno())
        return (funcname,filename,lineno)

    def stop(self):
        print "%s in %s:%d" % (self._get_exec_info())
        return False

class _SetupAnalyzePhp5Executer(gdb.Command):
    """ setup php5 executer tracer """
    def __init__(self):
        super(_SetupAnalyzePhp5Executer, self).__init__('setupphp5executer',
                                                  gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_ttyp):
        gdb.execute("set pagination off")
        _Php5ExecuterHook("zend_vm_execute.h:356")

_SetupAnalyzePhp5Executer()
