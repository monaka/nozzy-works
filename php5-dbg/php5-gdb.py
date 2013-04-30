# -*- coding: utf-8 -*-

class _Php5ExecuterHook(gdb.Breakpoint):
    """ peeking debugging information """
    def __init__(self,spec):
        super(_Php5ExecuterHook, self).__init__(spec,
                                               gdb.BP_BREAKPOINT,
                                               internal=False)
        
    def stop(self):
        current_frame = gdb.selected_frame()
        # check filename
        filename=(str(gdb.parse_and_eval("execute_data->op_array->filename")).split())[1]
        # check lineno
        lineno="NONE"
        if ( int(str(gdb.parse_and_eval("execute_data->opline")),0) != 0):
            lineno=gdb.parse_and_eval("execute_data->opline->lineno")

        #check what function within
        whereis=gdb.parse_and_eval("execute_data->function_state.function->common.function_name")
        if ( str(whereis) != "0x0" ):
            

            whereis=gdb.parse_and_eval("execute_data->opline->extended_value")

        print "%s:%s in %s" % (filename,lineno,whereis)
        return False

class _SetupAnalyzePhp5Executer(gdb.Command):
    """ setup php5 executer tracer """
    def __init__(self):
        super(_SetupAnalyzePhp5Executer, self).__init__('setupphp5executer',
                                                  gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_ttyp):
        gdb.execute("set pagination off")
        _Php5ExecuterHook("zend_vm_execute.h:410")

_SetupAnalyzePhp5Executer()
