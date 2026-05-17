function PushRepo {

    if [[ -z "$remote" ]]; then
        return
    fi

    if ! git push; then
        echo "Unable to push to remote."
    fi
}
