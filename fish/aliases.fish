alias show_git_prompt "set -g fish_prompt_show_git_prompt 1"
alias hide_git_prompt "set -e fish_prompt_show_git_prompt"

alias fix-dir-perms "find . -type d -exec chmod 755 '{}' \+"
alias fix-file-perms "find . -type f -exec chmod 644 '{}' \+"

alias youtube-dl-mp3 "youtube-dl --extract-audio --audio-format mp3"

alias ix "curl -F 'f:1=<-' ix.io"
alias flushdns "sudo killall -HUP mDNSResponder"
abbr -g -a dc "docker compose"
abbr -g -a d docker
abbr -g -a g git
abbr -g -a k kubectl
abbr -g -a o open

# alias dlrshell "env PS1='\$ ' bash"

function mkcd
    mkdir -pv $argv
    cd $argv
end
alias cdr "cd (git rev-parse --show-toplevel)"

if type -q bat
    abbr -g -a cat bat
end
if type -q exa
    function ls --wraps exa --description 'alias ls to exa'
        exa $argv
    end
    # abbr -g -a ls exa
end
if type -q prettyping
    function ping --wraps prettyping --description 'alias ping to prettyping'
        prettyping --nolegend $argv
    end
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
        # keep open alias
    case '*'
        alias open xdg-open
end

alias fish-reload "source ~/.config/fish/config.fish"

function git-dashboard
    fd '^\.git$' -H -x fish -c 'cd {//}; set -g __fish_git_prompt_show_informative_status; printf "%*s\r%s\n" '(tput cols)' (__fish_git_prompt) "{//}"'
end

function git-fetch-all
    fd '^\.git$' -H -x fish -c 'git -C {//} fetch'
end

alias urldecode 'python -c "import sys, urllib as ul; print(ul.unquote_plus(sys.argv[1]))"'
alias urlencode 'python -c "import sys, urllib as ul; print(ul.quote_plus(sys.argv[1]))"'
function git-open
    set -l giturl (git config --get remote.origin.url)
    if test -z "$giturl"
        echo "Not a git repository or no remote.origin.url set"
        return
    end

    set -l giturl (echo $giturl | sed 's/git@/http:\/\//' | sed 's/com:/com\//')
    set -l giturl (string replace ".git" "" $giturl)
    set -l branch (git branch --show-current)
    set -l giturl $giturl/tree/$branch
    open $giturl
end

function ssh-port-forward
    # use mole instead
    set -l name $argv[1]
    set -l fwd_addr $argv[2]
    set -l ssh_params $argv[3]
    mkdir -p /tmp/portforwards
    set -l sockfilename "/tmp/portforwards/$name.sock"
    # ssh -N -L $fwd_addr $ssh_params
    ssh -M -S $sockfilename -fNT -L $fwd_addr $ssh_params
end

function ssh-port-forward-stop
    set -l name $argv[1]
    mkdir -p /tmp/portforwards
    set -l sockfilename "/tmp/portforwards/$name.sock"
    ssh -S $sockfilename -O exit ''
end
