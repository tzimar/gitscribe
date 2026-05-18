function SyncRepo {

    if [[ -z "$remote" ]]; then
        return
    fi

    if RebaseInProgress; then
        echo "Please resolve conflicts."
        WatcherSetPause true
        WatcherSetRebasing true
        return
    fi

    if ! git fetch $remote &> /dev/null; then
        echo "Unable to fetch from remote."
        return
    fi

    if git merge-base --is-ancestor $remote_branch $local_branch; then
        git merge --ff-only $remote_branch &> /dev/null
    elif ! git rebase $remote_branch &> /dev/null; then
        echo "Local and remote are out of sync. Please resolve conflicts."
        notify-send -i error "Gitscribe" "Out of sync. Resolve conflicts."
        WatcherSetRebasing true
    fi
}
