#!/bin/sh

version="2.5.1"
output_dir=build
output=$output_dir/gitscribe.sh

archiveb64=$(tar -C archive -cf - . | base64)

sources=(
  "trap"

  "sync"
  "check"
  "push"

  "ip/lock"
  "ip/pipe"

  "cli/dependencies"
  "cli/archive"
  "cli/help"
  "cli/history"
  "cli/main"

  "watcher/interface"
  "watcher/main"
)

variables=(
  "version=\"$version\""
  "archive=\"$archiveb64\""
)

mkdir -p $output_dir
> $output
echo "#!/bin/sh" >> $output
echo "# Automatically generated" >> $output

for source in "${sources[@]}"; do
  cat src/$source.frag.sh >> $output
done

for variable in "${variables[@]}"; do
  echo "$variable" >> $output
done

echo 'Main "$@"' >> $output