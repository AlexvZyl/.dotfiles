import subprocess
import colors
np = colors.get_nord_colors()

# Available spinner types include: 
# line, dot, minidot, jump, pulse, points,
# globe, moon, monkey, meter, hamburger.
class GumSpinner():

    def __init__(self, script, title):
        self.command = "spin"
        self.spinner_type = "dot"
        self.border = False
        self.exec_script = ""
        self.text_color = np["white2"]
        self.spinner_color = np["yellow"]
        self.script = script
        self.title = title
        self.alignment = "center"
        self.width = 0

    def render(self):
        command = [ "gum", "spin" ]
        command.append("--spinner")
        command.append(self.spinner_type)
        command.append("--title")
        command.append(self.title)
        command.append("--title.foreground")
        command.append(self.text_color)
        command.append("--spinner.foreground")
        command.append(self.spinner_color)
        command.append("--spinner.align")
        command.append(self.alignment)
        command.append("--title.align")
        command.append("left")
        if self.width != 0:
            # command.append("--spinner.width")
            # command.append(str(self.width))
            command.append("--title.width")
            command.append(str(self.width))
        for arg in self.script:
            command.append(arg)
        return subprocess.run(command)

# Yes/No?
class GumConfirm:

    def __init__(self, message):
        self.message = message
        self. width = 0
        self.alignment = "center"
        self.msg_foreground = np["white2"]
        self.selected_background = np["yellow"]
        self.selected_foreground = np["black"]
        self.bold = False

    def render(self):
        command = [ "gum", "confirm" ]
        command.append(self.message)
        command.append("--prompt.align")
        command.append(self.alignment)
        command.append("--prompt.foreground")
        command.append(self.msg_foreground)
        if self.width != 0:
            command.append("--prompt.width")
            command.append(str(self.width))
        if self.bold:
            command.append("--prompt.bold")
        command.append("--selected.background")
        command.append(self.selected_background)
        command.append("--selected.foreground")
        command.append(self.selected_foreground)
        return subprocess.run(command)

# Choose an item from the list.
class GumChoose:

    def __init__(self, list):
        self.list = list 
        self.limit = 0
        self.selected_foreground = np["blue2"]
        self.cursor_color = np["yellow"]
        self.bold_cursor = True

    def render(self):
        command = [ "gum", "choose" ]
        if self.limit == 0: 
            command.append("--no-limit")
        else:               
            command.append("--limit")
            command.append(str(self.limit))
        command.append("--selected.foreground")
        command.append(self.selected_foreground)
        command.append("--cursor.foreground")
        command.append(self.cursor_color)
        if self.bold_cursor:
            command.append("--cursor.bold")
        for item in self.list:
            command.append(item)
        return subprocess.run(command)
