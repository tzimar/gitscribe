watcher_pause=false

function Watcher {

    if $watcher_pause; then
        return
    fi

    last_push_time=0
    while sleep $freq; do

        if ! AcquireLock "Watcher"; then
            continue
        fi 

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

        ReleaseLock "Watcher"
    done
}

function HandleCommand {
    parts=($1)
    command="${parts[0]}"

    until AcquireLock "Watcher"; do
        sleep 1
    done

    case $command in 
        exit | quit)
            stop_command_loop=1
            ;;
        help)
            CommandHelp
            ;;
        sync)
            SyncRepo
            ;;
        push)
            SyncRepo
            PushRepo
            ;;
        pause)
            watcher_pause=true
            ;;
        unpause)
            watcher_pause=false
            ;;
        history)
            History
            ;;
    esac
    ReleaseLock "CommandLoop"
}

function Main {

    InstallDependencies

    dir=$PWD
    init_repo=false
    freq=1

    history=false
    command=""

    push_mode=false
    push_freq=60

    while getopts "hlc:nd:f:p:" opt; do
        case $opt in
            h)
                ExecHelp
                exit
                ;;
            l)
                history=true
                ;;
            c)
                command="$OPTARG"
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

    CreateLock

    if [[ -n "$command" ]]; then
        HandleCommand "$command"
        exit
    fi
    
    AcquireLock "Main"
    CheckRepo
    SyncRepo
    ReleaseLock "Main"
    
    Watcher &
    watcher_pid=$!
    disown $watcher_pid
    Trap "kill -9 $watcher_pid" EXIT SIGINT SIGTERM

    stop_command_loop=0
    Trap "stop_command_loop=1" EXIT SIGINT SIGTERM
    while [[ $stop_command_loop -eq 0 ]]; do
        if read -p "gitscribe > " user_input; then
            HandleCommand "$user_input"
        fi
    done
}
