from abc import abstractmethod
from ..components import *

# Functions that the backend has to implement.
class Backend:
    
    @abstractmethod
    def render_text(self, component: Text):
        pass
    
    @abstractmethod
    def render_script(self, component: Spinner):
        pass
    
    @abstractmethod
    def render_confirm(self, component: Confirm):
        pass

    @abstractmethod
    def render_list(self, component: List):
        pass

    @abstractmethod
    def render_header(self, components):
        pass

    @abstractmethod
    def render_footer(self, components):
        pass
