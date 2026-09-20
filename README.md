# aibox

An isolated environment for secure local AI development.

## Quick start guide

Required dependencies:

- [Nix](https://nixos.org/)
- `qemu-system-x86_64`
- `ssh`
- `git`
- tinyproxy

1. Build the base VM image:
   ```bash
   cd flake
   ./build.sh
   ```
2. Symlink `ln -s aibox.sh ~/.local/bin/aibox` or wherever your `$PATH` points to
3. Go to the working directory of a git repository and run:
   ```bash
   aibox init
   aibox up
   aibox connect
   ```

This will result in the following:

1. Builds a reusable NixOS qcow2 image and records its path in `~/.config/aibox/qcowpath`
2. Copies that image to `.aibox/aibox.qcow2` in your current git repository
3. Starts the VM with QEMU
4. Connects to it over SSH as `agent@localhost:2222`

That way, whatever the AI agent does, is isolated from your local environment.

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
