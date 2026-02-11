# My dotfiles

This repo contains the dotfiles for my system.

## Requirements
Git and GNU Stow.

### Git
```
$ pacman -S git
```

### Stow
```
$ pacman -S stow
```

## Installation
Clone the repo to your home directory, cd into the cloned directory
and use stow to symlink the files.
```
$ git clone https://github.com/sagevik/dotfiles.git
$ cd dotfiles
$ stow <package>
```
### Example
To stow dotfiles for bash and zsh, use:
```
$ stow bash zsh
```

