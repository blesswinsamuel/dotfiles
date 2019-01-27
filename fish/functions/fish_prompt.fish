function fish_prompt
  set -l last_status $status

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

  printf "\n"
  if test -n "$SSH_TTY"
    set_color yellow
    printf '⚡ '
    set_color normal
  end

  set_color $fish_color_cwd
  printf '%s' (prompt_pwd)
  set_color normal

  if test -n "$fish_prompt_show_git_prompt"
    printf '%s ' (__fish_git_prompt)
    set_color normal
  end

  printf "\n"

  set_color yellow
  if not test $last_status -eq 0
    set_color $fish_color_status
    printf "[$last_status]"
    printf " "
  end
  printf "❯"
  set_color normal
  printf " "
end
