from abc import abstractmethod
from ..components import *

# Interface that a backend has to implement.
class Backend:
    
    @abstractmethod
    def render_text(self, component: Text, canvas: Canvas):
        pass
    
    @abstractmethod
    def render_script(self, component: Spinner, canvas: Canvas):
        pass
    
    @abstractmethod
    def render_confirm(self, component: Confirm, canvas: Canvas):
        pass

    @abstractmethod
    def render_list(self, component: List, canvas: Canvas):
        pass

    @abstractmethod
    def render_header(self, components, canvas: Canvas):
        pass

    @abstractmethod
    def render_body(self, components, canvas: Canvas, distribute_evenly, padding):
        pass

    @abstractmethod
    def render_footer(self, components, canvas: Canvas):
        pass

    @abstractmethod
    def render_empty_line(self, count = 1):
        pass
