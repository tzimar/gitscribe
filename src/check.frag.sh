function RebaseInProgress {
    if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
        return 0
    else
        return 1
    fi
}

function CheckRepo {

    if RebaseInProgress; then
        echo "Please resolve conflicts."
        WatcherSetPause true
        WatcherSetRebasing true
        return
    fi

    msg=""

    new_files=($(git ls-files --others --exclude-standard))
    mod_files=($(git diff-index --name-only HEAD --))

    if [[ -n $new_files || -n $mod_files ]]; then

        # add new line to file endings
        all_files=( "${new_files[@]}" "${mod_files[@]}" )
        for file in "${all_files[@]}"; do
            sed -i '$a\' $file
            sed -i 's/$/\r/' $file
        done

        git add .
        if [[ -n "$(git status -s)" ]]; then
            git commit --quiet -m "${all_files[@]}"
        fi
    fi
}
