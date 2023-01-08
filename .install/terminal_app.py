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

        # Calculate the title height.
        self.title_height = 2 + self.header.padding_y * 2 + self.header.margin_y * 2
        if self.header.has_border:
            self.title_height += 2

    def clear(self):
        subprocess.run(["clear"])
        self.header.render()
        self.credits.render()
        self.new_line(4)

    def query_arch(self):
        c = gum.GumConfirm("Are you on an Arch (btw) based platform?")
        c.width = self.term_size[0]
        c.render()
        return True

    def welcome_screen(self):
        text = gum.GumStyle("Welcome to the install utility!\nI will help you install everything, or anything specific.")
        text.alignment = "center"
        text.width = self.term_size[0]
        text.render()
        warning = gum.GumStyle("I will backup existing configs, but there is a small chance they will be ruined.")
        warning.text_color = np["yellow"]
        warning.alignment = "center"
        warning.italic = True
        warning.width = self.term_size[0]
        self.new_line(3)
        warning.render()
        proceed = gum.GumConfirm("Do you wish to proceed?")
        proceed.alignment = "center"
        proceed.width = self.term_size[0]
        proceed.bold = True
        self.new_line(2)
        proceed.render()

    def exec(self, command, title = "Executing..."):
        spinner = gum.GumSpinner(command, title)
        spinner.render()

    def new_line(self, count = 1):
        empty = gum.GumStyle("")
        for _ in range(count):
            empty.render()
