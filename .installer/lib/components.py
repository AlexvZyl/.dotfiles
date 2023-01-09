from abc import abstractmethod, update_abstractmethods
import subprocess
import shutil

# Basic definition of a rendered component.
class Component:

    def __init__(self):
        self.size = [0,0]
        self.padding = [0,0]
        self.margin = [0,0]
        self.has_border = False
        self.stretch_horizontal = False
        self.border_type = "thick"
        self.border_fg = "#FFFFFF"
        self.border_bg = ""
        self.text_fg = "#FFFFFF"
        self.text_bg = ""
        self.italic = False
        self.bold = False
        self.alignment = "center"
        self.width = 0

    # Update the component size based on features.
    @abstractmethod
    def update_dimensions(self):
        pass

# Render text only.
class Text(Component):

    def __init__(self, string):
        super().__init__()
        self.string = string
        self.update_dimensions()

    def update_dimensions(self):
        self.size[0] = self.padding[0]*2 + self.margin[0]*2 + len(self.string)
        self.size[1] = self.padding[1]*2 + self.margin[1]*2 + 1
        if self.has_border:
            self.size[0] += 2
            self.size[1] += 2

# Render a Yes/No widget with a message.
class Confirm(Component):

    def __init__(self, string):
        super().__init__()
        self.string = string
        self.button_fg = "#FFFFFF"
        self.button_bg = ""
        self.selected_button_fg = "#FFFFFF"
        self.selected_button_bg = ""
        self.update_dimensions()

    def update_dimensions(self):
        self.size[0] = self.padding[0]*2 + self.margin[0]*2 + len(self.string)
        self.size[1] = self.padding[1]*2 + self.margin[1]*2 + 3
        if self.has_border:
            self.size[0] += 2
            self.size[1] += 2

# Render a list with selection.
class List(Component):

    def __init__(self, items):
        super().__init__()
        self.limit = 1
        self.cursor_fg = "#FFFFFF"
        self.cursor_bg = ""
        self.cursor_bold = True
        self.items = items
        self.title = ""
        self.title_padding = 0
        self.title_blold = False
        self.title_italic = False
        self.title_fg = "#FFFFFF"
        self.title_bg = ""
        self.cursor = ">"
        self.update_dimensions()

    def update_dimensions(self):
        self.size[0] = self.padding[0]*2 + self.margin[0]*2 + self.widest_component()
        self.size[1] = self.padding[1]*2 + self.margin[1]*2 + len(self.items) + self.title_padding
        if self.has_border:
            self.size[0] += 2
            self.size[1] += 2
        if len(self.title) != 0:
            self.size[1] += 1

    # Calculate the widest component, inlcuding the list and message.
    def widest_component(self):
        widest_item = 0
        for item in self.items:
            cur_len = len(item)
            if widest_item < cur_len:
                widest_item = cur_len
        # A button is added here.
        if self.limit != 1:
            widest_item += 1
        return widest_item

# A spinner widget with a message.
class Spinner(Component):

    def __init__(self, script, message="Executing..."):
        super().__init__()
        self.string = message
        self.spinner_type = "dot"
        self.script = script
        self.spinner_fg = "#FFFFFF"
        self.update_dimensions()

    def update_dimensions(self):
        self.size[0] = self.padding[0]*2 + self.margin[0]*2 + 2 + len(self.string)
        self.size[1] = self.padding[1]*2 + self.margin[1]*2 + 1
        if self.has_border:
            self.size[0] += 2
            self.size[1] += 2

# Canvas to render to.
class Canvas():

    def __init__(self):
        self.width = 0
        self.height = 0
        self.padding = [0,0]

    # Update the canvas based on the current terminal dimentions.
    def update(self):
        size = shutil.get_terminal_size()
        self.width = size[0]-2 
        self.height = size[1]

    # Clear everything from the canvas.
    def clear(self):
        subprocess.run(["clear"])
