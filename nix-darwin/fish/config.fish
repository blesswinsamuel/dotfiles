if status is-interactive
    if type -q direnv
        direnv hook fish | source
    end

    if type -q starship
        starship init fish | source
    end

    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if type -q conda
        eval conda "shell.fish" hook $argv | source
    end
end


# My colors
# set -g fish_color_autosuggestion 444444
set -g fish_color_command green --bold
set -g fish_color_comment normal
set -g fish_color_cwd white --bold
set -g fish_color_cwd_root red --bold
set -g fish_color_error red --bold
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
