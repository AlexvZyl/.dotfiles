from .backends.gum import *
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
        self.footer_list = []
        self.distribute_evenly = True
        self.backend = GumBackend()

    # Submit a component to be drawn on the next render.
    def submit(self, component: Component):
        self.component_list.append(deepcopy(component))

    # Submit a component to be rendered to the header section.
    def submit_header(self, component: Component):
        self.header_list.append(deepcopy(component))

    # Submit a component to be rendered to the footer section.
    def submit_footer(self, component: Component):
        self.footer_list.append(deepcopy(component))

    # Clear the renderer.
    def clear(self):
        self.canvas.clear()
        self.component_list = []

    # Clear the components in the header.
    def clear_header(self):
        self.header_list = []

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
        self.backend.render_empty_line(count)

    # Redraw to the canvas.
    def rerender(self):
        self.canvas.clear()
        self.canvas.update()
        self.render()

    # Render the text to the canvas.
    def render_text(self, text: Text):
        return self.backend.render_text(text, self.canvas)

    # Render the confirm widget to the canvas.
    def render_confirm(self, confirm: Confirm):
        return self.backend.render_confirm(confirm, self.canvas)

    # Render a list widget to the canvas.
    def render_list(self, list: List):
        return self.backend.render_list(list, self.canvas)

    # Render a spinner widget with a message.
    def render_script(self, spinner: Spinner):
        return self.backend.render_script(spinner, self.canvas)

    # Count the components that will be rendered at a time.
    # This is NOT the total amount of components in the list.
    def count_components(self):
        count = 0
        for comp in self.component_list:
            count += 1
            if type(comp) == Spinner:
                return count
        return count

    # Calculate the padding required to center all of the components.
    def calculate_padding(self):
        comps_height = self._calculate_components_height()
        avail_padding = self.canvas.height - comps_height - self._calculate_header_height() 
        padding =  floor( avail_padding / (self.count_components()+1) )
        return padding

    # Render all of the components to the terminal.
    def render(self):

        # Canvas things.
        self.canvas.clear()
        self.canvas.update()

        # Calculate the available padding.
        padding = self.calculate_padding()

        # Render the sections.
        self.backend.render_header(self.header_list, self.canvas)
        result = self.backend.render_body(self.component_list, self.canvas, self.distribute_evenly, padding)
        self.backend.render_footer(self.footer_list, self.canvas)
        return result
