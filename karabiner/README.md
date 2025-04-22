# Karabiner Elements Custom Configuration

## Overview

This setup creates a powerful keyboard shortcut system using custom modifiers and layers for **aerospace**:

- **Utility Hyper Key**: Caps Lock is remapped to function as Escape when tapped, and as a "Utility Hyper" modifier when held
- **Window Hyper Key**: Tab is remapped to function as Tab when tapped, and as a "Window Hyper" modifier when held
- **Right Command**: Remapped to F18 for additional customization options

## Key Features

> Window management is acheived using **aerospace**

### Utility Hyper Key (Caps Lock)

- **Window Focus**: `Hyper + j/k/l/i` → Focus window left/down/right/up
- **Service/Exec Mode**: `Hyper + semicolon/o` → Switch to service/exec mode
- **Arrow Keys Sublayer**: `Hyper + s` activates a sublayer where:
  - `j/k/l/i` → Left/Down/Right/Up arrows
  - `h/semicolon` → Option+Left/Right arrows for word jumping

### Window Hyper Key (Tab)

- **Window Movement**: `Window-Hyper + j/k/l/i` → Move window left/down/right/up
- **Window Management**: 
  - `Window-Hyper + f` → Toggle fullscreen
  - `Window-Hyper + slash` → Toggle tiling
  - `Window-Hyper + comma` → Toggle accordion mode
  - `Window-Hyper + -/=` → Resize smart -50/+50
- **Desktop Navigation**: `Window-Hyper + 1-8` → Switch to desktop 1-8
- **Window Join Sublayer**: `Window-Hyper + w` activates a sublayer where:
  - `j/k/l/i` → Join window left/down/right/up
- **Window to Workspace Sublayer**: `Window-Hyper + m` activates a sublayer where:
  - `1-8` → Move window to desktop 1-8 and follow

## Requirements

- [Karabiner Elements](https://karabiner-elements.pqrs.org/) installed
- [Aerospace](https://github.com/nikitabobko/AeroSpace) installed

## Setup

1. Install Karabiner Elements
2. Run the following command to create symlinks:
```bash
# from repo's root directory
make karabiner
```

## Customization

The configuration is defined in YAML in `/script/karabiner-setup/rules.yaml` and compiled to JSON using the karabiner-setup tool.

To modify the configuration:
1. Edit `/script/karabiner-setup/rules.yaml`
2. Compile using `cd script/karabiner-setup && go run converter.go`
3. Run `make karabiner` to update the symlinks