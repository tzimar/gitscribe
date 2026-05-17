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
