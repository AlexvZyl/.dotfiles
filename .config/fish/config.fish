# Fish.
set fish_greeting ""

# Pfetch.
set -gx PF_INFO "ascii title kernel os wm pkgs memory uptime"
set -gx PF_COL1 "4"
set -gx PF_COL2 "9"
set -gx PF_COL3 "1"

# Environment
source ~/.profile

# Setup with transience.
function starship_transient_prompt_func
  starship module character
end
function starship_transient_rprompt_func
  starship module time
end
starship init fish | source
enable_transience

# Previous simple setup.
# eval  $(starship init fish)
# echo "" &&  pfetch | sed 's/^/  /'
