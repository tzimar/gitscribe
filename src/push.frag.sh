function PushRepo {

    if [[ -z "$remote" ]]; then
        return
    fi

    if ! git push &> /dev/null; then
        echo "Unable to push to remote."
    fi
}
