function PushRepo {

    if [[ -z "$remote" ]]; then
        return
    fi

    if RebaseInProgress; then
        echo "Please resolve conflicts."
        WatcherSetPause true
        WatcherSetRebasing true
        return
    fi

    if ! git push &> /dev/null; then
        echo "Unable to push to remote."
    fi
}
