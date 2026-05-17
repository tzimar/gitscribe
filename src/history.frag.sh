function History {
  function HistoryChanges {

        log=$(git log --format=">>>COMMIT %ad %ar" -p -U0)

        if ! echo "$log" | grep -q '>>>COMMIT '; then
            return
        fi

        echo "$log" | csplit -s - '%>>>COMMIT %' '/>>>COMMIT /' '{*}'
        perl -e 'for(@ARGV) { $old=$_; s/xx([0-9]+)/xxcommit$1/; rename($old, $_) if -e $old }' xx*
        commits=(xxcommit*)

        for commit in "${commits[@]}"; do
            commit="$(<$commit)"

            if [[ -z "$commit" ]]; then
                continue
            fi

            if ! echo "$commit" | grep -q 'diff --git a'; then
                continue
            fi

            timestamp_re=">>>COMMIT (.*) ago"
            if [[ "$commit" =~ $timestamp_re ]]; then
                timestamp=${BASH_REMATCH[1]}" ago"
            fi

            echo "--- "$'\033[35m'"$timestamp"$'\033[0m'" ---"

            echo "$commit" | csplit -s - '%diff --git a%' '/diff --git a/' '{*}'
            perl -e 'for(@ARGV) { $old=$_; s/xx([0-9]+)/xxfile$1/; rename($old, $_) if -e $old }' xx*
            files=(xxfile*)

            for file in "${files[@]}"; do
                file="$(<$file)"

                if [[ -z "$file" ]]; then
                    continue
                fi

                filename_re="diff --git a\/([a-zA-Z_.\/]+) b\/([a-zA-Z_.\/]+)"
                if [[ "$file" =~ $filename_re ]]; then
                    filename=${BASH_REMATCH[1]}
                fi
                echo "$filename"

                content=$(echo "$file" | grep -v -e '^[^+-]' -e '^$' -e '^---' -e '^+++')
                if [[ -n $content ]]; then
                    echo "$content" | awk '
                    {
                        # Extract the first character
                        first = substr($0, 1, 1)
                        if (first == "-") {
                            print "\033[31m" $0 "\033[0m"
                        } else if (first == "+") {
                            print "\033[32m" $0 "\033[0m"
                        } else {
                            # Default color
                            print $0
                        }
                    }'
                else
                    echo $'\033[33m'"<""$(echo "$file" | grep -v -e '^$' -e '^index' -e '^[+-]' -e '^diff' -e '^---' -e '^+++')"">"$'\033[0m'
                fi

                echo

            done

            rm xxfile*

        done
    }

    trap "rm xx*; sed -i '/xx*/d' .gitignore" EXIT

    echo "xx*" >> .gitignore
    HistoryChanges | less --RAW-CONTROL-CHARS
}
