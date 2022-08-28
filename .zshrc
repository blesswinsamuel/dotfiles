export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/opt/homebrew/bin"

if type "starship" > /dev/null; then
	eval "$(starship init zsh)"
fi
