from .driver import *
from .components import *
from math import floor
from copy import deepcopy

# Handles the rendering.
class Renderer:

    def __init__(self):
        self.canvas = Canvas()
        self.canvas.update()
        self.component_list = []
        self.header_list = []
        self.distribute_evenly = True

    # Submit a component to be drawn on the next render.
    def submit(self, component: Component):
        self.component_list.append(deepcopy(component))

    # Submit a component to be rendered to the header section.
    def submit_header(self, component: Component):
        self.header_list.append(deepcopy(component))

    # Clear the renderer.
    def clear(self):
        self.canvas.clear()
        self.component_list = []

    # Calculates the total height of all of the components.
    def _calculate_components_height(self):
        height = 0
        for comp in self.component_list:
            comp.update_dimensions()
            height += comp.size[1]
            # Should be able to have more than one spinner per render.
            # In gum they replace each other, so do not count all of their heights.
            if type(comp) == Spinner: break
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

    # Render the confirm widget to the canvas.
    def render_confirm(self, confirm: Confirm):
        render_gum_confirm(confirm, self.canvas)

    # Render a list widget to the canvas.
    def render_list(self, list: List):
        render_gum_choose(list, self.canvas)

    # Render a spinner widget with a message.
    def render_spinner(self, spinner: Spinner):
        render_gum_spinner(spinner, self.canvas)

    # Render all of the components to the terminal.
    def render(self):

        # Canvas things.
        self.canvas.clear()
        self.canvas.update()

        # Calculate the available padding.
        comps_height = self._calculate_components_height()
        avail_padding = self.canvas.height - comps_height - self._calculate_header_height() 
        padding =  floor( avail_padding / (len(self.component_list)+1) )

        # Render the header.
        for comp in self.header_list:
            if type(comp) == Text:
                self.render_text(comp)
            else:
                print("Bruh why is there an interactive element in the header?")

        # Render the components.
        for (i, comp) in enumerate(self.component_list):
            if type(comp) == Text:
                if self.distribute_evenly: render_empty_line(padding)
                self.render_text(comp)
            elif type(comp) == Confirm:
                if self.distribute_evenly: render_empty_line(padding-1)
                self.render_confirm(comp)
            elif type(comp) == List:
                if self.distribute_evenly: render_empty_line(padding)
                self.render_list(comp)
            elif type(comp) == Spinner:
                if self.distribute_evenly: render_empty_line(padding)
                self.render_spinner(comp)
