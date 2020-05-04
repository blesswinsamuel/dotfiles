source ~/.config/fish/aliases.fish

set -gx EDITOR "vim"
if test -n "$LANG"
  set -gx LANG en_US.UTF-8
end
if test -n "$LC_ALL"
  set -gx LC_ALL en_US.UTF-8
end

if test -n "$DISPLAY"
    set -gx EDITOR "subl -nw"
end

# Show full path in prompt
set -g fish_prompt_pwd_dir_length 0

# Show git prompt
set -g fish_prompt_show_git_prompt 1

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

if test -e ~/.config/fish/config.local.fish
  source ~/.config/fish/config.local.fish
end
