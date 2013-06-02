# -*- coding: utf-8 -*-

class Php5func_info:
    """data store for tracking php5 execution"""
    def __init__(self):
        self.lineno=0
        self.funcname=0
        self.filename="NONE"
        self.scope=""
        self.functype="NONE"
        self.classname="NONE"

class _Php5ExecuterHook(gdb.Breakpoint):
    """ peeking debugging information """
    def __init__(self,spec):
        super(_Php5ExecuterHook, self).__init__(spec,
                                               gdb.BP_BREAKPOINT,
                                               internal=False)
        self._extended_value_dic={1: 'Zend_EVAL', 2: 'Zend_INCLUDE',
                                  4: 'Zend_INCLUDE_ONCE',
                                  8: 'Zend_REQUIRE',
                                  16: 'Zend_REQUIRE_ONCE'}

    def stop(self):
        # check filename
        php5info=Php5func_info()
        op_array=gdb.parse_and_eval("op_array")
        cur_exec=gdb.parse_and_eval("executor_globals.current_execute_data")
        php5info.filnename=op_array['filename']
        if (cur_exec != 0x0):
            if (cur_exec['op_array'] != 0x0):
                php5info.filename=cur_exec['op_array']['filename']
            elif (cur_exec['prev_execute_data'] != 0x0):
                php5info.filename=cur_exec['prev_execute_data']['op_array']['filename']

            func_state_func=cur_exec['function_state']['function']
            if (func_state_func['common']['function_name'] != 0x0):
                scope=gdb.parse_and_eval("executor_globals.scope")
                if (cur_exec['object'] != 0x0):
                    php5info.functype="MemberFunction"                
                    php5info.classname=func_state_func['common']['scope']['name']

                elif ((scope != 0x0) and 
                      (func_state_func['common']['scope'] != 0x0) and
                      (func_state_func['common']['scope']['name'] != 0x0)) :
                    php5info.functype="StaticMemberFunction"
                    php5info.classname=func_state_func['common']['scope']['name']
                else:
                    php5info.functype="NormalFunction"
                    
                if (func_state_func['common']['function_name'] != "{closure}" ):
                    php5info.funcname="{closeure:%s:%d-%d}" % 
                    (func_state_func['op_array']['filename'],
                     func_state_func['op_array']['line_start'],
                     func_state_func['op_array']['line_end'])
                else:
                    php5info.funcname=func_state_func['common']['function_name'] 
            else:
                extended_val=cur_exec['opline']['extended_value']
                if (self._extended_value_dic.has_key(extended_val) == True):
                    php5info.functype=self._extended_value_dic[extended_val]
                else:
                    php5info.functype="UnkownFunction"
            
        print "%s,%s,%s in %s" % (php5info.php5info.filename,php5info.functype,php5info.classname,php5info.funcname)
        return False

class _SetupAnalyzePhp5Executer(gdb.Command):
    """ setup php5 executer tracer """
    def __init__(self):
        super(_SetupAnalyzePhp5Executer, self).__init__('setupphp5executer',
                                                  gdb.COMMAND_OBSCURE)

    def invoke(self, arg, from_ttyp):
        gdb.execute("set pagination off")
        _Php5ExecuterHook("zend_vm_execute.h:400")

_SetupAnalyzePhp5Executer()
