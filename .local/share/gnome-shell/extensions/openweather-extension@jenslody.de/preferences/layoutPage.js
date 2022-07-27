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

var LayoutPage = GObject.registerClass(
class OpenWeather_LayoutPage extends Adw.PreferencesPage {
    _init(settings) {
        super._init({
            title: _("Layout"),
            icon_name: 'preferences-other-symbolic',
            name: 'LayoutPage'
        });
        this._settings = settings;

        // Panel Options
        let panelGroup = new Adw.PreferencesGroup({
            title: _("Panel")
        });

        // Position in panel
        let panelPositions = new Gtk.StringList();
        panelPositions.append(_("Center"));
        panelPositions.append(_("Right"));
        panelPositions.append(_("Left"));
        let panelPositionRow = new Adw.ComboRow({
            title: _("Position In Panel"),
            model: panelPositions,
            selected: this._settings.get_enum('position-in-panel')
        });

        // Position offset
        let positionOffsetSpinButton = new Gtk.SpinButton({
            adjustment: new Gtk.Adjustment({
                lower: 0,
                upper: 15,
                step_increment: 1,
                page_increment: 1,
                page_size: 0,
                value: this._settings.get_int('position-index')
            }),
            climb_rate: 1,
            digits: 0,
            numeric: true,
            valign: Gtk.Align.CENTER
        });
        let positionOffsetRow = new Adw.ActionRow({
            title: _("Position Offset"),
            subtitle: _("The position relative to other items in the box"),
            activatable_widget: positionOffsetSpinButton
        });
        positionOffsetRow.add_suffix(positionOffsetSpinButton);

        // Temp in panel
        let temperatureInPanelSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            tooltip_text: _("Show the temperature in the panel"),
            active: this._settings.get_boolean('show-text-in-panel')
        });
        let temperatureInPanelRow = new Adw.ActionRow({
            title: _("Temperature In Panel"),
            activatable_widget: temperatureInPanelSwitch
        });
        temperatureInPanelRow.add_suffix(temperatureInPanelSwitch);

        // Conditions in panel
        let conditionsInPanelSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            tooltip_text: _("Show the weather conditions in the panel"),
            active: this._settings.get_boolean('show-comment-in-panel')
        });
        let conditionsInPanelRow = new Adw.ActionRow({
            title: _("Conditions In Panel"),
            activatable_widget: conditionsInPanelSwitch
        });
        conditionsInPanelRow.add_suffix(conditionsInPanelSwitch);

        panelGroup.add(panelPositionRow);
        panelGroup.add(positionOffsetRow);
        panelGroup.add(temperatureInPanelRow);
        panelGroup.add(conditionsInPanelRow);
        this.add(panelGroup);

        // Weather Popup Options
        let popupGroup = new Adw.PreferencesGroup({
            title: _("Popup")
        });

        // Popup position
        let weatherPopupPositionScale = new Gtk.Scale({
            adjustment: new Gtk.Adjustment({
                lower: 0,
                upper: 100,
                step_increment: 0.1,
                page_increment: 2,
                value: this._settings.get_double('menu-alignment')
            }),
            width_request: 200,
            show_fill_level: 1,
            restrict_to_fill_level: 0,
            fill_level: 100
        });
        let weatherPopupPositionRow = new Adw.ActionRow({
            title: _("Popup Position"),
            subtitle: _("Alignment of the popup from left to right"),
            activatable_widget: weatherPopupPositionScale
        });
        weatherPopupPositionRow.add_suffix(weatherPopupPositionScale);

        // Wind arrows
        let windArrowsSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('wind-direction')
        });
        let windArrowsRow = new Adw.ActionRow({
            title: _("Wind Direction Arrows"),
            activatable_widget: windArrowsSwitch
        });
        windArrowsRow.add_suffix(windArrowsSwitch);

        // Translate conditions
        this.providerTranslations = this._settings.get_boolean('owm-api-translate');
        let translateConditionsSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('translate-condition')
        });
        let translateConditionsRow = new Adw.ActionRow({
            title: _("Translate Conditions"),
            activatable_widget: translateConditionsSwitch,
            visible: !this.providerTranslations
        });
        translateConditionsRow.add_suffix(translateConditionsSwitch);

        // Temp decimal places
        let temperatureDigits = new Gtk.StringList();
        temperatureDigits.append(_("0"));
        temperatureDigits.append(_("1"));
        temperatureDigits.append(_("2"));
        temperatureDigits.append(_("3"));
        let temperatureDigitsRow = new Adw.ComboRow({
            title: _("Temperature Decimal Places"),
            tooltip_text: _("Maximum number of digits after the decimal point"),
            model: temperatureDigits,
            selected: this._settings.get_int('decimal-places')
        });

        // Location length text
        let locationLengthSpinButton = new Gtk.SpinButton({
            adjustment: new Gtk.Adjustment({
                lower: 0,
                upper: 500,
                step_increment: 1,
                page_increment: 10,
                value: this._settings.get_int('location-text-length')
            }),
            climb_rate: 5,
            digits: 0,
            numeric: true,
            valign: Gtk.Align.CENTER
        });
        let locationLengthRow = new Adw.ActionRow({
            title: _("Location Text Length"),
            tooltip_text: _("Maximum length of the location text. A setting of '0' is unlimited"),
            activatable_widget: locationLengthSpinButton
        });
        locationLengthRow.add_suffix(locationLengthSpinButton);

        popupGroup.add(weatherPopupPositionRow);
        popupGroup.add(windArrowsRow);
        popupGroup.add(translateConditionsRow);
        popupGroup.add(temperatureDigitsRow);
        popupGroup.add(locationLengthRow);
        this.add(popupGroup);

        // Forecast Options
        this.disableForecast = this._settings.get_boolean('disable-forecast');

        let forecastGroup = new Adw.PreferencesGroup({
            title: _("Forecast"),
            sensitive: !this.disableForecast
        });

        // Center today's forecast
        let centerForecastSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('center-forecast')
        });
        let centerForecastRow = new Adw.ActionRow({
            title: _("Center Today's Forecast"),
            activatable_widget: centerForecastSwitch
        });
        centerForecastRow.add_suffix(centerForecastSwitch);

        // Conditions in forecast
        let forecastConditionsSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('show-comment-in-forecast')
        });
        let forecastConditionsRow = new Adw.ActionRow({
            title: _("Conditions In Forecast"),
            activatable_widget: forecastConditionsSwitch
        });
        forecastConditionsRow.add_suffix(forecastConditionsSwitch);

        // Forecast days
        let forecastDays = new Gtk.StringList();
        forecastDays.append(_("Today Only"));
        forecastDays.append(_("1"));
        forecastDays.append(_("2"));
        forecastDays.append(_("3"));
        forecastDays.append(_("4"));
        forecastDays.append(_("5"));
        let forecastDaysRow = new Adw.ComboRow({
            title: _("Total Days In Forecast"),
            model: forecastDays,
            selected: this._settings.get_int('days-forecast')
        });

        // Keep forecast expanded
        let forecastExpandedSwitch = new Gtk.Switch({
            valign: Gtk.Align.CENTER,
            active: this._settings.get_boolean('expand-forecast')
        });
        let forecastExpandedRow = new Adw.ActionRow({
            title: _("Keep Forecast Expanded"),
            activatable_widget: forecastExpandedSwitch
        });
        forecastExpandedRow.add_suffix(forecastExpandedSwitch);

        forecastGroup.add(centerForecastRow);
        forecastGroup.add(forecastConditionsRow);
        forecastGroup.add(forecastDaysRow);
        forecastGroup.add(forecastExpandedRow);
        this.add(forecastGroup);

        // Bind signals
        panelPositionRow.connect("notify::selected", (widget) => {
            this._settings.set_enum('position-in-panel', widget.selected);
        });
        positionOffsetSpinButton.connect('value-changed', (widget) => {
            this._settings.set_int('position-index', widget.get_value());
        });
        temperatureInPanelSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('show-text-in-panel', widget.get_active());
        });
        conditionsInPanelSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('show-comment-in-panel', widget.get_active());
        });
        weatherPopupPositionScale.connect('value-changed', (widget) => {
            this._settings.set_double('menu-alignment', widget.get_value());
        });
        windArrowsSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('wind-direction', widget.get_active());
        });
        translateConditionsSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('translate-condition', widget.get_active());
        });
        temperatureDigitsRow.connect("notify::selected", (widget) => {
            this._settings.set_int('decimal-places', widget.selected);
        });
        locationLengthSpinButton.connect('value-changed', (widget) => {
            this._settings.set_int('location-text-length', widget.get_value());
        });
        centerForecastSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('center-forecast', widget.get_active());
        });
        forecastConditionsSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('show-comment-in-forecast', widget.get_active());
        });
        forecastDaysRow.connect("notify::selected", (widget) => {
            this._settings.set_int('days-forecast', widget.selected);
        });
        forecastExpandedSwitch.connect('notify::active', (widget) => {
            this._settings.set_boolean('expand-forecast', widget.get_active());
        });
        // Detect settings changes to enable/disable related options
        this._settings.connect('changed', () => {
            if (this._disableForecastChanged()) {
                if (this._settings.get_boolean('disable-forecast')) {
                    forecastGroup.set_sensitive(false);
                } else {
                    forecastGroup.set_sensitive(true);
                }
            }
            else if (this._providerTranslationsChanged()) {
                if (this._settings.get_boolean('owm-api-translate')) {
                    translateConditionsRow.set_visible(false);
                } else {
                    translateConditionsRow.set_visible(true);
                }
            }
        });
    }
    _disableForecastChanged() {
        let _disableForecast = this._settings.get_boolean('disable-forecast');
        if (this.disableForecast != _disableForecast) {
            this.disableForecast = _disableForecast;
            return true;
        }
        return false;
    }
    _providerTranslationsChanged() {
        let _providerTranslations = this._settings.get_boolean('owm-api-translate');
        if (this.providerTranslations != _providerTranslations) {
            this.providerTranslations = _providerTranslations;
            return true;
        }
        return false;
    }
});