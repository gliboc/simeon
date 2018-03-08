from cmd import Cmd
import utils

# Used for persistent history
import os.path
try:
    import readline
except ImportError:
    readline = None

histfile = os.path.expanduser('~/.simeon_history')
histfile_size = 1000


class Repl(Cmd):
    intro = "Welcome to the Simeon shell.     Type help or ? to list commands.\n"
    prompt = '|> '
    file = None
    table = None

    # repl instructions
    def do_test(self, arg):
        print(arg)

    def do_load(self, arg):
        file = arg
        table = utils.read(arg)

    def do_show(self,arg):
        if table is None:
            print("There is no table loaded.")
        else:
            utils.print_csv(table)

    def do_clear(self):
        file = None
        table = None

    def do_drop(self):
        table = None

    def do_quit(self, arg):
        'Stops the repl and closes it'
        print('Thank you for using Simeon')
        self.close()
        bye()
        return True

    # File handling methods
    def close(self):
        if self.file:
            self.file.close()
            self.file = None

    # Determines behavior before and after loop.
    # Currently being used to have a persistent history.
    def preloop(self):
        if readline and os.path.exists(histfile):
         readline.read_history_file(histfile)

    def postloop(self):
        if readline:
            readline.set_history_length(histfile_size)
            readline.write_history_file(histfile)

if __name__ == '__main__':
    Repl().preloop()
    Repl().cmdloop()
    Repl().postloop()