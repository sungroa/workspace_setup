# Workspace Setup

This repository contains my personal dotfiles and setup scripts. It uses **GNU Stow** to manage the dotfiles through symlinking.

## Setup Instructions

Simply clone the repository and run the setup script. This will install dependencies (including stow) and deploy the dotfiles to your home directory.

```bash
git clone <repository_url> workspace_setup
cd workspace_setup
./setup.sh
```

## Adding or Modifying Dotfiles

Since `stow` symlinks the files from this repository directly into your `~` (Home) directory, any changes you make to your dotfiles (e.g., editing `~/.bashrc`) are actually editing the files *in this repository*. 

1. Edit your dotfile (e.g. `vim ~/.bashrc`).
2. Navigate to this repository: `cd ~/git/workspace_setup`
3. Commit and push: `git commit -am "Updated bashrc" && git push`

To add a entirely **new** dotfile:
1. Move the file into the `home/` directory in this repository (e.g. `mv ~/.newdotfile ~/git/workspace_setup/home/`).
2. Run stow to create the symlink: `cd ~/git/workspace_setup && stow -v -t ~ home`
3. Commit the new file.
