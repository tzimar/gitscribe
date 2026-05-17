InstallDependencies(){
    if [[ ! -f "/usr/local/bin/notify-send.exe" ]]; then
        notify_send_url="https://github.com/vaskovsky/notify-send/releases/download/v4.0.1/notify-send.exe.4.0.1.zip"
        notify_send_tmp_path=$(mktemp)
        curl -s -L "$notify_send_url" | funzip > "$notify_send_tmp_path"
        mv "$notify_send_tmp_path" /usr/local/bin/notify-send.exe
    fi
}
