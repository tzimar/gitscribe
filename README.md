# Gitscribe

Gitscribe is a simple utility that creates a local Git repository, polls the working directory for changes, and automatically commits them. It's intended for use with simple, text-based files like manuscripts.

## Distribution

`gitscribe.sh` is self-extracting. Any necessary resources are stored in the `archive` folder of this repo. When they're modified, run `pack.sh` and copy the contents of `.archive.tar.b64` into the `archive` variable in `gitscribe.sh`. This will be made smoother later.