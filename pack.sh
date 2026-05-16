b64=$(tar -C archive -cvf - . | base64)
f='archive="[-A-Za-z0-9+\/=\r\n]*"'
r='archive="'"$b64"'"'
perl -0777 -i -pe 's/'"$f"'/'"$r"'/gs' gitscribe.sh