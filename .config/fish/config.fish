if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Setup fish.
set fish_greeting "" 

#-------------#
# Setup tide. #
#-------------#

# Customize the right hand side.
set -g tide_right_prompt_items status cmd_duration jobs time
set -g tide_left_prompt_items os context pwd git newline character 

# Icons. 
set -g tide_git_icon 
set -g tide_status_icon_failure 
