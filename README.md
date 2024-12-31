# Dotfiles Repository

use symlinks for better management of dotfiles

## Karabiner kemapping

[Karabiner README](./karabiner/README.md)

## Manual Installations

- app store apps
- setapp apps
- vscode extension

## VS code

- keybindings
- settings

## .zshrc

- z shell config, alias, functions

## BrewFile

auto install formulae and cask \
run following command from directory that `BrewFile` is located

```zsh
brew bundle
```

> caution: mactex require whole a lot of time, so install seperately

## Symlink creation

1. remove existing dotfiles (if they exist)

```zsh
rm -rf ~/.zshrc
rm -rf /Users/${USER}/.config/karabiner/karabiner.json
rm -rf /Users/${USER}/Library/Application\ Support/Code/User/settings.json
rm -rf /Users/${USER}/Library/Application\ Support/Code/User/keybindings.json
```

2. create symlink for dotfiles

```zsh
ln -s {path for repo clone}/.zshrc /Users/${USER}/.zshrc
ln -s {path for repo clone}/karabiner/karabiner.json /Users/${USER}/.config/karabiner/karabiner.json
ln -s {path for repo clone}/vscode/settings.json /Users/${USER}/Library/Application\ Support/Cursor/User/settings.json
ln -s {path for repo clone}/vscode/settings.json /Users/${USER}/Library/Application\ Support/Cursor/User/keybindings.json
```
