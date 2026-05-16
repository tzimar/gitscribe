version="1.0.0"

main(){
    if [ ! -d .git ]; then
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

        git config --local include.path ../.gitconfig
        
        git commit --quiet --allow-empty --allow-empty-message -m "(root commit)"

    fi

    while sleep 1; do

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

    done
}

archive=""

main