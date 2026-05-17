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
