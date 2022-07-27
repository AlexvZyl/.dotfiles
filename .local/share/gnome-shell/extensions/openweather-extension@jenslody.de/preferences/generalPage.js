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
    Adw, Gtk, GObject
} = imports.gi;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Gettext = imports.gettext.domain(Me.metadata['gettext-domain']);
const _ = Gettext.gettext;

var GeneralPage = GObject.registerClass(
class OpenWeather_GeneralPage extends Adw.PreferencesPage {
    _init(settings) {
        super._init({
            title: _("Settings"),
            icon_name: 'preferences-system-symbolic',
            name: 'GeneralPage'
        });
        this._settings = settings;

        // General Settings
        let generalGroup = new Adw.PreferencesGroup({
            title: _("General")
        });

        // Current weather refresh
        let currentRefreshSpinButton = new Gtk.SpinButton({
            adjustment: new Gtk.Adjustment({
                lower: 10,
                upper: 1440,
                step_increment: 1,
                page_increment: 10,
                value: this._settings.get_int('refresh-interval-current')  / 60
            }),
            climb_rate: 5,
            numeric: true,
            update_policy: 'if-valid',
            valign: Gtk.Align.CENTER
        });
        let currentRefreshRow = new Adw.ActionRow({
            title: _("Current Weather Refresh"),
            subtitle: _("Current weather refresh interval in minutes"),
            activatable_widget: currentRefreshSpinButton
        });
        currentRefreshRow.add_suffix(currentRefreshSpinButton);

        // forecast refresh
        let disableForecast = this._settings.get_boolean('disable-forecast');
        let forecastRefreshSpinButton = new Gtk.SpinButton({
            adjustment: new Gtk.Adjustment({
                lower: 60,
                upper: 1440,
                step_increment: 1,
                page_increment: 10,
                value: this._settings.get_int('refresh-interval-forecast')  / 60
            }),
            climb_rate: 5,
            numeric: true,
            update_policy: 'if-valid',
            sensitive: (disableForecast) ? false : true,
            valign: Gtk.Align.CENTER
        });
        let forecastRefreshRow = new Adw.ActionRow({
            title: _("Weather Forecast Refresh"),
            subtitle: _("Forecast refresh interval in minutes if enabled"),
            activatable_widget: forecastRefreshSpinButton
        });
        forecastRefreshRow.add_suffix(forecastRefreshSpinButton);

        // disable forecast
        let disableForecastSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: disableForecast
        });
        let disableForecastRow = new Adw.ActionRow({
            title: _("Disable Forecast"),
            subtitle: _("Disables all fetching and processing of forecast data"),
            activatable_widget: disableForecastSwitch
        });
        disableForecastRow.add_suffix(disableForecastSwitch);

        // Icons
        let systemIconsSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('use-system-icons')
        });
        let systemIconsRow = new Adw.ActionRow({
            title: _("System Icons"),
            subtitle: _("Disable to use packaged Adwaita weather icons"),
            tooltip_text: _("If you have issues with your system icons displaying correctly disable this to fix it"),
            activatable_widget: systemIconsSwitch
        });
        systemIconsRow.add_suffix(systemIconsSwitch);

        // Startup delay
        let startupDelaySpinButton = new Gtk.SpinButton({
            adjustment: new Gtk.Adjustment({
                lower: 0,
                upper: 30,
                step_increment: 1,
                page_increment: 10,
                value: this._settings.get_int('delay-ext-init')
            }),
            climb_rate: 1,
            numeric: true,
            update_policy: 'if-valid',
            valign: Gtk.Align.CENTER
        });
        let startupDelayRow = new Adw.ActionRow({
            title: _("First Boot Delay"),
            subtitle: _("Seconds to delay popup initialization and data fetching"),
            tooltip_text: _("This setting only applies to the first time the extension is loaded. (first log in / restarting gnome shell)"),
            activatable_widget: startupDelaySpinButton
        });
        startupDelayRow.add_suffix(startupDelaySpinButton);

        generalGroup.add(currentRefreshRow);
        generalGroup.add(forecastRefreshRow);
        generalGroup.add(disableForecastRow);
        generalGroup.add(systemIconsRow);
        generalGroup.add(startupDelayRow);
        this.add(generalGroup);

        // Units Group
        let unitsGroup = new Adw.PreferencesGroup({
            title: _("Units")
        });

        // Temperature
        let temperatureUnits = new Gtk.StringList();
        temperatureUnits.append(_("°C"));
        temperatureUnits.append(_("°F"));
        temperatureUnits.append(_("K"));
        temperatureUnits.append(_("°Ra"));
        temperatureUnits.append(_("°Ré"));
        temperatureUnits.append(_("°Rø"));
        temperatureUnits.append(_("°De"));
        temperatureUnits.append(_("°N"));
        let temperatureUnitRow = new Adw.ComboRow({
            title: _("Temperature"),
            model: temperatureUnits,
            selected: this._settings.get_enum('unit')
        });

        // Wind speed
        let windSpeedUnits = new Gtk.StringList();
        windSpeedUnits.append(_("km/h"));
        windSpeedUnits.append(_("mph"));
        windSpeedUnits.append(_("m/s"));
        windSpeedUnits.append(_("kn"));
        windSpeedUnits.append(_("ft/s"));
        windSpeedUnits.append(_("Beaufort"));
        let windSpeedUnitRow = new Adw.ComboRow({
            title: _("Wind Speed"),
            model: windSpeedUnits,
            selected: this._settings.get_enum('wind-speed-unit')
        });

        // Pressure
        let pressureUnits = new Gtk.StringList();
        pressureUnits.append(_("hPa"));
        pressureUnits.append(_("inHg"));
        pressureUnits.append(_("bar"));
        pressureUnits.append(_("Pa"));
        pressureUnits.append(_("kPa"));
        pressureUnits.append(_("atm"));
        pressureUnits.append(_("at"));
        pressureUnits.append(_("Torr"));
        pressureUnits.append(_("psi"));
        pressureUnits.append(_("mmHg"));
        pressureUnits.append(_("mbar"));
        let pressureUnitRow = new Adw.ComboRow({
            title: _("Pressure"),
            model: pressureUnits,
            selected: this._settings.get_enum('pressure-unit')
        });

        unitsGroup.add(temperatureUnitRow);
        unitsGroup.add(windSpeedUnitRow);
        unitsGroup.add(pressureUnitRow);
        this.add(unitsGroup);

        // Provider Settings
        let apiGroup = new Adw.PreferencesGroup({
            title: _("Provider")
        });

        // OpenWeatherMap Multilingual Support
        let providerTranslateSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('owm-api-translate')
        });
        let providerTranslateRow = new Adw.ActionRow({
            title: _("OpenWeatherMap Multilingual Support"),
            subtitle: _("Using provider translations applies to weather conditions only"),
            tooltip_text: _("Enable this to use OWM multilingual support in 46 languages if there's no built-in translations for your language yet."),
            activatable_widget: providerTranslateSwitch
        });
        providerTranslateRow.add_suffix(providerTranslateSwitch);

        // OpenWeatherMap API key
        let useDefaultApiKey = this._settings.get_boolean('use-default-owm-key');
        let defaultApiKeySwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: useDefaultApiKey
        });
        let defaultApiKeyRow = new Adw.ActionRow({
            title: _("Use Extensions API Key"),
            subtitle: _("Use the built-in API key for OpenWeatherMap"),
            tooltip_text: _("Disable this if you have your own API key from openweathermap.org and enter it below."),
            activatable_widget: defaultApiKeySwitch
        });
        defaultApiKeyRow.add_suffix(defaultApiKeySwitch);

        // Personal API key
        let personalApiKeyEntry = new Gtk.Entry({
            max_length: 32,
            width_chars: 20,
            vexpand: false,
            sensitive: (useDefaultApiKey) ? false : true,
            valign: Gtk.Align.CENTER
        });
        let personalApiKeyRow = new Adw.ActionRow({
            title: _("Personal API Key"),
            activatable_widget: personalApiKeyEntry
        });
        let personalApiKey = this._settings.get_string('appid');
        if (personalApiKey != ''){
            if (personalApiKey.length != 32) {
                personalApiKeyEntry.set_icon_from_icon_name(Gtk.PositionType.LEFT, 'dialog-warning');
            } else {
                personalApiKeyEntry.set_icon_from_icon_name(Gtk.PositionType.LEFT, '');
            }
            personalApiKeyEntry.set_text(personalApiKey);
        }
        else {
            personalApiKeyEntry.set_text("");
            personalApiKeyEntry.set_icon_from_icon_name(Gtk.PositionType.LEFT, 'dialog-warning');
        }
        personalApiKeyRow.add_suffix(personalApiKeyEntry);

        apiGroup.add(providerTranslateRow);
        apiGroup.add(defaultApiKeyRow);
        apiGroup.add(personalApiKeyRow);
        this.add(apiGroup);

        // Bind signals
        currentRefreshSpinButton.connect('value-changed', (widget) => {
            this._settings.set_int('refresh-interval-current', 60 * widget.get_value());
        });
        forecastRefreshSpinButton.connect('value-changed', (widget) => {
            this._settings.set_int('refresh-interval-forecast', 60 * widget.get_value());
        });
        disableForecastSwitch.connect('notify::active', (widget) => {
            if (widget.get_active()) {
                forecastRefreshSpinButton.set_sensitive(false);
            } else {
                forecastRefreshSpinButton.set_sensitive(true);
            }
            this._settings.set_boolean('disable-forecast', widget.get_active());
        });
        systemIconsSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('use-system-icons', widget.get_active());
        });
        startupDelaySpinButton.connect('value-changed', (widget) => {
            this._settings.set_int('delay-ext-init', widget.get_value());
        });
        temperatureUnitRow.connect('notify::selected', (widget) => {
            this._settings.set_enum('unit', widget.selected);
        });
        windSpeedUnitRow.connect('notify::selected', (widget) => {
            this._settings.set_enum('wind-speed-unit', widget.selected);
        });
        pressureUnitRow.connect('notify::selected', (widget) => {
            this._settings.set_enum('pressure-unit', widget.selected);
        });
        providerTranslateSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('owm-api-translate', widget.get_active());
        });
        defaultApiKeySwitch.connect('notify::active', (widget) => {
            if (widget.get_active()) {
                personalApiKeyEntry.set_sensitive(false);
            } else {
                personalApiKeyEntry.set_sensitive(true);
            }
            this._settings.set_boolean('use-default-owm-key', widget.get_active());
        });
        personalApiKeyEntry.connect("notify::text", (widget) => {
            if (widget.text.length == 32) {
                this._settings.set_string('appid', widget.text);
                personalApiKeyEntry.set_icon_from_icon_name(Gtk.PositionType.LEFT, '');
            }
            else {
                personalApiKeyEntry.set_icon_from_icon_name(Gtk.PositionType.LEFT, 'dialog-warning');
                if (widget.text.length == 0) {
                    this._settings.set_string('appid', '');
                }
            }
        });
    }
});