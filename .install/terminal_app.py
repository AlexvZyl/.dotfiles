import subprocess
import gum
import colors
import shutil

def get_terminal_size():
    size = shutil.get_terminal_size()
    return size[0]-2, size[1]

# Get the color palette.
np = colors.get_nord_colors()

class TerminalApp:

    def __init__(self):

        # Terminal dimensions (c, r)
        self.term_size = get_terminal_size()

        # Setup header.
        self.header = gum.GumStyle("Nordic Arch Installation")
        self.header.has_border = True
        self.header.padding_y = 1
        self.header.width = self.term_size[0]
        self.header.bold = True
        self.header.text_color = np["white2"]
        
        # Credits.
        self.credits = gum.GumStyle("@AlexvZyl (alexandervanzyl@protonmail.com)")
        self.credits.italic = True
        self.credits.width = self.term_size[0]
        self.credits.text_color = np["white0"]
        self.credits.alignment = "right"

    def clear(self):
        subprocess.run(["clear"])
        self.header.exec()
        self.credits.exec()
        self.new_line(2)

    def query_arch(self):
        c = gum.GumConfirm("Are you on an Arch (btw) based platform?")
        c.width = self.term_size[0]
        c.exec()
        return True

    def exec(self, command, title = "Executing..."):
        spinner = gum.GumSpinner(command, title)
        spinner.exec()

    def new_line(self, count = 1):
        empty = gum.GumStyle("")
        for _ in range(count):
            empty.exec()
