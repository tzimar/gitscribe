function UnpackArchive {
    echo "$archive" | base64 -d > .gitscribe.tar
    tar -xf .gitscribe.tar
    rm .gitscribe.tar
}
