# Dotfiles Repository

Use symlinks for better management of dotfiles. This repository provides automated setup via Makefile.

## Quick Setup

To set up everything at once:

```zsh
make all
```

## Karabiner kemapping

[Karabiner README](./karabiner/README.md)

Set up Karabiner configuration:

```zsh
make karabiner
```

## VS Code

Set up VS Code settings and keybindings:

```zsh
make vscode
```

Install VS Code extensions from the list:

```zsh
make vscode-ext
```

Export your current VS Code extensions to the list:

```zsh
make vscode-ext-export
```

## .zshrc

- z shell config, alias, functions

Set up zsh configuration:

```zsh
make zsh
```

Re-source your .zshrc file:

```zsh
make szsh
```

## SSH Wrapper

Set up SSH wrapper script (sc):

```zsh
make ssh
```

## Markdown to PDF Converter

Install the markdown to PDF conversion tool:

```zsh
make md2pdf
```

> caution: mactex requires a lot of time, so install separately