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
