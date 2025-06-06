# Only execute this file once per shell.
set -q __fish_config_sourced; and exit
set -g __fish_config_sourced 1

if status is-login
    # Login shell initialisation
    switch (uname)
        case Darwin
            # fix path variable order - https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
            # https://d12frosted.io/posts/2021-05-21-path-in-fish-with-nix-darwin.html
            fish_add_path --move --prepend --path "$HOME/.nix-profile/bin" "/etc/profiles/per-user/$USER/bin" /run/current-system/sw/bin /nix/var/nix/profiles/default/bin
            set fish_user_paths $fish_user_paths
    end
end

if status is-interactive
    # # add completions generated by Home Manager to $fish_complete_path
    # begin
    #     set -l joined (string join " " $fish_complete_path)
    #     set -l prev_joined (string replace --regex "[^\s]*generated_completions.*" "" $joined)
    #     set -l post_joined (string replace $prev_joined "" $joined)
    #     set -l prev (string split " " (string trim $prev_joined))
    #     set -l post (string split " " (string trim $post_joined))
    #     set fish_complete_path $prev "/Users/bsamuel/.local/share/fish/home-manager_generated_completions" $post
    # end

    source ~/.config/fish/aliases.fish
    source ~/.config/fish/env_vars.fish


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

    if type -q direnv
        direnv hook fish | source
    end

    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if type -q conda
        eval conda "shell.fish" hook $argv | source
    end

    if type -q mise
        mise activate fish | source
    end

    if test "$TERM" != dumb
        eval (starship init fish)
    end
end
