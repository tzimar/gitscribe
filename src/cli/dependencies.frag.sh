function InstallWindowsDependencies {
  if ! where notify-send &>/dev/null; then
    tmp_path=$(mktemp)
    curl -s -L "https://github.com/vaskovsky/notify-send/releases/download/v4.0.1/notify-send.exe.4.0.1.zip" | funzip > "$tmp_path"
    mv "$tmp_path" /usr/local/bin/notify-send.exe
  fi
}

function InstallDependencies {
    case "$OSTYPE" in
      msys* | cygwin*)
        InstallWindowsDependencies
        ;;

      *)
        echo "$OSTYPE is not supported"
        exit
        ;;
    esac
}
