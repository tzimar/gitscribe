#!/bin/sh

version="2.3.4"
output_dir=build
output=$output_dir/gitscribe.sh

archiveb64=$(tar -C archive -cf - . | base64)

sources=(
  "dependencies"
  "lock"
  "archive"
  "trap"

  "help"
  "history"
  "sync"
  "check"
  "push"
  "main"
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