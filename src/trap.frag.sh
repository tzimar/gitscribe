function Trap {
  trap_cmd="$1"
  shift
  function __ExtractTraps {
    echo "$3"
  }
  for trap_name in "$@"; do
    traps=$(eval "__ExtractTraps $(trap -p $trap_name)")
    if [[ -z "$traps" || "$traps" == "-" ]]; then
      trap -- "$trap_cmd" $trap_name
    else
      trap -- "$traps; $trap_cmd" $trap_name
    fi 
  done
}
