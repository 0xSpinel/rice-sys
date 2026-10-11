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

# dotfiles bare repo
alias dots="git --git-dir=/home/seku/.dotfiles --work-tree=/home/seku"
