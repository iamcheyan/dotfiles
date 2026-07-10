#!/bin/bash

cmd=$(tmux display-message -p '#{pane_current_command}')

case "$cmd" in
    vim|nvim)
        echo "VIM | hjkl Move | / Search | :w Save | :q Quit"
        ;;
    less|more)
        echo "j/k Move | / Search | n Next | q Quit"
        ;;
    htop|btop|top)
        echo "F3 Search | F6 Sort | F10 Exit"
        ;;
    man)
        echo "/ Search | n Next | N Prev | q Quit"
        ;;
    ssh)
        echo "SSH | ~. Disconnect | ~? Help"
        ;;
    git)
        echo "Git | q Quit | Space Stage | - Unstage"
        ;;
    *)
        echo "C-b c New | C-b % VSplit | C-b \" HSplit | C-b z Zoom"
        ;;
esac
