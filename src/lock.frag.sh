lock_dir=""
verbose_lock=false

function LogLock {
  if $verbose_lock; then
    echo "[Lock] $1"
  fi
}

function CreateLock {
  lock_dir="$(mktemp -d)/.gitscribe.lock"
  LogLock "Lock dir is '$lock_dir'"
}

function AcquireLock {

    if [[ -z "$lock_dir" ]]; then
      LogLock "Lock does not exist."
      return 1
    fi

    if mkdir "$lock_dir" 2>/dev/null; then
        LogLock "$1 acquired lock."
        Trap "LogLock \"Released lock in emergency.\"" EXIT SIGINT SIGTERM
        Trap "rm -rf \"$lock_dir\"" EXIT SIGINT SIGTERM
        return 0
    else
        LogLock "$1 failed to acquire lock."
        return 1
    fi
}

function ReleaseLock {
    LogLock "$1 released lock" 
    rm -rf "$lock_dir"
}
