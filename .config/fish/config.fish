#source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

alias ff="fastfetch"
alias mc="nohup /home/seku/.local/games/tlauncher/lib/jvm/jre/bin/java -Dfile.encoding=UTF8 -jar /home/seku/.local/games/tlauncher/starter-core.jar > /tmp/tlauncher.log 2>&1 &"

# Created by `pipx` on 2026-09-25 09:26:01
set PATH $PATH /home/seku/.local/bin

# rice: commit + push one rice iteration -> single dotfiles repo (rice-sys)
function rice --description "Commit + push one rice iteration (xinitrc + vxwm + kitty)"
    if test (count $argv) -eq 0
        echo 'usage: rice "message"'
        return 1
    end
    set -l msg (string join " " -- $argv)

    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add \
        "$HOME/.xinitrc" \
        "$HOME/vxwm/config.h" \
        "$HOME/.config/kitty/kitty.conf" \
        "$HOME/.config/kitty/current-theme.conf"
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add "$HOME/.config/fish/config.fish" 2>/dev/null
    if not git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" diff --cached --quiet
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" commit -q -m $msg
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" push -q origin master
        echo "[rice] rice-sys: committed + pushed"
    else
        echo "[rice] nothing to commit"
    end
end

# undo last rice: revert rice files to last committed + rebuild vxwm
function rice-undo --description "Revert rice files to last committed version"
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -- \
        "$HOME/.xinitrc" "$HOME/vxwm/config.h" \
        "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/current-theme.conf"
    make -C $HOME/vxwm > /dev/null 2>&1
    echo "[rice-undo] reverted + rebuilt, restart to apply"
end
