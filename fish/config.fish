set -gx EDITOR "vim"
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

if test -n "$DISPLAY"
    set -gx EDITOR "subl -nw"
end

set -g fish_prompt_pwd_dir_length 0

set -g fish_prompt_show_git_prompt 1
alias show_git_prompt "set -g fish_prompt_show_git_prompt 1"
alias hide_git_prompt "set -e fish_prompt_show_git_prompt"

alias fix-dir-perms "find . -type d -exec chmod 755 '{}' \+"
alias fix-file-perms "find . -type f -exec chmod 644 '{}' \+"

alias youtube-dl-mp3 "youtube-dl --extract-audio --audio-format mp3"

alias ix "curl -F 'f:1=<-' ix.io"

switch (uname)
case Darwin
	set -gx PATH /usr/local/sbin $PATH

	# Mac Quick Look
    alias ql "qlmanage -p"
	alias dont-index "touch .metadata_never_index"
case '*'
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
    # alias pbcopy='xclip -selection clipboard'
    # alias pbpaste='xclip -selection clipboard -o'
end

switch (uname)
case Darwin
    alias o "open"
case '*'
    alias open "xdg-open"
    alias o "xdg-open"
end

# My colors
# set -g fish_color_autosuggestion 444444
set -g fish_color_command green  '--bold'
set -g fish_color_comment normal
set -g fish_color_cwd white '--bold'
set -g fish_color_cwd_root red '--bold'
set -g fish_color_error red '--bold'
# set -g fish_color_escape cyan
# set -g fish_color_history_current cyan
# set -g fish_color_host '-o'  'cyan'
# set -g fish_color_match cyan
# set -g fish_color_normal normal
# set -g fish_color_operator 00afff
set -g fish_color_param cyan
# set -g fish_color_quote brown
# set -g fish_color_redirection normal
# set -g fish_color_search_match purple
set -g fish_color_status red
