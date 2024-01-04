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

# brew - /usr/local/sbin /usr/local/bin
# pipx - ~/.local/bin
# go   - ~/go/bin
set -gx PATH ~/bin /opt/homebrew/bin $PATH /usr/local/sbin /usr/local/bin ~/.local/bin ~/go/bin
set -gx PATH $PATH "$(brew --prefix)/opt/python/libexec/bin"  # unversioned python binaries

set -gx PATH $PATH ~/.cargo/bin ~/.config/yarn/global/node_modules/.bin/

set -gx PATH $PATH ~/.gem/ruby/2.7.0/bin

set -gx PATH $PATH ~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/

set -gx PATH $PATH ~/.krew/bin

set -gx PATH $PATH "/Applications/IntelliJ IDEA.app/Contents/MacOS"

