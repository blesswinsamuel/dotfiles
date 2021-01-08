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

set -gx HOMEBREW_NO_AUTO_UPDATE 1

# brew - /usr/local/sbin /usr/local/bin
# pipx - ~/.local/bin
# go   - ~/go/bin
set -gx PATH $PATH /opt/homebrew/bin /usr/local/sbin /usr/local/bin ~/.local/bin ~/go/bin ~/bin

set PATH $PATH ~/.cargo/bin ~/.config/yarn/global/node_modules/.bin/

set PATH $PATH ~/.gem/ruby/2.7.0/bin
