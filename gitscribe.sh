version="2.1.1"

Help(){
    echo "usage: gitscribe.sh [-h] [-l] [-n] [-d directory] [-f frequency] [-p [frequency]]"
    echo
    echo "h     Help"
    echo "l     History"
    echo "n     Create repository"
    echo "d     Set working directory"
    echo "f     Polling frequency (seconds)"
    echo "p     Enable push mode (automatically pushes to remote)"
}

History(){
    HistoryChanges(){

        log=$(git log --format=">>>COMMIT %ad %ar" -p -U0)

        if ! echo "$log" | grep -q '>>>COMMIT '; then
            return
        fi

        echo "$log" | csplit -s - '%>>>COMMIT %' '/>>>COMMIT /' '{*}'
        perl -e 'for(@ARGV) { $old=$_; s/xx([0-9]+)/xxcommit$1/; rename($old, $_) if -e $old }' xx*
        commits=(xxcommit*)

        for commit in "${commits[@]}"; do
            commit="$(<$commit)"

            if [[ -z "$commit" ]]; then
                continue
            fi

            if ! echo "$commit" | grep -q 'diff --git a'; then
                continue
            fi

            timestamp_re=">>>COMMIT (.*) ago"
            if [[ "$commit" =~ $timestamp_re ]]; then
                timestamp=${BASH_REMATCH[1]}" ago"
            fi

            echo "--- "$'\033[35m'"$timestamp"$'\033[0m'" ---"

            echo "$commit" | csplit -s - '%diff --git a%' '/diff --git a/' '{*}'
            perl -e 'for(@ARGV) { $old=$_; s/xx([0-9]+)/xxfile$1/; rename($old, $_) if -e $old }' xx*
            files=(xxfile*)

            for file in "${files[@]}"; do
                file="$(<$file)"

                if [[ -z "$file" ]]; then
                    continue
                fi

                filename_re="diff --git a\/([a-zA-Z_.\/]+) b\/([a-zA-Z_.\/]+)"
                if [[ "$file" =~ $filename_re ]]; then
                    filename=${BASH_REMATCH[1]}
                fi
                echo "$filename"

                content=$(echo "$file" | grep -v -e '^[^+-]' -e '^$' -e '^---' -e '^+++')
                if [[ -n $content ]]; then
                    echo "$content" | awk '
                    {
                        # Extract the first character
                        first = substr($0, 1, 1)
                        if (first == "-") {
                            print "\033[31m" $0 "\033[0m"
                        } else if (first == "+") {
                            print "\033[32m" $0 "\033[0m"
                        } else {
                            # Default color
                            print $0
                        }
                    }'
                else
                    echo $'\033[33m'"<""$(echo "$file" | grep -v -e '^$' -e '^index' -e '^[+-]' -e '^diff' -e '^---' -e '^+++')"">"$'\033[0m'
                fi

                echo

            done

            rm xxfile*

        done
    }

    trap "rm xx*; sed -i '/xx*/d' .gitignore" EXIT

    echo "xx*" >> .gitignore
    HistoryChanges | less --RAW-CONTROL-CHARS
}

InstallDependencies(){
    if [[ ! -f "/usr/local/bin/notify-send.exe" ]]; then
        notify_send_url="https://github.com/vaskovsky/notify-send/releases/download/v4.0.1/notify-send.exe.4.0.1.zip"
        notify_send_tmp_path=$(mktemp)
        curl -s -L "$notify_send_url" | funzip > "$notify_send_tmp_path"
        mv "$notify_send_tmp_path" /usr/local/bin/notify-send.exe
    fi
}

UnpackArchive(){
    echo "$archive" | base64 -d > .gitscribe.tar
    tar -xf .gitscribe.tar
    rm .gitscribe.tar
}

InitRepo(){
    git init

    git config --global --add safe.directory $(pwd -P)

    UnpackArchive
    regex='.gitscribe(\..+)'
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

    history=false

    push_mode=false
    push_freq=60

    while getopts "hlnd:f:p:" opt; do
        case $opt in
            h)
                Help
                exit
                ;;
            l)
                history=true
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
    else
        if [ ! -f ".gitignore" ] || ! grep -q "gitscribe.sh" ".gitignore"; then
            # merge .gitignore files
            UnpackArchive
            cat .gitscribe.gitignore >> .gitignore
            rm .gitscribe.gitignore
        fi
    fi

    local_branch=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
    remote_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    remote=$(git config branch.$local_branch.remote)

    if $history; then
        History
        exit
    fi
    
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