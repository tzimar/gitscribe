ExecHelp(){
    echo "usage: gitscribe.sh [-h] [-l] [-c command] [-n] 
                              [-d directory] [-f frequency] 
                              [-p [frequency]]"
    echo
    echo "h     Help"
    echo "l     History"
    echo "c     Run command"
    echo "n     Create repository"
    echo "d     Set working directory"
    echo "f     Polling frequency (seconds)"
    echo "p     Enable push mode (automatically pushes to remote)"
}

CommandHelp(){
    echo "usage: <command> [<argument>...]"
    echo
    echo "exit/quit"
    echo "history"
    echo "sync          Pull changes from remote"
    echo "push          Push changes to remote"
    echo "pause         Pause repo watcher"
    echo "unpause       Unpause repo watcher"
}
