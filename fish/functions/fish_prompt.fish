function fish_prompt
    set -l last_status $status

    # Show full path in prompt
    set -g fish_prompt_pwd_dir_length 0

    # Show git prompt
    set -g fish_prompt_show_git_prompt 1

    # https://github.com/fish-shell/fish-shell/blob/master/share/functions/__fish_git_prompt.fish
    set -g __fish_git_prompt_char_dirtystate ' ±'
    set -g __fish_git_prompt_char_invalidstate ' ✕'
    set -g __fish_git_prompt_char_stagedstate ' ●'
    set -g __fish_git_prompt_char_untrackedfiles ' …'
    set -g __fish_git_prompt_char_cleanstate ' ✓'
    set -g __fish_git_prompt_char_upstream_ahead ' ↑'
    set -g __fish_git_prompt_char_upstream_behind ' ↓'
    # set -g __fish_git_prompt_color_branch white
    set -g __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_showcolorhints
    set -g __fish_git_prompt_char_stateseparator ' |'

    # My colors
    # set -g fish_color_autosuggestion 444444
    set -g fish_color_command green '--bold'
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

    ## Line 1
    printf "\n"

    # SSH indicator
    if test -n "$SSH_TTY"
        set_color yellow
        printf '⚡ '
        set_color normal
    end

    # Working Directory
    set_color $fish_color_cwd
    printf '%s' (prompt_pwd)
    set_color normal

    # Git Prompt
    if test -n "$fish_prompt_show_git_prompt"
        printf '%s ' (__fish_git_prompt)
        set_color normal
    end

    ## Line 2
    printf "\n"
    # Exit Code
    if not test $last_status -eq 0
        set_color $fish_color_status
        printf "[$last_status]"
        printf " "
    end
    # Prompt indicator
    set_color yellow
    printf "❯"
    set_color normal
    printf " "
end
