set -gx EDITOR vim
if test -n "$LANG"
    set -gx LANG en_US.UTF-8
end
if test -n "$LC_ALL"
    set -gx LC_ALL en_US.UTF-8
end

if test -z "$SSH_CLIENT"
    set -gx EDITOR "subl -nw"
    switch (uname)
        case Darwin
            # set -gx EDITOR "zed -w"
    end
end

set -gx HOMEBREW_NO_INSTALL_UPGRADE 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# set -gx VOLTA_HOME "$HOME/.volta"

# set -gx PATH "$VOLTA_HOME/bin" $PATH
