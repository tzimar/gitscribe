version="1.0.0"

Help(){
    echo "usage: gitscribe.sh [-h] [-n] [-d directory] [-f frequency] [-p [frequency]]"
    echo
    echo "h     Help"
    echo "n     Create repository"
    echo "d     Set working directory"
    echo "f     Polling frequency (seconds)"
    echo "p     Enable push mode (automatically pushes to remote)"
}

InstallDependencies(){
    if [[ ! -f "/usr/local/bin/notify-send.exe" ]]; then
        notify_send_url="https://github.com/vaskovsky/notify-send/releases/download/v4.0.1/notify-send.exe.4.0.1.zip"
        notify_send_tmp_path=$(mktemp)
        curl -s -L "$notify_send_url" | funzip > "$notify_send_tmp_path"
        mv "$notify_send_tmp_path" /usr/local/bin/notify-send.exe
    fi
}

InitRepo(){
    git init

    git config --global --add safe.directory $(pwd -P)

    # unpack archive
    echo "$archive" | base64 -d > .gitscribe.tar
    tar -xvf .gitscribe.tar
    rm .gitscribe.tar
    regex='dot(\..*)'
    for f in dot.*; do
        [[ $f =~ $regex ]] && mv "$f" "${BASH_REMATCH[1]}"
    done
    
    git commit --quiet --allow-empty --allow-empty-message -m "(root commit)"
}

CheckRepo(){
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
            git commit --quiet --allow-empty-message -m ""
        fi
    fi
}

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

PushRepo(){

    if [[ -z "$remote" ]]; then
        return
    fi

    if ! git push; then
        echo "Unable to push to remote."
    fi
}

Main(){

    InstallDependencies

    dir=$PWD
    init_repo=false
    freq=1

    push_mode=false
    push_freq=60

    while getopts "hnd:f:p:" opt; do
        case $opt in
            h)
                Help
                exit
                ;;
            n)
                init_repo=true
                ;;
            d)
                dir=$(realpath "$OPTARG")
                ;;
            f)
                freq=$OPTARG
                ;;
            p)
                push_mode=true
                push_freq=$OPTARG
                ;;
           \?)
                echo "Invalid option."
                exit
                ;;
        esac
    done

    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist."
        exit
    fi
    cd "$dir"

    if $init_repo; then
        if [ -d .git ]; then
            echo "A repository already exists."
            exit
        fi
        InitRepo
    elif [ ! -d .git ]; then
        echo "No repository in this directory."
        exit
    fi

    local_branch=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    remote=$(git config branch.$local_branch.remote)
    
    CheckRepo
    SyncRepo
    
    last_push_time=0
    while sleep $freq; do
        CheckRepo

        if $push_mode; then
            current_time=$(date +%s)
            d=$(( $current_time - $last_push_time ))
            if [[ "$d" -gt "$push_freq" ]]; then
                SyncRepo
                PushRepo
                last_push_time=$current_time
            fi
        fi
    done
}

archive=""

Main "$@"