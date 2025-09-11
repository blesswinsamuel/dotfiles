#alias python "/usr/bin/env python3"
#alias pip "/usr/bin/env pip3"

alias show_git_prompt "set -g fish_prompt_show_git_prompt 1"
alias hide_git_prompt "set -e fish_prompt_show_git_prompt"

alias fix-dir-perms "find . -type d -exec chmod 755 '{}' \+"
alias fix-file-perms "find . -type f -exec chmod 644 '{}' \+"

alias youtube-dl-mp3 "youtube-dl --extract-audio --audio-format mp3"

alias ix "curl -F 'f:1=<-' ix.io"
alias flushdns "sudo killall -HUP mDNSResponder"
abbr -g -a dc "docker compose"
abbr -g -a d docker
abbr -g -a p podman
abbr -g -a g git
abbr -g -a k kubectl
abbr -g -a o open
if type -q nvim
    abbr -g -a vim nvim
    abbr -g -a vi nvim
end
abbr -g -a cdssd "cd /Volumes/BleSSD/"
alias yqsd "yq e '.data | map_values(@base64d)'"
alias jqsd "jq '.data | map_values(@base64d)'"

alias nix-shell 'nix-shell --run fish'

function dockersize
    set -l image $argv
    podman manifest inspect -v "$name" | jq -c 'if type == "array" then .[] else . end' | jq -r '[ ( .Descriptor.platform | [ .os, .architecture, .variant, ."os.version" ] | del(..|nulls) | join("/") ), ( [ .SchemaV2Manifest.layers[].size ] | add ) ] | join(" ")' | numfmt --to iec --format '%.2f' --field 2 | sort | column -t
end

if type -q kubecolor
    function kubectl --wraps kubecolor --description 'alias kubectl to kubecolor'
        kubecolor $argv
    end
end

# set -g kubectl_path $(which kubectl)

# function kubectl --wraps $kubectl_path --description 'kubectl with context'
#     if test -z "$KUBECONTEXT"
#         $kubectl_path $argv
#     else
#         $kubectl_path --context $KUBECONTEXT $argv
#     end
# end

function kubectl-get-all-namespaced
    kubectl get (string join ',' (kubectl api-resources --namespaced --verbs list -o name)) $argv
    # kubectl -n $argv get (string join ',' (kubectl api-resources --namespaced --verbs list -o name))
end

# alias dlrshell "env PS1='\$ ' bash"

function mkcd
    mkdir -pv $argv
    cd $argv
end
alias cdr "cd (git rev-parse --show-toplevel)"

if type -q bat
    function cat --wraps bat --description 'alias cat to bat'
        bat $argv
    end
end
if type -q eza
    function ls --wraps eza --description 'alias ls to eza'
        eza --group $argv
    end
    # abbr -g -a ls eza
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

function sshrun --description 'run command over ssh'
    if test -z "$SSH_CLIENT"
        echo "Not an SSH session"
        return
    end
    set -l command (string replace "." "$PWD" $argv)
    set -l command (string replace "/mnt/bless-mac-mini-ssd-nfs" "/Volumes/BleSSD" $command)
    set -l sshusername blesswinsamuel
    set -l sshhost (string split -f1 ' ' "$SSH_CLIENT")
    set -l sshport (string split -f3 ' ' "$SSH_CLIENT")
    echo "Running command '$command' on host '$sshusername@$sshhost:$sshport'"
    ssh -p $sshport "$sshusername@$sshhost" $command
end

function clipboard-server
    echo 'Starting server on port 9630'
    while true
        nc -l localhost 9630 | pbcopy
        echo 'Received data'
    end
end

function remote-pbcopy
    nc -C localhost 9630
end

# function ssh-port-forward
#     # use mole instead
#     set -l name $argv[1]
#     set -l fwd_addr $argv[2]
#     set -l ssh_params $argv[3]
#     mkdir -p /tmp/portforwards
#     set -l sockfilename "/tmp/portforwards/$name.sock"
#     # ssh -N -L $fwd_addr $ssh_params
#     ssh -M -S $sockfilename -fNT -L $fwd_addr $ssh_params
# end

# function ssh-port-forward-stop
#     set -l name $argv[1]
#     mkdir -p /tmp/portforwards
#     set -l sockfilename "/tmp/portforwards/$name.sock"
#     ssh -S $sockfilename -O exit ''
# end
