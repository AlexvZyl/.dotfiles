#---------#
# Imports #
#---------#

from abc import abstractmethod
import subprocess
import shutil
from math import floor

#------------#
# Components #
#------------#

# Basic definition of a rendered component.
class Component:

    def __init__(self):
        self.size = [0,0]
        self.padding = [0,0]
        self.margin = [0,0]
        self.has_border = False
        self.stretch_horizontal = False
        self.border_type = "thick"
        self.border_fg = "#000000"
        self.border_bg = "#000000"
        self.text_fg = "#000000"
        self.text_bg = "#000000"
        self.italic = False
        self.bold = False
        self.alignment = "center"

    # Update the component size based on features.
    @abstractmethod
    def update_dimensions(self):
        pass

# Render text only.
class Text(Component):

    def __init__(self, string):
        Component.__init__(self)
        self.string = string
        self.update_dimensions()

    def update_dimensions(self):
        self.size[0] = self.padding[0]*2 + self.margin[0]*2 + len(self.string)
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

#--------#
# Driver #
#--------#

def _execute(command):
    return subprocess.run(command)

def render_empty_line(count = 1):
    command = [ "gum", "style" ]
    for _ in range(count):
        command.append("")
    return _execute(command)

# Render a style module from gum.
def render_gum_style(comp: Text, canvas):
    command = [ "gum", "style" ]
    if comp.has_border:
        command.append("--border")
        command.append(comp.border_type)
        command.append("--border-foreground") 
        command.append(comp.border_fg) 
    command.append("--padding")
    command.append(str(comp.padding[1]) + ' ' + str(comp.padding[0]))
    command.append("--margin")
    command.append(str(comp.margin[1]) + ' ' + str(comp.margin[0]))
    command.append("--align")
    command.append(comp.alignment)
    if comp.stretch_horizontal:
        command.append("--width")
        command.append(str(canvas.width))
    if comp.bold:
        command.append("--bold")
    if comp.italic:
        command.append("--italic")
    command.append("--foreground")
    command.append(comp.text_fg)
    command.append(comp.string)
    return _execute(command)

#----------#
# Renderer #
#----------#

# Handles the rendering.
class Renderer:

    def __init__(self):
        self.canvas = Canvas()
        self.canvas.update()
        self.render_list = []
        self.header_list = []
        self.distribute_evenly = True

    # Submit a component to be drawn on the next render.
    def submit(self, component: Component):
        self.render_list.append(component)

    # Submit a component to be rendered to the header section.
    def submit_header(self, component: Component):
        self.header_list.append(component)

    # Clear the renderer.
    def clear(self):
        self.canvas.clear()
        self.render_list = []

    # Calculates the total height of all of the components.
    def _calculate_components_height(self):
        height = 0
        for comp in self.render_list:
            comp.update_dimensions()
            height += comp.size[1]
        return height

    # Calculate the height of the header components.
    def _calculate_header_height(self):
        height = 0
        for comp in self.header_list:
            comp.update_dimensions()
            height += comp.size[1]
        return height

    # Render vertical padding, or new lines.
    def vertical_padding(self, count):
        render_empty_line(count)

    # Redraw to the canvas.
    def rerender(self):
        self.canvas.clear()
        self.canvas.update()
        self.render()

    # Render the text to the canvas.
    def render_text(self, text: Text):
        render_gum_style(text, self.canvas)

    # Render all of the components to the terminal.
    def render(self):

        # Canvas things.
        self.canvas.clear()
        self.canvas.update()

        # Calculate the available padding.
        comps_height = self._calculate_components_height()
        avail_padding = self.canvas.height - comps_height - self._calculate_header_height() 
        padding =  floor( avail_padding / (len(self.render_list)+1) )

        # Render the header.
        for comp in self.header_list:
            if type(comp) == Text:
                self.render_text(comp)

        # Render the components.
        for (i, comp) in enumerate(self.render_list):
            if type(comp) == Text:
                render_empty_line(padding)
                self.render_text(comp)

#-----#
# EOF #
#-----#
