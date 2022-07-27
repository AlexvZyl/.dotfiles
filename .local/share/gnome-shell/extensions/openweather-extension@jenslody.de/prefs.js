/*
   This file is part of OpenWeather (gnome-shell-extension-openweather).

   OpenWeather is free software: you can redistribute it and/or modify it under the terms of
   the GNU General Public License as published by the Free Software Foundation, either
   version 3 of the License, or (at your option) any later version.

   OpenWeather is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
   See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with OpenWeather.
   If not, see <https://www.gnu.org/licenses/>.

   Copyright 2022 Jason Oickle
*/

const {
    Adw, Gtk, Gdk
} = imports.gi;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
// Import preferences pages
const GeneralPrefs = Me.imports.preferences.generalPage;
const LayoutPrefs = Me.imports.preferences.layoutPage;
const LocationsPrefs = Me.imports.preferences.locationsPage;
const AboutPrefs = Me.imports.preferences.aboutPage;

function init() {
    ExtensionUtils.initTranslations(Me.metadata['gettext-domain']);
}

function fillPreferencesWindow(window) {
    let iconTheme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default());
    if (!iconTheme.get_search_path().includes(Me.path + "/media")) {
        iconTheme.add_search_path(Me.path + "/media");
    }

    const settings = ExtensionUtils.getSettings(Me.metadata['settings-schema']);
    const generalPage = new GeneralPrefs.GeneralPage(settings);
    const layoutPage = new LayoutPrefs.LayoutPage(settings);
    const locationsPage = new LocationsPrefs.LocationsPage(window, settings);
    const aboutPage = new AboutPrefs.AboutPage();

    let prefsWidth = settings.get_int('prefs-default-width');
    let prefsHeight = settings.get_int('prefs-default-height');

    window.set_default_size(prefsWidth, prefsHeight);
    window.set_search_enabled(true);

    window.add(generalPage);
    window.add(layoutPage);
    window.add(locationsPage);
    window.add(aboutPage);

    window.connect('close-request', () => {
        let currentWidth = window.default_width;
        let currentHeight = window.default_height;
        // Remember user window size adjustments.
        if (currentWidth != prefsWidth || currentHeight != prefsHeight) {
            settings.set_int('prefs-default-width', currentWidth);
            settings.set_int('prefs-default-height', currentHeight);
        }
        window.destroy();
    });
}