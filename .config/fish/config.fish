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

# rice: commit + push one rice iteration (vxwm + kitty/xinitrc)
function rice --description "Commit + push one rice iteration (vxwm config.h + kitty theme)"
    if test (count $argv) -eq 0
        echo 'usage: rice "message"'
        return 1
    end
    set -l msg (string join " " -- $argv)

    pushd $HOME/vxwm
        git add config.h
        if not git diff --cached --quiet
            git commit -q -m $msg
            and git push -q origin main
            echo "[rice] vxwm: committed + pushed (codeberg)"
        else
            echo "[rice] vxwm: nothing to commit"
        end
    popd

    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" add "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/current-theme.conf" "$HOME/.xinitrc"
    if not git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" diff --cached --quiet
        git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" commit -q -m $msg
        echo "[rice] dotfiles: committed locally (dotfiles has no remote since GitHub repo deleted)"
    else
        echo "[rice] dotfiles: nothing to commit"
    end
end

# undo last rice: revert config.h + kitty theme to last committed
function rice-undo --description "Revert vxwm config.h + kitty theme to last committed version"
    git -C $HOME/vxwm checkout -- config.h
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout -- "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/current-theme.conf" "$HOME/.xinitrc"
    make -C $HOME/vxwm > /dev/null 2>&1; and echo "[rice-undo] reverted + rebuilt, restart to apply"
end
