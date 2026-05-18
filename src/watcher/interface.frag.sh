function WatcherSetPause {
    if [[ -n "$watcher_pid" ]]; then WritePipe "WatcherSetPause $@"; else
        watcher_paused=$1
        if ! $watcher_paused; then
            watcher_paused_for_rebase=false
        fi
    fi
}

function WatcherSetRebasing {
    if [[ -n "$watcher_pid" ]]; then WritePipe "WatcherSetRebasing $@"; else
        if $1; then
            if ! $watcher_paused; then
                WatcherSetPause true
                watcher_paused_for_rebase=true
            fi
        else
            if $watcher_paused_for_rebase; then
                WatcherSetPause false
            fi
        fi
    fi
}
