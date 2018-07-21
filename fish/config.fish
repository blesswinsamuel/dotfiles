set -gx EDITOR "vim"
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

if status --is-interactive
    set -gx EDITOR "subl -nw"
end

set -g fish_prompt_pwd_dir_length 0

set -g fish_prompt_show_git_prompt 1
alias show_git_prompt "set -g fish_prompt_show_git_prompt 1"
alias hide_git_prompt "set -e fish_prompt_show_git_prompt"

set -gx PATH /usr/local/sbin $PATH

alias fix-dir-perms "find . -type d -exec chmod 755 '{}' \+"
alias fix-file-perms "find . -type f -exec chmod 644 '{}' \+"

alias dont-index "touch .metadata_never_index"

alias youtube-dl-mp3 "youtube-dl --extract-audio --audio-format mp3"

# Mac Quick Look
alias ql "qlmanage -p"

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
