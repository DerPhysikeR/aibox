# aibox

An isolated environment for secure local AI development.

## Quick start guide

Required dependencies:

- `qemu-system-x86_64`
- `ssh`
- `git`
- tinyproxy

optional dependencies:
- [Nix](https://nixos.org/)
- rsync

1. Run `./install.sh`
2. Append the path to your qcow2 image to `~/.config/aibox/qcowpath`, or if you don't have one, build it with:
   ```bash
   cd flake
   ./build.sh
   ```
3. Adapt the `connect` function in `aibox.sh` to your needs (it currently copies your neovim and tmux configurations into the VM)

From now on you can go into any git repository and run:
 - `aibox init` to set up a local copy for this specific repository
 - `aibox up` to start the VM
 - `aibox repoinit` to set up the git remote inside the VM and a working copy for the agent
 - `aibox connect` to connect to the VM over SSH to work on your project

## Architecture

This project only consists of a few wrapper scripts which run the agent inside
a VM using qemu, blocking all network access beside a local tinyproxy instance,
which supports a domain witelist or blacklist as well as audit logging, so you
can control and monitor the agent's network access.

It also offers a NixOS configuration from which you can build a reusable VM
image if you want.

There is no shared directory between the host and the VM to minimize the attack
surface, instead a bare git repo is created inside the VM which acts as a remote
for the host and the working copy of the agent.

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
