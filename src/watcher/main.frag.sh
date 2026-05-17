watcher_paused=false

function Watcher {

    last_push_time=0
    while sleep $freq; do

        case $(ReadPipe) in
          pause)
            watcher_paused=true
            ;;
          unpause)
            watcher_paused=false
            ;;
          *)
            ;;
        esac

        if $watcher_paused; then
          continue
        fi

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
