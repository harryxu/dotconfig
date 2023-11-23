set -g fish_greeting

if type -q nvim
  export EDITOR='nvim'
  alias vim='nvim'
  alias vi='nvim'
end

starship init fish | source
