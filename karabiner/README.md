# Karabiner Complex Key Mappings

This file configures custom key mappings to enhance keyboard efficiency, enabling faster navigation, window management, and application launching. Below is a breakdown of the main key mappings configured in this Karabiner-Elements setup.

## Key Mappings Overview

### 1. **Right Command to F18**

-   **Key:** `Right Command`
-   **Remap:** `F18`
-   **Usage:** F18 can act as a modifier to create additional layers or trigger specific macros.

### 2. **Tab Key - Window Hyper Key Layer**

-   **Key:** `Tab`
-   **Tap Behavior:** Acts as a normal `Tab` key.
-   **Hold Behavior:** Activates the `window_hyper` layer for window management shortcuts.

#### Window Hyper Key Layer Mappings (Hold Tab):

-   **`j`**: Move window to left half.
-   **`l`**: Move window to right half.
-   **`k`**: Resize window to almost full screen.
-   **`i`**: Maximize window fully.
-   **`1` to `4`**: Switch desktops (Control + 1, 2, 3, or 4).
-   **`w`**: Move to desktop left.
-   **`e`**: Move to desktop right.

### 3. **Caps Lock Key - Utility Hyper Key Layer**

-   **Key:** `Caps Lock`
-   **Tap Behavior:** Acts as `Escape`.
-   **Hold Behavior:** Activates `util_hyper` layer for application and arrow navigation sublayers.

#### Utility Hyper Key Sublayers

-   **`util_hyper + o`**: Application Launcher

    -   **`b`**: Open Arc browser.
    -   **`k`**: Open KakaoTalk.
    -   **`,`**: Open Warp terminal.
    -   **`f`**: Open Finder.
    -   **`c`**: Open Calendar.
    -   **`m`**: Open Spark email client.
    -   **`p`**: Open Spotify.
    -   **`v`**: Open Visual Studio Code.

-   **`util_hyper + s`**: Arrow Key Navigation
    -   **`j`**: Left Arrow.
    -   **`l`**: Right Arrow.
    -   **`i`**: Up Arrow.
    -   **`k`**: Down Arrow.

## Usage

1. **Activate Layers**: Hold the designated key (Tab or Caps Lock) to enable the respective layer, and press the mapped keys to perform the desired actions.
2. **Single Press**: Tapping Caps Lock or Tab without holding will retain their original function (Escape or Tab).

This configuration enables efficient window management and application launching directly from the keyboard, enhancing productivity with minimal hand movement.

## Troubleshooting

If the key mappings are not working as expected, delete symlink and recreate.
