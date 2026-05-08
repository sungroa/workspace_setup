# Workspace Setup

Personal dotfiles and cross-platform setup scripts, managed with **GNU Stow**. A single `./setup.sh` call installs dependencies and symlinks all dotfiles into `$HOME`.

## How It Works

1. **OS Detection** — `setup.sh` identifies Linux / macOS / Windows (Git Bash).
2. **Infrastructure** — the OS-specific script installs package managers, runtimes, and pinned tool versions from `versions.json`.
3. **Conflict Resolution** — existing files are backed up before Stow runs, preventing symlink collisions.
4. **Dotfile Deployment** — GNU Stow creates symlinks from `home/` → `$HOME` (falls back to `ln -snf` when Stow is unavailable).
5. **Agent Skills** — `setup_jetski.sh` installs the custom AI agent skills from `.agent/skills/` into the global agent directory.

> [!TIP]
> See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture details, dependency pinning, agent skill maintenance, and troubleshooting.

## Quick Start

```bash
git clone <repository_url> workspace_setup
cd workspace_setup
./setup.sh
```

## Managing Dotfiles

Because Stow creates real symlinks, editing a file in `$HOME` (e.g. `~/.bashrc`) **edits the file in this repo directly**. Just commit the change:

```bash
# Edit via your normal workflow, then commit
cd ~/git/workspace_setup
git commit -am "Updated bashrc" && git push
```

**To add a new dotfile:**

```bash
mv ~/.newdotfile ~/git/workspace_setup/home/
cd ~/git/workspace_setup
stow -v -t ~ home          # create the symlink
git add home/.newdotfile && git commit -m "Add .newdotfile"
```

## Repository Layout

```
workspace_setup/
├── home/               # Dotfile source of truth — stowed to $HOME
├── .agent/
│   └── skills/         # Custom AI agent skills (see DEVELOPMENT.md)
├── setup.sh            # Main entry point
├── setup_linux.sh      # Linux-specific provisioning
├── setup_mac.sh        # macOS-specific provisioning
├── setup_windows.sh    # Windows (Git Bash) provisioning
├── setup_jetski.sh     # Installs agent skills into the global agent dir
├── sync_skills.sh      # Copies skill changes back from global dir → repo
├── versions.json       # Pinned dependency versions (all platforms)
└── cleanup_backups.sh  # Removes old $HOME backup directories
```
