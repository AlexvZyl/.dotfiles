
## Communication ⚠️

This project is community-maintained. You can find the official [Material Theme here](https://github.com/material-theme/vsc-material-theme).

---

The most epic theme meets Visual Studio Code. You can help by reporting issues [here](https://github.com/material-theme/vsc-community-material-theme/issues).

- [Communication ⚠️](#communication-️)
- [Getting started](#getting-started)
  - [Installation](#installation)
      - [GitHub Repository Clone](#github-repository-clone)
- [Activate theme](#activate-theme)
- [Override theme colors](#override-theme-colors)
  - [Color Scheme override](#color-scheme-override)
- [Recommended settings for a better experience](#recommended-settings-for-a-better-experience)
- [Other resources](#other-resources)

## Getting started

You can install this awesome theme through the [Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Equinusocio.vsc-community-material-theme).

### Installation

Launch *Quick Open*:
  - <img src="https://www.kernel.org/theme/images/logos/favicon.png" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf">Linux</a> `Ctrl+P`
  - <img src="https://developer.apple.com/favicon.ico" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf">macOS</a> `⌘P`
  - <img src="https://www.microsoft.com/favicon.ico" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf">Windows</a> `Ctrl+P`

Paste the following command and press `Enter`:

```shell
ext install material theme
```

And pick the one by **Mattia Astorino (Equinusocio)** (me) as author.

##### GitHub Repository Clone

Change to your `.vscode/extensions` [VS Code extensions directory](https://code.visualstudio.com/docs/extensions/install-extension#_side-loading).
Depending on your platform it is located in the following folders:

  - <img src="https://www.kernel.org/theme/images/logos/favicon.png" width=16 height=16/> **Linux** `~/.vscode/extensions`
  - <img src="https://developer.apple.com/favicon.ico" width=16 height=16/> **macOs** `~/.vscode/extensions`
  - <img src="https://www.microsoft.com/favicon.ico" width=16 height=16/> **Windows** `%USERPROFILE%\.vscode\extensions`

Clone the Material Theme repository as `Equinusocio.vsc-community-material-theme`:

```shell
git clone https://github.com/material-theme/vsc-community-material-theme.git Equinusocio.vsc-community-material-theme
```

## Activate theme

Launch *Quick Open*:

  - <img src="https://www.kernel.org/theme/images/logos/favicon.png" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf">Linux</a> `Ctrl + Shift + P`
  - <img src="https://developer.apple.com/favicon.ico" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf">macOS</a> `⌘ + Shift + P`
  - <img src="https://www.microsoft.com/favicon.ico" width=16 height=16/> <a href="https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf">Windows</a> `Ctrl + Shift + P`

Type `theme`, choose `Preferences: Color Theme`, and select one of the Community Material Theme variants from the list. After activation, the theme will set the correct icon theme based on your active theme variant.

## Override theme colors

You can override the Material Theme UI and schemes colors by adding these theme-specific settings to your configuration. For advanced customisation please check the [relative section on the VS Code documentation](https://code.visualstudio.com/docs/getstarted/themes#_customizing-a-color-theme).

### Color Scheme override

**Basic example**
```js
// Overrides colors
"workbench.colorCustomizations": {
    "[Community Material Theme VARIANT]": {
        "sideBar.background": "#ff0000",
    }
},

// Overrides editor syntax colors and font style
"editor.tokenColorCustomizations": {
    "[Community Material Theme VARIANT]": {
        "comments": "#229977"
    }
},
```

**Advanced example**

```js
"editor.tokenColorCustomizations": {
    "[Community Material Theme VARIANT]": {
        "textMateRules": [
            {
                "scope": [
                    "punctuation.definition.comment",
                    "comment.block",
                    "comment.line",
                    "comment.block.documentation"
                ],
                "settings": {
                    "foreground": "#FF0000"
                }
            }
        ]
    },
},
```

## Recommended settings for a better experience

```js
{
    // Controls the font family.
    "editor.fontFamily": "Operator Mono",
    // Controls the line height. Use 0 to compute the lineHeight from the fontSize.
    "editor.lineHeight": 24,
    // Enables font ligatures
    "editor.fontLigatures": true,
    // Controls if file decorations should use badges.
    "explorer.decorations.badges": false
}
```

## Other resources
- **AppIcon:** [Download](https://github.com/material-theme/vsc-material-theme/files/989048/vsc-material-theme-appicon.zip) the official Material Theme app icon for Visual Studio code

---
