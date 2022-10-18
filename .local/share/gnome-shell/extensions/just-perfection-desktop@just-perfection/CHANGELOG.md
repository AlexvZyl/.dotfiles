# Changelog

All notable changes to this project will be documented in this file.

We go to the next version after each release on [GNOME Shell Extensions website](https://extensions.gnome.org/).

## [Unreleased]

## [22.0.0 Millet] - 2022-09-10

### Fixed

- Dash app button visibility height.
- Looking glass error after unlock.

### Added

- App menu label visibility.
- GNOME Shell 43 support.
- Quick settings menu visibility.

### Removed

- Aggregate menu for GNOME Shell 43 and higher.

## [21.0.0 Reynolds] - 2022-08-06

### Changed

- Prefs compatibility layer checking to GTK and Adw instead of GNOME Shell version.

### Fixed

- Application button visibility in Ubuntu 22.04.
- Prefs window size for scaled displays.
- Prefs window size for small displays in GNOME Shell 42.
- Racy prefs window size.
- Window caption going out of display area when dash is disabled in GNOME Shell 40 and higher.
- Russian translation by [@librusekus35790](https://gitlab.gnome.org/librusekus35790).
- Spanish translation by [@Luci](https://gitlab.gnome.org/Luci).

### Added

- Alt Tab window preview icon size.
- Alt Tab window preview size.
- Alt Tab icon size.
- Dash separator visibility.
- Looking glass size by [@AdvendraDeswanta](https://gitlab.gnome.org/AdvendraDeswanta).
- OSD position.
- Take screenshot button in window menu visibility.

### Removed

- Gesture API for GNOME Shell 40 and higher.
- List box separators for GNOME Shell 40 and 41 (EOS).
- Prefs intro.

## [20.0.0 Hayez] - 2022-04-01

### Fixed

- Dynamic workspaces getting disabled by workspace popup.
- Flickering panel after Unlock.
- Notification banner position on GNOME Shell 42.
- Window demands attention focus on GNOME Shell 42.
- French translation by [@GeoffreyCoulaud](https://gitlab.gnome.org/GeoffreyCoulaud).
- Italian translation by [@svityboy](https://gitlab.gnome.org/svityboy).

### Added

- Events visibility in clock menu.
- Calendar visibility in clock menu.
- Dutch translation by [@Vistaus](https://gitlab.gnome.org/Vistaus).

## [19.0.0 Ancher] - 2022-03-02

### Fixed

- Blurry search entry on GNOME Shell themes with box-shadow.
- Prefs file chooser recursion.
- SecondaryMonitorDisplay error on GNOME Shell 42.
- Shell theme override OSD for GNOME Shell 42.
- Shell theme override workspace switcher for GNOME Shell 42.
- Workspace popup visiblity in GNOME Shell 42.

### Added

- Libadwaita for GNOME Shell 42 prefs.
- Panel icon size.
- Panel world clock visiblity.
- Weather visiblity.

## [18.0.0 Roslin] - 2022-02-12

### Fixed

- GNOME 3.x prefs error.

## [17.0.0 Roslin] - 2022-02-11

### Fixed

- Emitting panel show when panel is visible.
- Looking glass not showing up.
- Looking glass position on startup when panel is hidden.
- Prefs height going off the screen in small displays.
- Prefs lunching url freeze on Wayland.
- Prefs padding in GNOME Shell 42.
- Prefs UI Improvement by [@muqtxdir](https://gitlab.gnome.org/muqtxdir).
- Startup animation for hiding panel when panel is disabled.
- Type to search when text entry content is replaced with another content.
- Window goes under panel after unlock on Wayland.
- Window picker caption visibility issue on Pop Shell.
- Galician translation by [@frandieguez](https://gitlab.gnome.org/frandieguez).

### Added

- Bottom to notification banner position.

### Removed

- Panel corner size option for GNOME Shell 42.

## [16.0.0 Rembrandt] - 2021-11-15

### Fixed

- Animation jump when search entry is disabled and entering app grid.
- Clock menu revealing in lockscreen when the position is left or right.
- Startup status for Ubuntu.
- Workspace switcher visiblity in GNOME Shell 41.

### Removed

- Hot corner for GNOME Shell 41.
- Hot corner library for all supported Shell versions.

### Added

- Double supper to app grid for GNOME Shell 40 and 41.
- Panel corner size when panel is disabled.
- Panel visiblity in overview when panel is disabled.
- Prefs window intro.
- Profile selector to the prefs window.
- Ripple box.

## [15.0.0 Magnetized] - 2021-09-22

### Fixed

- unlock recursion error.

### Added

- Hot corner support for GNOME Shell 41.

## [14.0.0 Magnetized] - 2021-09-22

### Changed

- Repo folder structure to have better organization.

### Fixed

- Bottom panel position for multi monitors [@harshadgavali](https://gitlab.gnome.org/harshadgavali).
- First swipe up in desktop startup status.
- Looking glass position on bottom panel.
- Maximized window gap on Wayland.
- Search entry animation for type to search when search entry is disabled.
- Search entry API to avoid conflicting with other extensions.
- Window picker caption border on disable.
- Window picker disapearing on wayland with shell theme override.
- Galician translation by [@frandieguez](https://gitlab.gnome.org/frandieguez).
- Spanish translation by [@DiegoIvanME](https://gitlab.gnome.org/DiegoIvanME).

### Removed

- Donation popover in prefs.
- Hot corner for GNOME Shell 41.

### Added

- GNOME Shell 41 support.
- Panel indicator padding size.
- Window picker close button visibility.

## [13.0.0 Ring] - 2021-08-10

### Changed

- Search button position in prefs window.

### Fixed

- Accessing dash in case the original dash has been removed by third party extensions.
- API.monitorGetInfo for "pMonitor is null" error.
- Dropdown align in preferences dialog.
- Startup status blocking shortcut keys.
- Unwanted window demands attention focus.
- Russian translation by [@librusekus35790](https://gitlab.gnome.org/librusekus35790).

### Removed

- Settings and Translation library and using ExtensionUtils instead.

### Added

- Panel button padding size.
- Panel height.
- Window picker caption visibility.
- Workspace background corner size in overview.
- Workspace wraparound (modified version of WorkspaceSwitcherWrapAround by [@war1025](https://github.com/war1025)).

## [12.0.0 Queen Red] - 2021-06-29

### Changed

- Lighter background color for switcher list (alt+tab) in override theme.
- Workspace switcher max size now maxed out to 30%.

### Fixed

- Combobox scroll issue on GTK4.
- Window demands attention focus notification popup.
- French translation by [@GeoffreyCoulaud](https://gitlab.gnome.org/GeoffreyCoulaud).
- Russian translation by [@librusekus35790](https://gitlab.gnome.org/librusekus35790).

### Added

- Always show workspace switcher on dynamic workspaces.
- More descriptions to the preferences dialog.
- Notification banner position.
- Startup status for GNOME Shell 40.
- Workspace animation background color for shell theme override.
- Workspaces visiblity in app grid by [@fmuellner](https://gitlab.gnome.org/fmuellner).
- Chinese (Taiwan) translation by [@r0930514](https://gitlab.com/r0930514).

## [11.0.0 Whisper] - 2021-05-20

### Changed

- App gesture now only works on GNOME 3.36 and 3.38.
- Donation icon to GTK4 non-compatible icon sets.
- Shell theme override is now disabled by default.
- Workspace switcher size for GNOME Shell 40 is now maxed out to 15%.

### Fixed

- Gap when panel posision is at the bottom and shell override theme happens.
- Panel menu margin when panel is in bottom.
- Window picker icon visiblity on drag.
- Workspace switcher size for multi monitor setup.
- Arabic translation by [@AliGalal](https://gitlab.com/AliGalal).
- Chinese translation by [@wsxy162](https://gitlab.com/wsxy162).
- Italian translation by [@l3nn4rt](https://gitlab.com/l3nn4rt).
- Swedish translation by [@MorganAntonsson](https://gitlab.com/MorganAntonsson).

### Added

- Activities button icon.
- Dash icon size.
- Window demands attention focus.

## [10.0.0] - 2021-03-26

### Changed

- Organized prefs UI for icons and behavior.
- Removed quotes and side bar image from prefs UI.

### Fixed

- Fake hot corner primary monitor position.
- Horizontal scroll in prefs.
- Primary Monitor Panel Position.
- Arabic translation by [@karem34](https://gitlab.com/karem34).
- Russian translation by [@librusekus35790](https://gitlab.com/librusekus35790).

### Added

- Clock menu position.
- Disable animation or change the animation speed.
- Disable applications button in dash.
- Disable app menu icon.
- Disable panel arrow in GNOME 3.36 and 3.38.
- Disable panel notification icon.
- No results found for prefs window.
- Brazilian Portuguese translation by [@Zelling](https://gitlab.com/Zelling).
- Catalan translation by [@juxuanu](https://gitlab.com/juxuanu).
- Galician translation by [@frandieguez](https://gitlab.com/frandieguez).

## [9.0.0] - 2021-03-06

### Changed

- Prefs interface.

### Fixed

- Default value for hot corner on extension disable.
- GNOME Shell 40.beta version.

### Added

- Disable power icon.
- Panel position.
- Support to prefs window.

## [8.0.0] - 2021-02-22

### Changed

- Holding back lonely overview until the final GNOME 40 release.

### Fixed

- Dash override theme on GNOME Shell 40 beta.
- Focus for find entry on prefs.
- Search controller for GNOME Shell 40 beta.
- Start search for GNOME Shell 40 beta.
- Workspace switcher enable related to workspace switcher size.
- Nepali translation filename by [@IBA4](https://gitlab.com/IBA4).

## [7.0.0] - 2021-02-12

### Fixed

- GNOME Shell 40 hidden side by side workspace preview.
- GNOME Shell 40 search padding when panel is disabled.
- Initial prefs window size.

### Added

- GNOME Shell 40 window picker icon visibility to the settings.
- GNOME Shell 40 workspace switcher size to the settings.
- Panel corner size to the settings.
- Search feature to the settings.
- Type to Search to the settings.
- Nepali translation by [@IBA4](https://gitlab.com/IBA4).
- Spanish translation by [@oscfdezdz](https://gitlab.com/oscfdezdz).

## [6.0.0] - 2021-01-29

### Fixed

- GNOME Shell 3.38 extra padding on no workspace switcher.
- GNOME Shell 40 and GTK4 support for prefs.
- GNOME Shell 40 support for search entry.
- GNOME Shell 40 support for workspace switcher.

## [5.0.0] - 2021-01-05

### Added

- Accessibility Menu visibility to the settings.
- Activities button visibility to the settings.
- App menu visibility to the settings.
- Clock menu visibility to the settings.
- Keyboard Layout visibility to the settings.
- System Menu (Aggregate Menu) visibility to the settings.

### Changed

- OSD in settings to "On Screen Display (OSD)".

### Fixed

- Hot corner when top panel is visible.
- Padding on no dash.
- Search top padding on no top panel.

## [4.0.0] 2020-12-25

### Added

- API to decouple all libraries from using GNOME Shell ui directly.
- Automate build process by [@daPhipz](https://gitlab.com/daPhipz).
- CHANGELOG.md file.
- Compatibility layer for API.
- Translation automation script by [@daPhipz](https://gitlab.com/daPhipz).

### Changed

- Default settings to enable.
- Displaying error for generate-mo.sh by [@daPhipz](https://gitlab.com/daPhipz).
- German translation by [@M4he](https://gitlab.com/M4he).

### Fixed

- Top padding on no search and no top panel.

## [3.0.0] - 2020-12-21

### Added

- CONTRIBUTING.md file.
- Decoupled library from GNOME Shell ui.
- Extension logo.
- Initial Translations.
- Prefs as extension settings.

## [2.0.0] - 2020-11-18

### Fixed

- Destroy hot corner on disable.

## [1.0.0] - 2020-11-15

### Added

- Disable app gesture.
- Disable background menu.
- Hide dash.
- Hide search.
- Hide top panel.
- Hide workspace switcher.
- Hot corner to toggle overview visibility.

.
