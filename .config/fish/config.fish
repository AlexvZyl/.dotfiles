if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Setup fish.
set fish_greeting "" 

#-------------#
# Setup tide. #
#-------------#

# Customize the right hand side.
set --universal tide_right_prompt_items status cmd_duration jobs time
set --universal tide_left_prompt_items os context pwd git newline character 

# Config style. 
set -g _tide_configure_style rainbow
 
# Prompt seperators.
set -g fake_tide_left_prompt_separator_diff_color 
set -g fake_tide_right_prompt_separator_diff_color 

# Tails.
set -g fake_tide_left_prompt_prefix ''
set -g fake_tide_right_prompt_suffix ''

# Heads.
set -g fake_tide_left_prompt_suffix 
set -g fake_tide_right_prompt_prefix 

# Height.
set fake_tide_left_prompt_frame_enabled true
set fake_tide_right_prompt_frame_enabled true

# Frame.
set fake_tide_left_prompt_frame_enabled false
set fake_tide_right_prompt_frame_enabled false

# Icons. 
set -p fake_tide_left_prompt_items os
set -g fake_tide_pwd_icon 
set -g fake_tide_pwd_icon_home 
set -g fake_tide_cmd_duration_icon 
set -g fake_tide_git_icon 

# Connection.
set -g fake_tide_prompt_icon_connection '·'
set -g fake_tide_prompt_color_frame_and_connection 444444

# Spacing.
set -g fake_tide_prompt_add_newline_before true

# 24h time format. 
set -g fake_tide_time_format %T
