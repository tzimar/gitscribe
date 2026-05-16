version="1.0.0"

Help(){
    echo "usage: gitscribe.sh [-h] [-n] [-d directory] [-f frequency]"
    echo
    echo "h     Help"
    echo "n     Create repository"
    echo "d     Set working directory"
    echo "f     Polling frequency (seconds)"
}

InitRepo(){
    git init

    git config --global --add safe.directory $(pwd -P)

    # unpack archive
    echo "$archive" | base64 -d > .gitscribe.tar
    tar -xvf .gitscribe.tar
    rm .gitscribe.tar
    regex='dot(\..*)'
    for f in dot.*; do
        [[ $f =~ $regex ]] && mv "$f" "${BASH_REMATCH[1]}"
    done
    
    git commit --quiet --allow-empty --allow-empty-message -m "(root commit)"
}

CheckRepo(){
    msg=""

    new_files=($(git ls-files --others --exclude-standard))
    mod_files=($(git diff-index --name-only HEAD --))

    if [[ -n $new_files || -n $mod_files ]]; then

        # add new line to file endings
        all_files=( "${new_files[@]}" "${mod_files[@]}" )
        for file in "${all_files[@]}"; do
            sed -i '$a\' $file
            sed -i 's/$/\r/' $file
        done

        git add .
        if [[ -n "$(git status -s)" ]]; then
            git commit --quiet --allow-empty-message -m ""
        fi
    fi
}

Main(){

    dir=$PWD
    init_repo=false
    freq=1

    while getopts "hnd:f:" opt; do
        case $opt in
            h)
                Help
                exit
                ;;
            n)
                init_repo=true
                ;;
            d)
                dir=$(realpath "$dir/$OPTARG")
                ;;
            f)
                freq=$OPTARG
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
    fi

    while sleep $freq; do
        CheckRepo
    done
}

archive=""

Main "$@"