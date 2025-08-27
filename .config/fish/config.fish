source ~/.profile

set fish_greeting ""

# config.fish
function starship_transient_prompt_func
	tput cuu1
	starship module character
end

function prompt_newline --on-event fish_postexec
	echo
end

alias clear "command clear; commandline -f clear-screen"

# Integrations.
starship init fish | source
zoxide init fish | source
