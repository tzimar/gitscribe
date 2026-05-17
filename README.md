# Gitscribe

Gitscribe is a simple utility that polls the working directory for changes in a Git repo, and automatically commits them. It's intended for use with simple, text-based files like manuscripts.

Gitscribe currently only supports Windows.

## Development Setup

Run `git.sh` to configure your local repository after cloning.

## Build

The script is separated into a number of fragments in `src/` which must be built with `build.sh`. The output is `build/gitscribe.sh`.

## Distribution

`gitscribe.sh` is self-extracting. Any necessary resources are stored in the `archive` folder of this repo, and bundled when building the script.
