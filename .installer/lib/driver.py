import subprocess
from math import floor
from .components import Canvas, Text, Confirm, Spinner, List

def _execute(command, catch_output = False):
    if catch_output:
        return subprocess.run(command, stdout=subprocess.PIPE)
    else:
        return subprocess.run(command)

def render_empty_line(count = 1):
    # Do not render the lines!
    if count == 0: return 0
    command = [ "gum", "style" ]
    for _ in range(count):
        command.append("")
    return _execute(command)

# Render a style module from gum.
def render_gum_style(comp: Text, canvas: Canvas):
    command = [ "gum", "style" ]
    if comp.has_border:
        command.append("--border=" + comp.border_type)
        command.append("--border-foreground=" + comp.border_fg) 
    command.append("--padding=\"" 
                   + str(comp.padding[1]) + ' ' 
                   + str(comp.padding[0]) + "\"")
    command.append("--margin=\"" 
                   + str(comp.margin[1]) + ' ' 
                   + str(comp.margin[0]) + "\"")
    command.append("--align=" + comp.alignment)
    if comp.stretch_horizontal:
        command.append("--width=" + str(canvas.width))
    elif comp.width != 0:
        command.append("--width=" + str(canvas.width))
    if comp.bold:
        command.append("--bold")
    if comp.italic:
        command.append("--italic")
    command.append("--foreground=" + comp.text_fg)
    command.append(comp.string)
    return _execute(command)

# Render a confirm module from gum.
def render_gum_confirm(comp: Confirm, canvas: Canvas):
    command = [ "gum", "confirm", comp.string ]
    command.append("--affirmative=" + comp.affirmative)
    command.append("--negative=" + comp.negative)
    command.append("--prompt.align=" + comp.alignment)
    command.append("--prompt.foreground=" + comp.text_fg)
    if comp.stretch_horizontal:
        command.append("--prompt.width=" + str(canvas.width))
    elif comp.width != 0:
        command.append("--prompt.width=" + str(comp.width))
    if comp.bold:        
        command.append("--prompt.bold")
    if comp.italic:      
        command.append("--prompt.italic")
    command.append("--selected.background=" + comp.selected_button_bg)
    command.append("--selected.foreground=" + comp.selected_button_fg)
    command.append("--unselected.background=" + comp.button_bg)
    command.append("--unselected.foreground=" + comp.button_fg)
    if _execute(command).returncode ==0:
        return True
    return False

# Render a gum choose element.
def render_gum_choose(comp: List, canvas: Canvas):
    # Render the title.
    if comp.title != 0:
        title = Text(comp.title)
        title.bold = comp.title_blold
        title.italic = comp.title_italic
        title.text_bg = comp.title_bg
        title.text_fg = comp.title_fg
        title.alignment = comp.alignment
        title.width = comp.width
        title.stretch_horizontal = comp.stretch_horizontal
        render_gum_style(title, canvas)
        pass
    render_empty_line(comp.title_padding)
    # Render the list.
    command = [ "gum", "choose" ]
    if comp.limit == 0: 
        command.append("--no-limit")
    else:               
        command.append("--limit=" + str(comp.limit))
    command.append("--cursor.foreground=" + comp.cursor_fg)
    if comp.cursor_bold:
        command.append("--cursor.bold")
    for item in comp.items:
        command.append(item)
    # Alignment is tricky with this library...
    if comp.alignment == "center":
        widest_comp = comp.widest_component()
        # TODO: This is only if strech_horizontal is true.
        padding = floor((canvas.width-widest_comp)/2)
        cursor = ""
        for _ in range(padding-2):
            cursor += " "
        cursor += comp.cursor + " "
        command.append("--cursor=" + cursor)
    elif comp.alignment == "left":
        pass
    elif comp.alignment== "right":
        print("TODO: Gum choose right alignment.")
    return _execute(command, True).stdout.decode('utf-8')

# Render a gum spinner element.
def render_gum_spinner(comp: Spinner, canvas: Canvas):
    command = [ "gum", "spin" ]
    command.append("--spinner=" + comp.spinner_type)
    command.append("--title=" + comp.string)
    command.append("--title.foreground=" + comp.text_fg)
    command.append("--spinner.foreground=" + comp.spinner_fg)
    # Alignment is slightly tricky.
    # TODO: Consider comp.stretch_horizontal
    if comp.alignment == "center":
        padding = floor((canvas.width - comp.size[0]) / 2)
        command.append("--spinner.align=right")
        command.append("--spinner.width=" + str(padding))
        pass
    elif comp.alignment == "left":
        pass
    else:
        print("TODO: Gum spinner right align.")
    for arg in comp.script:
        command.append(arg)
    return _execute(command)
