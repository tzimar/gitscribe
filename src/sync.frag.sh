SyncRepo(){

    if [[ -z "$remote" ]]; then
        return
    fi

    if ! git fetch $remote; then
        echo "Unable to fetch from remote."
        return
    fi

    if git merge-base --is-ancestor $remote_branch $local_branch; then
        git merge --ff-only $remote_branch
    elif ! git rebase $remote_branch; then
        echo "Local and remote are out of sync. Please resolve conflicts."
        notify-send -i error "Gitscribe" "Out of sync. Resolve conflicts."
        exit
    fi
}
