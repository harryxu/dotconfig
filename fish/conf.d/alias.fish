# ls -- eza version
if type -q eza
    function ls --wraps=eza --description 'ls -- eza version'
        eza $argv
    end
end

# ll -- eza version
if type -q eza
    function ll --wraps=eza --description 'ls -lh using eza'
        eza -lh $argv
    end
end
