set fish_greeting ""

# Environment
source ~/.profile

# Setup with transience.
# function starship_transient_prompt_func
#   starship module character
# end
# function starship_transient_rprompt_func
#   starship module time
# end
starship init fish | source
# enable_transience
