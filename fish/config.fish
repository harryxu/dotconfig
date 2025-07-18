set -g fish_greeting

if type -q nvim
    export EDITOR='nvim'
    alias vim='nvim'
    alias vi='nvim'
end

if test -e ~/.local/bin
    fish_add_path -m ~/.local/bin
end

alias tmux='tmux -u'

# pyenv
set -Ux PYENV_ROOT $HOME/.pyenv
if test -e $PYENV_ROOT
    fish_add_path -m $PYENV_ROOT/bin
    pyenv init - | source
end

# bat command theme
set -Ux BAT_THEME ansi

if type -q zoxide
    zoxide init fish | source
end

# Bind fzf completions to ctrl-x
set -U fifc_keybinding \cn


if test "$TERM_PROGRAM" = ghostty -o "$TERM_PROGRAM" = xterm-kitty
    set -x TERM xterm-256color
end

starship init fish | source
