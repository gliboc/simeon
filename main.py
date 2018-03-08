from cmd import Cmd
import utils

class Repl(Cmd):
    intro = "Welcome to the Simeon shell.     Type help or ? to list commands.\n"
    prompt = '|> '
    file = None

    # repl instructions
    def do_test(self, arg):
        print(arg)

    def do_load(self, arg):
        file = utils.read(arg)

    def do_show(self,arg):
        if file is None:
            print("There is no file loaded.")
        else:
            utils.print_csv(file)

    def do_clear(self):
        file = None

if __name__ == '__main__':
    Repl().cmdloop()