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

## Why not just run it directly

Even if you turned off all abilities of the AI agent to modify your system in
any way, which depending on the harness might not even be possible, they can
still read all your files and exfiltrate them.

Repeatedly clicking "accept" to prompts, which might contain code you don't
fully understand, is not a good way to ensure security.

A good development process also works, when you are tired on a Friday evening
and just want to get your work done.
If it only works, when you are fully alert and focused, it is not a good
process.

## Why VMs and not containers

 - To develop container images, the agent needs to be able to build them, which
   is not always possible inside a container.
 - Nix, the best tool to ensure an identical development environment inside
   the sandbox, requires a systemd service which doesn't run inside a container.
 - VMs without a GUI are pretty light.
 - If your VM needs a GUI for the agent, it should definitely run inside a VM.
   That being said, if you need a GUI but the agent doesn't, you can always
   just use web based GUIs instead of installing a desktop environment inside
   the VM.
