from lib.colors import *
from lib.renderer import *
np = get_nord_colors()

class App:

    def __init__(self):
        self.renderer = Renderer()
        self.setup_header()
        self.os_list = ["Arch (btw)", "Debian", "Gentoo", "Slackware", "Windows (lol wut)"]
        self.component_list = [ "Core packages", "Dev packages", "Fish", "Polybar", "Wallpaper", "Rofi", "i3", "Neovim", "SDDM", "Refind" ]

    def run(self):
        self.render_welcome_screen()
        self.quit()

    def quit(self):
        self.renderer.clear()
        print("Cheers.")

    # Setup the application header.
    # This has to be called only once, since clearing the screen does not clear the header.
    def setup_header(self):
        header = Text("Nordic Installation Utility")
        header.has_border = True
        header.border_fg = np["cyan"]
        header.text_fg = np["white2"]
        header.padding = [0,1]
        self.renderer.submit_header(header)
        credits = Text("@AlexvZyl")
        credits.alignment = "right"
        credits.italic = True
        credits.text_fg = np["white0"]
        self.renderer.submit_header(credits)

    # Render the contents of the canvas.
    def render(self):
        return self.renderer.render()

    # Clear the cavnas and leave the header.
    def clear(self):
        self.renderer.clear()

    # Screen that shows then the app starts.
    def render_welcome_screen(self):
        # Welcome msg.
        welcome = Text("Welcome to the Nordic installation utility!\nI will help you install everything, or some specific components.")
        welcome.text_fg = np["white2"]
        # Warning.
        warning = Text("I will try to backup existing configs, but there is a chance that they will be ruined.")
        warning.text_fg = np["yellow"]
        warning.italic = True
        # Confirm box.
        confirm = Confirm("Do you wish to continue?")
        confirm.selected_button_bg = np["yellow"]
        confirm.selected_button_fg = np["black"]
        confirm.button_fg = np["white2"]
        confirm.button_bg = np["black"]
        confirm.alignment = "center"
        # Submit it all and render.
        self.renderer.submit(welcome)
        self.renderer.submit(warning)
        self.renderer.submit(confirm)
        result = self.render()
        # Parse result.
        if result:
            self.clear()
            self.query_os()
        else:
            self.quit()

    # Query from the user the OS he is using.
    def query_os(self):
        list = List(self.os_list)
        list.text_fg = np["white2"]
        list.cursor_fg = np["yellow"]
        list.title = "Please select your OS:"
        list.title_padding = 2
        list.title_blold = True
        list.cursor_bold = True
        self.renderer.submit(list)
        result = self.render()
        if result == self.os_list[0]: # Arch.
            self.query_use_case()
            pass
        else:
            error = Text(str(result) + " is not supported atm.  Sorry!")
            error.text_fg = np["red"]
            error.bold = True
            error.italic = True
            error.alignment = "center"
            self.clear()
            self.renderer.submit(error)
            self.render_welcome_screen()

    # Ask the user if they want to isntall everything, or just some components.
    def query_use_case(self):
        msg = Text("This utility can install everything that Nordic has to offer, or you can choose from a selection of components.")
        question = Text("What would you like to do?")
        options = ["Install everything.", "Select from a list of components."]
        list = List(options)
        list.cursor_fg = np["yellow"]
        self.clear()
        self.renderer.submit(msg)
        self.renderer.submit(question)
        self.renderer.submit(list)
        result = self.render()
        if result == options[0]:
            self.ensure_install_everything()
        else:
            self.query_install_components()

    # Make sure if the user wants to install everything if they selected it.
    def ensure_install_everything(self):
        warning = Text("You are about to install everything.")
        warning.italic = True
        warning.bold = True
        warning.text_fg = np["yellow"]
        confirm = Confirm("Are you sure?")
        confirm.bold = True
        confirm.selected_button_fg = np["black"]
        confirm.selected_button_bg = np["yellow"]
        confirm.button_bg = np["black"]
        confirm.button_fg = np["white2"]
        self.clear()
        self.renderer.submit(warning)
        self.renderer.submit(confirm)
        if self.render():
            return
        else:
            self.query_use_case()

    # Ask the user which components they want to install.
    def query_install_components(self):
        list = List(self.component_list)
        list.limit = 0
        list.cursor_fg = np["blue2"]
        list.selected_fg = np["yellow"]
        msg = Text("Please select the components to install:")
        msg.bold = True
        msg.text_fg = np["white2"]
        self.clear()
        self.renderer.submit(msg)
        self.renderer.submit(list)
        result = self.render()
        self.check_components(result)

    # Show the user what components they are going to install and if it is correct.
    def check_components(self, components):
        msg = Text("You are about to install:")
        msg.text_fg = np["white2"]
        msg.bold = True
        list = Text("")
        for comp in components:
            list.string += comp + ", "
        list.string = list.string[0:len(list.string)-2]
        confirm = Confirm("Are you sure?")
        confirm.selected_button_fg = np["black"]
        confirm.selected_button_bg = np["yellow"]
        confirm.button_bg = np["black"]
        confirm.button_fg = np["white2"]
        confirm.bold = True
        self.clear()
        self.renderer.submit(msg)
        self.renderer.submit(list)
        self.renderer.submit(confirm)
        if self.render():
            self.install_components(components)
        else:
            self.query_install_components()

    # Install the selected components.
    def install_components(self, components):
        msg = Text("Installing components.")
        msg.bold = True
        msg.text_fg = np["white2"]
        self.clear()
        self.renderer.submit(msg)
        spinner = Spinner(["sleep", "1"])
        spinner.spinner_fg = np["yellow"]
        spinner.text_fg = np["white2"]
        for comp in components:
            spinner.string = comp + "..."
            spinner.update_dimensions()
            self.renderer.submit(spinner)
        self.render()
