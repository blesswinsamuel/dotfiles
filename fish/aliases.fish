alias show_git_prompt "set -g fish_prompt_show_git_prompt 1"
alias hide_git_prompt "set -e fish_prompt_show_git_prompt"

alias fix-dir-perms "find . -type d -exec chmod 755 '{}' \+"
alias fix-file-perms "find . -type f -exec chmod 644 '{}' \+"

alias youtube-dl-mp3 "youtube-dl --extract-audio --audio-format mp3"

alias ix "curl -F 'f:1=<-' ix.io"
alias flushdns "sudo killall -HUP mDNSResponder"
alias dc "docker-compose"
alias d "docker"
alias g "git"

# alias dlrshell "env PS1='\$ ' bash"

function mkcd
    mkdir -pv $argv;
    cd $argv;
end
alias cdr "cd (git rev-parse --show-toplevel)"

if type -q bat
  alias cat bat
end
if type -q prettyping
  alias ping 'prettyping --nolegend'
end
if type -q fzf
  # add support for ctrl+o to open selected file in subl
  set -x FZF_DEFAULT_OPTS "--bind='ctrl-o:execute(subl {})+abort'"

  # use fd instead of find
  if type -q fd
    set -x FZF_DEFAULT_COMMAND 'fd --type f'
  end

  # preview alias
  set FZF_PREVIEW_COMMAND 'head -100'
  if type -q bat
    set FZF_PREVIEW_COMMAND 'bat --line-range 0:100 --color always'
  end
  alias preview "fzf --preview '$FZF_PREVIEW_COMMAND {}'"
end
if type -q ncdu
  alias ncdu 'ncdu --color dark'
end

switch (uname)
case Darwin
  set -gx PATH /usr/local/sbin $PATH

  # Mac Quick Look
  alias ql "qlmanage -p"
  alias dont-index "touch .metadata_never_index"

  # cd to open Finder directory
  alias cdf "cd (osascript -e 'tell application \"Finder\" to get the POSIX path of (target of front window as alias)')"
case '*'
  # alias pbcopy 'xsel --clipboard --input'
  # alias pbpaste 'xsel --clipboard --output'
  alias pbcopy 'xclip -selection clipboard'
  alias pbpaste 'xclip -selection clipboard -o'
end

switch (uname)
case Darwin
  alias o "open"
case '*'
  alias open "xdg-open"
  alias o "xdg-open"
end

function git_dashboard
    fd '^\.git$' -H -x fish -c 'cd {//}; set -g __fish_git_prompt_show_informative_status; printf "%*s\r%s\n" '(tput cols)' (__fish_git_prompt) "{//}"'
end