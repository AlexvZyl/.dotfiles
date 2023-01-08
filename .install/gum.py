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
