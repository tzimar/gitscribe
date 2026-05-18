function SetupPipe {
  watcher_pipe="$(mktemp -d)/watcher_pipe"
  mkfifo "$watcher_pipe"
  exec 3<> "$watcher_pipe"
}

function WritePipe {
  echo "$1" >&3
}

function CheckPipe {
  read -t 0 -N 0 < "$watcher_pipe"
}

function ReadPipe {
  if CheckPipe; then
    read watcher_pipe_message < "$watcher_pipe"
    echo "$watcher_pipe_message"
  else
    echo ""
  fi
}
