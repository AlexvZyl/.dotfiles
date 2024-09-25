source ~/.profile

set fish_greeting ""

if status is-interactive
	function newline --on-event fish_postexec
        if test "$argv[1]" != "clear" && test "$argv[1]" != "c"
            echo
        end
	end
end

starship init fish | source
