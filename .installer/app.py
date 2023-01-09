from lib.colors import *
from lib.renderer import *
np = get_nord_colors()

class App:

    def __init__(self):
        self.renderer = Renderer()
        self.setup_header()
        pass

    def setup_header(self):
        header = Text("Nordic Installation Utility")
        header.has_border = True
        header.border_fg = np["cyan"]
        header.text_fg = np["white2"]
        header.stretch_horizontal = True
        header.padding = [0,1]
        self.renderer.submit_header(header)
        credits = Text("@AlexvZyl (alexandervanzyl@protonmail.com)")
        credits.alignment = "right"
        credits.stretch_horizontal = True
        credits.italic = True
        credits.text_fg = np["white0"]
        self.renderer.submit_header(credits)

    def render(self):
        self.renderer.render()

    def render_welcome_screen(self):
        # Welcome msg.
        welcome = Text("Welcome to the Nordic installation utility!\nI will help you install everything, or some specific components.")
        welcome.text_fg = np["white2"]
        welcome.stretch_horizontal = True

        # Warning.
        warning = Text("I will try to backup existing configs, but there is a chance that they will be ruined.")
        warning.text_fg = np["yellow"]
        warning.italic = True
        warning.stretch_horizontal = True

        # Confirm box.
        confirm = Confirm("Do you wish to continue?")
        confirm.selected_button_bg = np["yellow"]
        confirm.selected_button_fg = np["black"]
        confirm.button_fg = np["white2"]
        confirm.button_bg = np["black"]
        confirm.alignment = "center"
        confirm.stretch_horizontal = True

        # Submit it all and render.
        self.renderer.submit(welcome)
        self.renderer.submit(warning)
        self.renderer.submit(confirm)
        self.render()
