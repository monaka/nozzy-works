import pydoc
class HelpViewer (gdb.Command):
  """ Greet the whole world """
  def __init__ (self):
     super(HelpViewer, self).__init__ ("pydoc",gdb.COMMAND_OBSCURE)
     self.help=pydoc.Helper()     

  def invoke (self,arg, from_tty):
     print self.help.help(str(arg))

HelpViewer()

