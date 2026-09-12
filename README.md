# aibox

An isolated environment for secure local AI development. 

## Quick start guide

[podman](https://podman.io/) is a required dependency.

1. Clone this repository
2. Symlink `ln -s aibox.sh ~/.local/bin/aibox` or wherever your $PATH points to
3. Either symlink `ln -s aibox/Containerfile ~/.aibox/Containerfile` or create your own Containerfile
4. Go to the working directory of a git repository and run `aibox`

This will result in the following:

1. Copies your current git working directory to `~/.local/share/aibox/aibox-$(date +%Y%m%d-%H%M%S)`
2. Adds that directory as a remote to your current git repository
3. Creates a container from the Containerfile, runs it and mounts the copied directory into it

That way, whatever the AI agent does, is completely isolated from your local
environment, but you can easily fetch changes from it.

## Cleanup

If you use it often you will accumulate a bunch of remotes in your git repository.
You can remove them with the following command:

`git remote -v | grep aibox | xargs -n1 git remote remove`
