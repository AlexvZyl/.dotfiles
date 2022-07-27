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
    Clutter, Gio, Gtk, GLib, GObject, St
} = imports.gi;

const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const GnomeSession = imports.misc.gnomeSession;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const OpenWeatherMap = Me.imports.openweathermap;
const Gettext = imports.gettext.domain(Me.metadata['gettext-domain']);
const _ = Gettext.gettext;

let _firstBoot = 1;
let _timeCacheCurrentWeather;
let _timeCacheForecastWeather;
// Keep enums in sync with GSettings schemas
const WeatherProvider = {
    OPENWEATHERMAP: 0
};
const WeatherUnits = {
    CELSIUS: 0,
    FAHRENHEIT: 1,
    KELVIN: 2,
    RANKINE: 3,
    REAUMUR: 4,
    ROEMER: 5,
    DELISLE: 6,
    NEWTON: 7
};
const WeatherWindSpeedUnits = {
    KPH: 0,
    MPH: 1,
    MPS: 2,
    KNOTS: 3,
    FPS: 4,
    BEAUFORT: 5
};
const WeatherPressureUnits = {
    HPA: 0,
    INHG: 1,
    BAR: 2,
    PA: 3,
    KPA: 4,
    ATM: 5,
    AT: 6,
    TORR: 7,
    PSI: 8,
    MMHG: 9,
    MBAR: 10
};
const WeatherPosition = {
    CENTER: 0,
    RIGHT: 1,
    LEFT: 2
};

//hack (for Wayland?) via https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/1997
Gtk.IconTheme.get_default = function() {
    let theme = new Gtk.IconTheme();
    theme.set_custom_theme(St.Settings.get().gtk_icon_theme);
    return theme;
};

let OpenWeatherMenuButton = GObject.registerClass(
class OpenWeatherMenuButton extends PanelMenu.Button {

    _init() {
        super._init(0, 'OpenWeatherMenuButton', false);

        // Putting the panel item together
        this._weatherIcon = new St.Icon({
            icon_name: 'view-refresh-symbolic',
            style_class: 'system-status-icon openweather-icon'
        });
        this._weatherInfo = new St.Label({
            style_class: 'openweather-label',
            y_align: Clutter.ActorAlign.CENTER,
            y_expand: true
        });
        let topBox = new St.BoxLayout({
            style_class: 'panel-status-menu-box'
        });
        topBox.add_child(this._weatherIcon);
        topBox.add_child(this._weatherInfo);
        this.add_child(topBox);

        if (Main.panel._menus === undefined)
            Main.panel.menuManager.addMenu(this.menu);
        else
            Main.panel._menus.addMenu(this.menu);

        // Load settings
        this.loadConfig();
        // Setup network things
        this._idle = false;
        this._connected = false;
        this._network_monitor = Gio.network_monitor_get_default();

        // Bind signals
        this._presence = new GnomeSession.Presence((proxy, error) => {
            this._onStatusChanged(proxy.status);
        });
        this._presence_connection = this._presence.connectSignal('StatusChanged', (proxy, senderName, [status]) => {
            this._onStatusChanged(status);
        });
        this._network_monitor_connection = this._network_monitor.connect('network-changed', this._onNetworkStateChanged.bind(this));

        this.menu.connect('open-state-changed', this.recalcLayout.bind(this));

        let _firstBootWait = this._startupDelay;
        if (_firstBoot && _firstBootWait != 0) {
            // Delay popup initialization and data fetch on the first
            // extension load, ie: first log in / restart gnome shell
            this._timeoutFirstBoot = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, _firstBootWait, () => {
                this._checkConnectionState();
                this.initOpenWeatherUI();
                _firstBoot = 0;
                this._timeoutFirstBoot = null;
                return false; // run timer once then destroy
            });
        }
        else {
            this._checkConnectionState();
            this.initOpenWeatherUI();
        }
    }

    initOpenWeatherUI() {
        this.owmCityId = 0;
        this.useOpenWeatherMap();
        this.checkPositionInPanel();

        this._currentWeather = new PopupMenu.PopupBaseMenuItem({
            reactive: false
        });
        if (!this._isForecastDisabled) {
            this._currentForecast = new PopupMenu.PopupBaseMenuItem({
                reactive: false
            });
            if (this._forecastDays != 0) {
                this._forecastExpander = new PopupMenu.PopupSubMenuMenuItem("");
            }
        }
        this._buttonMenu = new PopupMenu.PopupBaseMenuItem({
            reactive: false,
            style_class: 'openweather-menu-button-container'
        });
        this._selectCity = new PopupMenu.PopupSubMenuMenuItem("");
        this._selectCity.actor.set_height(0);
        this._selectCity._triangle.set_height(0);

        this.rebuildCurrentWeatherUi();
        this.rebuildFutureWeatherUi();
        this.rebuildButtonMenu();
        this.rebuildSelectCityItem();

        this.menu.addMenuItem(this._currentWeather);
        if (!this._isForecastDisabled) {
            this.menu.addMenuItem(this._currentForecast);
            if (this._forecastDays != 0) {
                this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
                this.menu.addMenuItem(this._forecastExpander);
            }
        }
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        this.menu.addMenuItem(this._buttonMenu);
        this.menu.addMenuItem(this._selectCity);
        this.checkAlignment();
    }

    _onStatusChanged(status) {
        this._idle = false;

        if (status == GnomeSession.PresenceStatus.IDLE) {
            this._idle = true;
        }
    }

    stop() {
        if (this._timeoutCurrent) {
            GLib.source_remove(this._timeoutCurrent);
            this._timeoutCurrent = null;
        }
        if (this._timeoutForecast) {
            GLib.source_remove(this._timeoutForecast);
            this._timeoutForecast = null;
        }
        if (this._timeoutFirstBoot) {
            GLib.source_remove(this._timeoutFirstBoot);
            this._timeoutFirstBoot = null;
        }

        if (this._timeoutMenuAlignent) {
            GLib.source_remove(this._timeoutMenuAlignent);
            this._timeoutMenuAlignent = null;
        }

        if (this._timeoutCheckConnectionState) {
            GLib.source_remove(this._timeoutCheckConnectionState);
            this._timeoutCheckConnectionState = null;
        }

        if (this._presence_connection) {
            this._presence.disconnectSignal(this._presence_connection);
            this._presence_connection = undefined;
        }

        if (this._network_monitor_connection) {
            this._network_monitor.disconnect(this._network_monitor_connection);
            this._network_monitor_connection = undefined;
        }

        if (this._settingsC) {
            this._settings.disconnect(this._settingsC);
            this._settingsC = undefined;
        }

        if (this._settingsInterfaceC) {
            this._settingsInterface.disconnect(this._settingsInterfaceC);
            this._settingsInterfaceC = undefined;
        }

        if (this._globalThemeChangedId) {
            let context = St.ThemeContext.get_for_stage(global.stage);
            context.disconnect(this._globalThemeChangedId);
            this._globalThemeChangedId = undefined;
        }
    }

    useOpenWeatherMap() {
        this.initWeatherData = OpenWeatherMap.initWeatherData;
        this.reloadWeatherCache = OpenWeatherMap.reloadWeatherCache;
        this.refreshWeatherData = OpenWeatherMap.refreshWeatherData;
        this.populateCurrentUI = OpenWeatherMap.populateCurrentUI;

        if (!this._isForecastDisabled) {
            this.refreshForecastData = OpenWeatherMap.refreshForecastData;
            this.populateTodaysUI = OpenWeatherMap.populateTodaysUI;
            this.populateForecastUI = OpenWeatherMap.populateForecastUI;
            this.processTodaysData = OpenWeatherMap.processTodaysData;
            this.processForecastData = OpenWeatherMap.processForecastData;
        }
        this.loadJsonAsync = OpenWeatherMap.loadJsonAsync;
        this.weatherProvider = "OpenWeatherMap";

        if (this._appid.toString().trim() === '')
            Main.notify("OpenWeather", _("Openweathermap.org does not work without an api-key.\nEither set the switch to use the extensions default key in the preferences dialog to on or register at https://openweathermap.org/appid and paste your personal key into the preferences dialog."));
    }

    getWeatherProviderURL() {
        let url = "https://openweathermap.org";
        url += "/city/" + this.owmCityId;
        return url;
    }

    loadConfig() {
        this._settings = ExtensionUtils.getSettings(Me.metadata['settings-schema']);

        if (this._cities.length === 0)
            this._cities = "43.6534817,-79.3839347>Toronto >0";

        this._currentLocation = this.extractCoord(this._city);
        this._isForecastDisabled = this._disable_forecast;
        this._forecastDays = this._days_forecast;
        this._currentAlignment = this._menu_alignment;
        this._providerTranslations = this._provider_translations;

        // Get locale
        this.locale = GLib.get_language_names()[0];
        if (this.locale.indexOf('_') != -1)
            this.locale = this.locale.split("_")[0];
        else  // Fallback for 'C', 'C.UTF-8', and unknown locales.
            this.locale = 'en';

        // Bind to settings changed signal
        this._settingsC = this._settings.connect("changed", () => {

            if (this.disableForecastChanged()) {
                let _children = (this._isForecastDisabled) ? 4 : 7;
                if (this._forecastDays === 0) {
                    _children = this.menu.box.get_children().length-1;
                }
                for (let i = 0; i < _children; i++) {
                    this.menu.box.get_child_at_index(0).destroy();
                }
                this._isForecastDisabled = this._disable_forecast;
                this.initOpenWeatherUI();
                this._clearWeatherCache();
                this.initWeatherData();
                return;
            }
            else if (this.locationChanged()) {
                if (this._cities.length === 0)
                    this._cities = "43.6534817,-79.3839347>Toronto >0";
                this.showRefreshing();
                if (this._selectCity._getOpenState())
                    this._selectCity.menu.toggle();
                this._currentLocation = this.extractCoord(this._city);
                this.rebuildSelectCityItem();
                this._clearWeatherCache();
                this.initWeatherData();
                return;
            }
            else {
                if (this.menuAlignmentChanged()) {
                    if (this._timeoutMenuAlignent)
                        GLib.source_remove(this._timeoutMenuAlignent);
                    // Use 1 second timeout to avoid crashes and spamming
                    // the logs while changing the slider position in prefs
                    this._timeoutMenuAlignent = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
                        this.checkAlignment();
                        this._currentAlignment = this._menu_alignment;
                        this._timeoutMenuAlignent = null;
                        return false; // run once then destroy
                    });
                    return;
                }
                if (this._forecastDays != this._days_forecast) {
                    let _oldDays = this._forecastDays;
                    let _newDays = this._days_forecast;
                    this._forecastDays = _newDays;

                    if (_oldDays >= 1 && _newDays === 0) {
                        this._forecastExpander.destroy();
                        return;
                    }
                    else if (_oldDays === 0 && _newDays >= 1) {
                        let _children = this.menu.box.get_children().length-1;
                        for (let i = 0; i < _children; i++) {
                            this.menu.box.get_child_at_index(0).destroy();
                        }
                        this._clearWeatherCache();
                        this.initOpenWeatherUI();
                        this.initWeatherData();
                        return;
                    }
                    else {
                        this.forecastJsonCache = undefined;
                        this.rebuildFutureWeatherUi();
                        this.reloadWeatherCache();
                        return;
                    }
                }
                if (this._providerTranslations != this._provider_translations) {
                    this._providerTranslations = this._provider_translations;
                    if (this._providerTranslations) {
                        this.showRefreshing();
                        this._clearWeatherCache();
                        this.initWeatherData();
                    } else {
                        this.reloadWeatherCache();
                    }
                    return;
                }
                this.checkAlignment();
                this.checkPositionInPanel();
                this.rebuildCurrentWeatherUi();
                this.rebuildFutureWeatherUi();
                this.rebuildButtonMenu();
                this.reloadWeatherCache();
            }
            return;
        });
    }

    loadConfigInterface() {
        this._settingsInterface = ExtensionUtils.getSettings('org.gnome.desktop.interface');
        this._settingsInterfaceC = this._settingsInterface.connect("changed", () => {
            this.rebuildCurrentWeatherUi();
            this.rebuildFutureWeatherUi();
            if (this.locationChanged()) {
                this.rebuildSelectCityItem();
                this._clearWeatherCache();
                this.initWeatherData();
            }
            else {
                this.reloadWeatherCache();
            }
        });
    }

    _clearWeatherCache() {
        this.currentWeatherCache = undefined;
        this.todaysWeatherCache = undefined;
        this.forecastWeatherCache = undefined;
        this.forecastJsonCache = undefined;
    }

    _onNetworkStateChanged() {
        this._checkConnectionState();
    }

    _checkConnectionState() {
        this._checkConnectionStateRetries = 3;
        this._oldConnected = this._connected;
        this._connected = false;

        this._checkConnectionStateWithRetries(1250);
    }

    _checkConnectionStateRetry() {
        if (this._checkConnectionStateRetries > 0) {
            let timeout;
            if (this._checkConnectionStateRetries == 3)
                timeout = 10000;
            else if (this._checkConnectionStateRetries == 2)
                timeout = 30000;
            else if (this._checkConnectionStateRetries == 1)
                timeout = 60000;

            this._checkConnectionStateRetries -= 1;
            this._checkConnectionStateWithRetries(timeout);
        }
    }

    _checkConnectionStateWithRetries(interval) {
        if (this._timeoutCheckConnectionState) {
            GLib.source_remove(this._timeoutCheckConnectionState);
            this._timeoutCheckConnectionState = null;
        }

        this._timeoutCheckConnectionState = GLib.timeout_add(GLib.PRIORITY_DEFAULT, interval, () => {
            // Nullify the variable holding the timeout-id, otherwise we can get errors, if we try to delete
            // it manually, the timeout will be destroyed automatically if we return false.
            // We just fetch it for the rare case, where the connection changes or the extension will be stopped during
            // the timeout.
            this._timeoutCheckConnectionState = null;
            let url = this.getWeatherProviderURL();
            let address = Gio.NetworkAddress.parse_uri(url, 80);
            let cancellable = Gio.Cancellable.new();
            try {
                this._network_monitor.can_reach_async(address, cancellable, this._asyncReadyCallback.bind(this));
            } catch (err) {
                let title = _("Can not connect to %s").format(url);
                log(title + '\n' + err.message);
                this._checkConnectionStateRetry();
            }
            return false;
        });
    }

    _asyncReadyCallback(nm, res) {
        try {
            this._connected = this._network_monitor.can_reach_finish(res);
        } catch (err) {
            let title = _("Can not connect to %s").format(this.getWeatherProviderURL());
            log(title + '\n' + err.message);
            this._checkConnectionStateRetry();
            return;
        }
        if (!this._oldConnected && this._connected) {
            let now = new Date();
            if (
                _timeCacheCurrentWeather
                && (Math.floor(new Date(now - _timeCacheCurrentWeather).getTime() / 1000) > this._refresh_interval_current)
            ) {
                this.currentWeatherCache = undefined;
            }
            if (
                !this._isForecastDisabled
                && _timeCacheForecastWeather
                && (Math.floor(new Date(now - _timeCacheForecastWeather).getTime() / 1000) > this._refresh_interval_forecast)
            ) {
                this.forecastWeatherCache = undefined;
                this.todaysWeatherCache = undefined;
            }
            this.forecastJsonCache = undefined;
            this.initWeatherData();
        }
    }

    disableForecastChanged() {
        if (this._isForecastDisabled != this._disable_forecast) {
            return true;
        }
        return false;
    }

    locationChanged() {
        let location = this.extractCoord(this._city);
        if (this._currentLocation != location) {
            return true;
        }
        return false;
    }

    menuAlignmentChanged() {
        if (this._currentAlignment != this._menu_alignment) {
            return true;
        }
        return false;
    }

    get _clockFormat() {
        if (!this._settingsInterface)
            this.loadConfigInterface();
        return this._settingsInterface.get_string("clock-format");
    }

    get _weather_provider() {
        // Simplify until more providers are added
        return 0;
        // if (!this._settings)
        //     this.loadConfig();
        // let provider = this.extractProvider(this._city);
        // if (provider == WeatherProvider.DEFAULT)
        //     provider = this._settings.get_enum('weather-provider');
        // return provider;
    }

    get _units() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_enum('unit');
    }

    get _wind_speed_units() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_enum('wind-speed-unit');
    }

    get _wind_direction() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('wind-direction');
    }

    get _pressure_units() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_enum('pressure-unit');
    }

    get _cities() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_string('city');
    }

    set _cities(v) {
        if (!this._settings)
            this.loadConfig();
        return this._settings.set_string('city', v);
    }

    get _actual_city() {
        if (!this._settings)
            this.loadConfig();
        var a = this._settings.get_int('actual-city');
        var b = a;
        var cities = this._cities.split(" && ");

        if (typeof cities != "object")
            cities = [cities];

        var l = cities.length - 1;

        if (a < 0)
            a = 0;

        if (l < 0)
            l = 0;

        if (a > l)
            a = l;

        return a;
    }

    set _actual_city(a) {
        if (!this._settings)
            this.loadConfig();
        var cities = this._cities.split(" && ");

        if (typeof cities != "object")
            cities = [cities];

        var l = cities.length - 1;

        if (a < 0)
            a = 0;

        if (l < 0)
            l = 0;

        if (a > l)
            a = l;

        this._settings.set_int('actual-city', a);
    }

    get _city() {
        let cities = this._cities.split(" && ");
        if (cities && typeof cities == "string")
            cities = [cities];
        if (!cities[0])
            return "";
        cities = cities[this._actual_city];
        return cities;
    }

    get _translate_condition() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('translate-condition');
    }

    get _provider_translations() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('owm-api-translate');
    }

    get _getUseSysIcons() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('use-system-icons') ? 1 : 0;
    }

    get _startupDelay() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_int('delay-ext-init');
    }

    get _text_in_panel() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('show-text-in-panel');
    }

    get _position_in_panel() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_enum('position-in-panel');
    }

    get _position_index() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_int('position-index');
    }

    get _menu_alignment() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_double('menu-alignment');
    }

    get _comment_in_panel() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('show-comment-in-panel');
    }

    get _disable_forecast() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('disable-forecast');
    }

    get _comment_in_forecast() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('show-comment-in-forecast');
    }

    get _refresh_interval_current() {
        if (!this._settings)
            this.loadConfig();
        let v = this._settings.get_int('refresh-interval-current');
        return ((v >= 600) ? v : 600);
    }

    get _refresh_interval_forecast() {
        if (!this._settings)
            this.loadConfig();
        let v = this._settings.get_int('refresh-interval-forecast');
        return ((v >= 3600) ? v : 3600);
    }

    get _loc_len_current() {
        if (!this._settings)
            this.loadConfig();
        let v = this._settings.get_int('location-text-length');
        return ((v > 0) ? v : 0);
    }

    get _center_forecast() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_boolean('center-forecast');
    }

    get _days_forecast() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_int('days-forecast');
    }

    get _decimal_places() {
        if (!this._settings)
            this.loadConfig();
        return this._settings.get_int('decimal-places');
    }

    get _appid() {
        if (!this._settings)
            this.loadConfig();
        let key = '';
        let useDefaultKey = this._settings.get_boolean('use-default-owm-key');

        if (useDefaultKey)
            key = 'e54ac00966ee06bcf68722c86925b326';
        else
            key = this._settings.get_string('appid');
        return (key.length == 32) ? key : '';
    }

    createButton(iconName, accessibleName) {
        let button;

        button = new St.Button({
            reactive: true,
            can_focus: true,
            track_hover: true,
            accessible_name: accessibleName,
            style_class: 'message-list-clear-button button openweather-button-action'
        });

        button.child = new St.Icon({
            icon_name: iconName
        });

        return button;
    }

    rebuildButtonMenu() {
        this._buttonMenu.actor.destroy_all_children();

        this._buttonBox1 = new St.BoxLayout({
            style_class: 'openweather-button-box'
        });
        this._buttonBox2 = new St.BoxLayout({
            style_class: 'openweather-button-box'
        });

        this._locationButton = this.createButton('find-location-symbolic', _("Locations"));
        this._reloadButton = this.createButton('view-refresh-symbolic', _("Reload Weather Information"));
        this._urlButton = this.createButton('', _("Weather data by: %s").format(this.weatherProvider));
        this._urlButton.set_label(this._urlButton.get_accessible_name());
        this._prefsButton = this.createButton('preferences-system-symbolic', _("Weather Settings"));

        this._buttonBox1.add_actor(this._locationButton);
        this._buttonBox1.add_actor(this._reloadButton);
        this._buttonBox2.add_actor(this._urlButton);
        this._buttonBox2.add_actor(this._prefsButton);

        this._locationButton.connect('clicked', () => {
            this._selectCity._setOpenState(!this._selectCity._getOpenState());
        });
        this._reloadButton.connect('clicked', () => {
            if (this._lastRefresh) {
                let _twoMinsAgo = Date.now() - 120000;
                if (this._lastRefresh > _twoMinsAgo) {
                    Main.notify("OpenWeather", _("Manual refreshes less than 2 minutes apart are ignored!"));
                    return;
                }
            }
            this.showRefreshing();
            this.initWeatherData(true);
        });
        this._urlButton.connect('clicked', () => {
            this.menu.close();
            let url = this.getWeatherProviderURL();
            try {
                Gtk.show_uri(null, url, global.get_current_time());
            }
            catch (err) {
                let title = _("Can not open %s").format(url);
                Main.notifyError(title, err);
            }
        });
        this._prefsButton.connect('clicked', this._onPreferencesActivate.bind(this));

        this._buttonMenu.actor.add_actor(this._buttonBox1);
        this._buttonMenu.actor.add_actor(this._buttonBox2);
    }

    rebuildSelectCityItem() {
        this._selectCity.menu.removeAll();
        let item = null;

        let cities = this._cities;
        cities = cities.split(" && ");
        if (cities && typeof cities == "string")
            cities = [cities];
        if (!cities[0])
            return;

        for (let i = 0; cities.length > i; i++) {
            item = new PopupMenu.PopupMenuItem(this.extractLocation(cities[i]));
            item.location = i;
            if (i == this._actual_city) {
                item.setOrnament(PopupMenu.Ornament.DOT);
            }

            this._selectCity.menu.addMenuItem(item);
            // override the items default onActivate-handler, to keep the ui open while choosing the location
            item.activate = this._onActivate;
        }

        if (cities.length == 1)
            this._selectCity.actor.hide();
        else
            this._selectCity.actor.show();
    }

    _onActivate() {
        openWeatherMenu._actual_city = this.location;
    }

    extractLocation() {
        if (!arguments[0])
            return "";

        if (arguments[0].search(">") == -1)
            return _("Invalid city");
        return arguments[0].split(">")[1];
    }

    extractCoord() {
        let coords = 0;

        if (arguments[0] && (arguments[0].search(">") != -1))
            coords = arguments[0].split(">")[0].replace(' ', '');

        if ((coords.search(",") == -1) || isNaN(coords.split(",")[0]) || isNaN(coords.split(",")[1])) {
            Main.notify("OpenWeather", _("Invalid location! Please try to recreate it."));
            return 0;
        }

        return coords;
    }

    extractProvider() {
        if (!arguments[0])
            return -1;
        if (arguments[0].split(">")[2] === undefined)
            return -1;
        if (isNaN(parseInt(arguments[0].split(">")[2])))
            return -1;
        return parseInt(arguments[0].split(">")[2]);
    }

    _onPreferencesActivate() {
        this.menu.close();
        ExtensionUtils.openPrefs();
        return 0;
    }

    recalcLayout() {
        if (!this.menu.isOpen)
            return;

        if (!this._isForecastDisabled && this._currentForecast !== undefined)
            this._currentForecast.set_width(this._currentWeather.get_width());

        if (!this._isForecastDisabled && this._forecastDays != 0 && this._forecastExpander !== undefined) {
            this._forecastScrollBox.set_width(this._forecastExpanderBox.get_width() - this._daysBox.get_width());
            this._forecastScrollBox.show();
            this._forecastScrollBox.hscroll.show();

            if (this._settings.get_boolean('expand-forecast')) {
                this._forecastExpander.setSubmenuShown(true);
            } else {
                this._forecastExpander.setSubmenuShown(false);
            }
        }
        this._buttonBox1.set_width(this._currentWeather.get_width() - this._buttonBox2.get_width());
    }

    unit_to_unicode() {
        if (this._units == WeatherUnits.FAHRENHEIT)
            return _('\u00B0F');
        else if (this._units == WeatherUnits.KELVIN)
            return _('K');
        else if (this._units == WeatherUnits.RANKINE)
            return _('\u00B0Ra');
        else if (this._units == WeatherUnits.REAUMUR)
            return _('\u00B0R\u00E9');
        else if (this._units == WeatherUnits.ROEMER)
            return _('\u00B0R\u00F8');
        else if (this._units == WeatherUnits.DELISLE)
            return _('\u00B0De');
        else if (this._units == WeatherUnits.NEWTON)
            return _('\u00B0N');
        else
            return _('\u00B0C');
    }

    toFahrenheit(t) {
        return ((Number(t) * 1.8) + 32).toFixed(this._decimal_places);
    }

    toKelvin(t) {
        return (Number(t) + 273.15).toFixed(this._decimal_places);
    }

    toRankine(t) {
        return ((Number(t) * 1.8) + 491.67).toFixed(this._decimal_places);
    }

    toReaumur(t) {
        return (Number(t) * 0.8).toFixed(this._decimal_places);
    }

    toRoemer(t) {
        return ((Number(t) * 21 / 40) + 7.5).toFixed(this._decimal_places);
    }

    toDelisle(t) {
        return ((100 - Number(t)) * 1.5).toFixed(this._decimal_places);
    }

    toNewton(t) {
        return (Number(t) - 0.33).toFixed(this._decimal_places);
    }

    toInHg(p /*, t*/ ) {
        return (p / 33.86530749).toFixed(this._decimal_places);
    }

    toBeaufort(w, t) {
        if (w < 0.3)
            return (!t) ? "0" : "(" + _("Calm") + ")";

        else if (w >= 0.3 && w <= 1.5)
            return (!t) ? "1" : "(" + _("Light air") + ")";

        else if (w > 1.5 && w <= 3.4)
            return (!t) ? "2" : "(" + _("Light breeze") + ")";

        else if (w > 3.4 && w <= 5.4)
            return (!t) ? "3" : "(" + _("Gentle breeze") + ")";

        else if (w > 5, 4 && w <= 7.9)
            return (!t) ? "4" : "(" + _("Moderate breeze") + ")";

        else if (w > 7.9 && w <= 10.7)
            return (!t) ? "5" : "(" + _("Fresh breeze") + ")";

        else if (w > 10.7 && w <= 13.8)
            return (!t) ? "6" : "(" + _("Strong breeze") + ")";

        else if (w > 13.8 && w <= 17.1)
            return (!t) ? "7" : "(" + _("Moderate gale") + ")";

        else if (w > 17.1 && w <= 20.7)
            return (!t) ? "8" : "(" + _("Fresh gale") + ")";

        else if (w > 20.7 && w <= 24.4)
            return (!t) ? "9" : "(" + _("Strong gale") + ")";

        else if (w > 24.4 && w <= 28.4)
            return (!t) ? "10" : "(" + _("Storm") + ")";

        else if (w > 28.4 && w <= 32.6)
            return (!t) ? "11" : "(" + _("Violent storm") + ")";

        else
            return (!t) ? "12" : "(" + _("Hurricane") + ")";
    }

    getLocaleDay(abr) {
        let days = [_('Sunday'), _('Monday'), _('Tuesday'), _('Wednesday'), _('Thursday'), _('Friday'), _('Saturday')];
        return days[abr];
    }

    getWindDirection(deg) {
        let arrows = ["\u2193", "\u2199", "\u2190", "\u2196", "\u2191", "\u2197", "\u2192", "\u2198"];
        let letters = [_('N'), _('NE'), _('E'), _('SE'), _('S'), _('SW'), _('W'), _('NW')];
        let idx = Math.round(deg / 45) % arrows.length;
        return (this._wind_direction) ? arrows[idx] : letters[idx];
    }

    getWeatherIcon(iconname) {
        // Built-in icons option and fallback for missing icons on some distros
        if (this._getUseSysIcons && Gtk.IconTheme.get_default().has_icon(iconname)) {
            return Gio.icon_new_for_string(iconname);
        } // No icon available or user prefers built in icons
        else {
            return Gio.icon_new_for_string(Me.path + "/media/status/" + iconname + ".svg");
        }
    }

    checkAlignment() {
        let menuAlignment = 1.0 - (this._menu_alignment / 100);
        if (Clutter.get_default_text_direction() == Clutter.TextDirection.RTL)
            menuAlignment = 1.0 - menuAlignment;
        this.menu._arrowAlignment=menuAlignment;
    }

    checkPositionInPanel() {
        if (
            this._old_position_in_panel == undefined
            || this._old_position_in_panel != this._position_in_panel
            || this._first_run || this._old_position_index != this._position_index
        ) {
            this.get_parent().remove_actor(this);

            let children = null;
            switch (this._position_in_panel) {
                case WeatherPosition.LEFT:
                    children = Main.panel._leftBox.get_children();
                    Main.panel._leftBox.insert_child_at_index(this, this._position_index);
                    break;
                case WeatherPosition.CENTER:
                    children = Main.panel._centerBox.get_children();
                    Main.panel._centerBox.insert_child_at_index(this, this._position_index);
                    break;
                case WeatherPosition.RIGHT:
                    children = Main.panel._rightBox.get_children();
                    Main.panel._rightBox.insert_child_at_index(this, this._position_index);
                    break;
            }
            this._old_position_in_panel = this._position_in_panel;
            this._old_position_index = this._position_index;
            this._first_run = 1;
        }

    }

    formatPressure(pressure) {
        let pressure_unit = _('hPa');
        switch (this._pressure_units) {
            case WeatherPressureUnits.INHG:
                pressure = this.toInHg(pressure);
                pressure_unit = _("inHg");
                break;

            case WeatherPressureUnits.HPA:
                pressure = pressure.toFixed(this._decimal_places);
                pressure_unit = _("hPa");
                break;

            case WeatherPressureUnits.BAR:
                pressure = (pressure / 1000).toFixed(this._decimal_places);
                pressure_unit = _("bar");
                break;

            case WeatherPressureUnits.PA:
                pressure = (pressure * 100).toFixed(this._decimal_places);
                pressure_unit = _("Pa");
                break;

            case WeatherPressureUnits.KPA:
                pressure = (pressure / 10).toFixed(this._decimal_places);
                pressure_unit = _("kPa");
                break;

            case WeatherPressureUnits.ATM:
                pressure = (pressure * 0.000986923267).toFixed(this._decimal_places);
                pressure_unit = _("atm");
                break;

            case WeatherPressureUnits.AT:
                pressure = (pressure * 0.00101971621298).toFixed(this._decimal_places);
                pressure_unit = _("at");
                break;

            case WeatherPressureUnits.TORR:
                pressure = (pressure * 0.750061683).toFixed(this._decimal_places);
                pressure_unit = _("Torr");
                break;

            case WeatherPressureUnits.PSI:
                pressure = (pressure * 0.0145037738).toFixed(this._decimal_places);
                pressure_unit = _("psi");
                break;

            case WeatherPressureUnits.MMHG:
                pressure = (pressure * 0.750061683).toFixed(this._decimal_places);
                pressure_unit = _("mmHg");
                break;

            case WeatherPressureUnits.MBAR:
                pressure = pressure.toFixed(this._decimal_places);
                pressure_unit = _("mbar");
                break;
        }
        return parseFloat(pressure).toLocaleString(this.locale) + ' ' + pressure_unit;
    }

    formatTemperature(temperature) {
        switch (this._units) {
            case WeatherUnits.FAHRENHEIT:
                temperature = this.toFahrenheit(temperature);
                break;

            case WeatherUnits.CELSIUS:
                temperature = temperature.toFixed(this._decimal_places);
                break;

            case WeatherUnits.KELVIN:
                temperature = this.toKelvin(temperature);
                break;

            case WeatherUnits.RANKINE:
                temperature = this.toRankine(temperature);
                break;

            case WeatherUnits.REAUMUR:
                temperature = this.toReaumur(temperature);
                break;

            case WeatherUnits.ROEMER:
                temperature = this.toRoemer(temperature);
                break;

            case WeatherUnits.DELISLE:
                temperature = this.toDelisle(temperature);
                break;

            case WeatherUnits.NEWTON:
                temperature = this.toNewton(temperature);
                break;
        }
        return parseFloat(temperature).toLocaleString(this.locale).replace('-', '\u2212') + ' ' + this.unit_to_unicode();
    }

    formatWind(speed, direction) {
        let conv_MPSinMPH = 2.23693629;
        let conv_MPSinKPH = 3.6;
        let conv_MPSinKNOTS = 1.94384449;
        let conv_MPSinFPS = 3.2808399;
        let unit = _('m/s');

        switch (this._wind_speed_units) {
            case WeatherWindSpeedUnits.MPH:
                speed = (speed * conv_MPSinMPH).toFixed(this._decimal_places);
                unit = _('mph');
                break;

            case WeatherWindSpeedUnits.KPH:
                speed = (speed * conv_MPSinKPH).toFixed(this._decimal_places);
                unit = _('km/h');
                break;

            case WeatherWindSpeedUnits.MPS:
                speed = speed.toFixed(this._decimal_places);
                break;

            case WeatherWindSpeedUnits.KNOTS:
                speed = (speed * conv_MPSinKNOTS).toFixed(this._decimal_places);
                unit = _('kn');
                break;

            case WeatherWindSpeedUnits.FPS:
                speed = (speed * conv_MPSinFPS).toFixed(this._decimal_places);
                unit = _('ft/s');
                break;

            case WeatherWindSpeedUnits.BEAUFORT:
                speed = this.toBeaufort(speed);
                unit = this.toBeaufort(speed, true);
                break;
        }

        if (!speed)
            return '\u2013';
        else if (speed === 0 || !direction)
            return parseFloat(speed).toLocaleString(this.locale) + ' ' + unit;
        else // i.e. speed > 0 && direction
            return direction + ' ' + parseFloat(speed).toLocaleString(this.locale) + ' ' + unit;
    }

    reloadWeatherCurrent(interval) {
        if (this._timeoutCurrent) {
            GLib.source_remove(this._timeoutCurrent);
            this._timeoutCurrent = null;
        }
        _timeCacheCurrentWeather = new Date();
        this._timeoutCurrent = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, interval, () => {
            this.refreshWeatherData();
            return true;
        });
    }

    reloadWeatherForecast(interval) {
        if (this._timeoutForecast) {
            GLib.source_remove(this._timeoutForecast);
            this._timeoutForecast = null;
        }
        if (this._isForecastDisabled)
            return;

        _timeCacheForecastWeather = new Date();
        this._timeoutForecast = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT_IDLE, interval, () => {
            this.refreshForecastData();
            return true;
        });
    }

    showRefreshing() {
        this._currentWeatherSummary.text = _('Loading ...');
        this._currentWeatherIcon.icon_name = 'view-refresh-symbolic';
    }

    rebuildCurrentWeatherUi() {
        this._currentWeather.actor.destroy_all_children();
        if (!this._isForecastDisabled)
            this._currentForecast.actor.destroy_all_children();

        this._weatherInfo.text = ('...');
        this._weatherIcon.icon_name = 'view-refresh-symbolic';

        // This will hold the icon for the current weather
        this._currentWeatherIcon = new St.Icon({
            icon_size: 96,
            icon_name: 'view-refresh-symbolic',
            style_class: 'system-menu-action openweather-current-icon'
        });

        this._sunriseIcon = new St.Icon({
            icon_size: 15,
            style_class: 'openweather-sunrise-icon'
        });
        this._sunsetIcon = new St.Icon({
            icon_size: 15,
            style_class: 'openweather-sunset-icon '
        });
        this._sunriseIcon.set_gicon(this.getWeatherIcon('daytime-sunrise-symbolic'));
        this._sunsetIcon.set_gicon(this.getWeatherIcon('daytime-sunset-symbolic'));

        this._buildIcon = new St.Icon({
            icon_size: 15,
            icon_name: 'view-refresh-symbolic',
            style_class: 'openweather-build-icon'
        });

        // The summary of the current weather
        this._currentWeatherSummary = new St.Label({
            text: _('Loading ...'),
            style_class: 'openweather-current-summary'
        });
        this._currentWeatherLocation = new St.Label({
            text: _('Please wait')
        });

        let bb = new St.BoxLayout({
            vertical: true,
            x_expand: true,
            y_expand: true,
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'system-menu-action openweather-current-summarybox'
        });
        bb.add_actor(this._currentWeatherLocation);
        bb.add_actor(this._currentWeatherSummary);

        this._currentWeatherSunrise = new St.Label({
            text: '-'
        });
        this._currentWeatherSunset = new St.Label({
            text: '-'
        });
        this._currentWeatherBuild = new St.Label({
            text: '-'
        });

        let ab = new St.BoxLayout({
            x_expand: true,
            style_class: 'openweather-current-infobox'
        });

        ab.add_actor(this._sunriseIcon);
        ab.add_actor(this._currentWeatherSunrise);
        ab.add_actor(this._sunsetIcon);
        ab.add_actor(this._currentWeatherSunset);
        ab.add_actor(this._buildIcon);
        ab.add_actor(this._currentWeatherBuild);
        bb.add_actor(ab);

        // Other labels
        this._currentWeatherFeelsLike = new St.Label({
            text: '...'
        });
        this._currentWeatherHumidity = new St.Label({
            text: '...'
        });
        this._currentWeatherPressure = new St.Label({
            text: '...'
        });
        this._currentWeatherWind = new St.Label({
            text: '...'
        });
        this._currentWeatherWindGusts = new St.Label({
            text: '...'
        });

        let rb = new St.BoxLayout({
            x_expand: true,
            style_class: 'openweather-current-databox'
        });
        let rb_captions = new St.BoxLayout({
            x_expand: true,
            vertical: true,
            style_class: 'popup-menu-item popup-status-menu-item openweather-current-databox-captions'
        });
        let rb_values = new St.BoxLayout({
            x_expand: true,
            vertical: true,
            style_class: 'system-menu-action openweather-current-databox-values'
        });
        rb.add_actor(rb_captions);
        rb.add_actor(rb_values);

        rb_captions.add_actor(new St.Label({
            text: _('Feels Like:')
        }));
        rb_values.add_actor(this._currentWeatherFeelsLike);
        rb_captions.add_actor(new St.Label({
            text: _('Humidity:')
        }));
        rb_values.add_actor(this._currentWeatherHumidity);
        rb_captions.add_actor(new St.Label({
            text: _('Pressure:')
        }));
        rb_values.add_actor(this._currentWeatherPressure);
        rb_captions.add_actor(new St.Label({
            text: _('Wind:')
        }));
        rb_values.add_actor(this._currentWeatherWind);
        rb_captions.add_actor(new St.Label({
            text: _('Gusts:')
        }));
        rb_values.add_actor(this._currentWeatherWindGusts);

        let xb = new St.BoxLayout({
            x_expand: true
        });
        xb.add_actor(bb);
        xb.add_actor(rb);

        let box = new St.BoxLayout({
            x_expand: true,
            style_class: 'openweather-current-iconbox'
        });
        box.add_actor(this._currentWeatherIcon);
        box.add_actor(xb);
        this._currentWeather.actor.add_child(box);

        // Today's forecast if not disabled by user
        if (this._isForecastDisabled)
            return;

        this._todays_forecast = [];
        this._todaysBox = new St.BoxLayout({
            x_expand: true,
            x_align: this._center_forecast ? St.Align.END : St.Align.START,
            style_class: 'openweather-today-box'
        });

        for (let i = 0; i < 4; i++) {
            let todaysForecast = {};

            todaysForecast.Time = new St.Label({
                style_class: 'openweather-forcast-time'
            });
            todaysForecast.Icon = new St.Icon({
                icon_size: 24,
                icon_name: 'view-refresh-symbolic',
                style_class: 'openweather-forecast-icon'
            });
            todaysForecast.Temperature = new St.Label({
                style_class: 'openweather-forecast-temperature'
            });
            todaysForecast.Summary = new St.Label({
                style_class: 'openweather-forecast-summary'
            });
            todaysForecast.Summary.clutter_text.line_wrap = true;

            let fb = new St.BoxLayout({
                vertical: true,
                x_expand: true,
                style_class: 'openweather-today-databox'
            });
            let fib = new St.BoxLayout({
                x_expand: true,
                x_align: Clutter.ActorAlign.CENTER,
                style_class: 'openweather-forecast-iconbox'
            });

            fib.add_actor(todaysForecast.Icon);
            fib.add_actor(todaysForecast.Temperature);

            fb.add_actor(todaysForecast.Time);
            fb.add_actor(fib);
            if (this._comment_in_forecast)
                fb.add_actor(todaysForecast.Summary);

            this._todays_forecast[i] = todaysForecast;
            this._todaysBox.add_actor(fb);
        }
        this._currentForecast.actor.add_child(this._todaysBox);
    }

    scrollForecastBy(delta) {
        if (this._forecastScrollBox === undefined)
            return;
        this._forecastScrollBox.hscroll.adjustment.value += delta;
    }

    rebuildFutureWeatherUi(cnt) {
        if (this._isForecastDisabled || this._forecastDays === 0)
            return;
        this._forecastExpander.menu.box.destroy_all_children();

        this._forecast = [];
        this._forecastExpanderBox = new St.BoxLayout({
            x_expand: true,
            opacity: 150,
            style_class: 'openweather-forecast-expander'
        });
        this._forecastExpander.menu.box.add(this._forecastExpanderBox);

        this._daysBox = new St.BoxLayout({
            vertical: true,
            y_expand: true,
            style_class: 'openweather-forecast-box'
        });
        this._forecastBox = new St.BoxLayout({
            vertical: true,
            x_expand: true,
            style_class: 'openweather-forecast-box'
        });
        this._forecastScrollBox = new St.ScrollView({
            x_expand: true,
            style_class: 'openweather-forecasts'
        });
        let pan = new Clutter.PanAction({
            interpolate: true
        });
        pan.connect('pan', (action) => {

            let[dist, dx, dy] = action.get_motion_delta(0);

            this.scrollForecastBy(-1 * (dx / this._forecastScrollBox.width) * this._forecastScrollBox.hscroll.adjustment.page_size);
            return false;
        });
        this._forecastScrollBox.add_action(pan);
        this._forecastScrollBox.connect('scroll-event', this._onScroll.bind(this));
        this._forecastScrollBox.hscroll.connect('scroll-event', this._onScroll.bind(this));
        this._forecastScrollBox.hscroll.margin_right = 25;
        this._forecastScrollBox.hscroll.margin_left = 25;
        this._forecastScrollBox.hscroll.hide();
        this._forecastScrollBox.vscrollbar_policy = Gtk.PolicyType.NEVER;
        this._forecastScrollBox.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        this._forecastScrollBox.enable_mouse_scrolling = true;
        this._forecastScrollBox.hide();

        if (cnt === undefined)
            cnt = this._days_forecast;

        if (cnt === 1)
            this._forecastExpander.label.set_text( _("Tomorrow's Forecast") );
        else
            this._forecastExpander.label.set_text( _("%s Day Forecast").format(cnt) );

        for (let i = 0; i < cnt; i++) {
            let forecastWeather = {};

            forecastWeather.Day = new St.Label({
                style_class: 'openweather-forecast-day'
            });
            this._daysBox.add_actor(forecastWeather.Day);

            let forecastWeatherBox = new St.BoxLayout({
                x_expand: true,
                x_align: Clutter.ActorAlign.CENTER
            });

            for (let j = 0; j < 8; j++) {
                forecastWeather[j] = {};

                forecastWeather[j].Time = new St.Label({
                    style_class: 'openweather-forcast-time'
                });
                forecastWeather[j].Icon = new St.Icon({
                    icon_size: 24,
                    style_class: 'openweather-forecast-icon'
                });
                forecastWeather[j].Temperature = new St.Label({
                    style_class: 'openweather-forecast-temperature'
                });
                forecastWeather[j].Summary = new St.Label({
                    style_class: 'openweather-forecast-summary'
                });
                forecastWeather[j].Summary.clutter_text.line_wrap = true;

                let by = new St.BoxLayout({
                    vertical: true,
                    x_expand: true,
                    style_class: 'openweather-forecast-databox'
                });
                let bib = new St.BoxLayout({
                    x_expand: true,
                    x_align: Clutter.ActorAlign.CENTER,
                    style_class: 'openweather-forecast-iconbox'
                });

                bib.add_actor(forecastWeather[j].Icon);
                bib.add_actor(forecastWeather[j].Temperature);

                by.add_actor(forecastWeather[j].Time);
                by.add_actor(bib);
                if (this._comment_in_forecast)
                    by.add_actor(forecastWeather[j].Summary);
                forecastWeatherBox.add_actor(by);
            }
            this._forecast[i] = forecastWeather;
            this._forecastBox.add_actor(forecastWeatherBox);
        }
        this._forecastScrollBox.add_actor(this._forecastBox);
        this._forecastExpanderBox.add_actor(this._daysBox);
        this._forecastExpanderBox.add_actor(this._forecastScrollBox);
    }

    _onScroll(actor, event) {
        if (this._isForecastDisabled)
            return;

        let dx = 0;
        let dy = 0;
        switch (event.get_scroll_direction()) {
            case Clutter.ScrollDirection.UP:
            case Clutter.ScrollDirection.RIGHT:
                dy = -1;
                break;
            case Clutter.ScrollDirection.DOWN:
            case Clutter.ScrollDirection.LEFT:
                dy = 1;
                break;
            default:
                return true;
        }

        this.scrollForecastBy(dy * this._forecastScrollBox.hscroll.adjustment.stepIncrement);
        return false;
    }
});

let openWeatherMenu;

function init() {
    ExtensionUtils.initTranslations(Me.metadata['gettext-domain']);
}

function enable() {
    openWeatherMenu = new OpenWeatherMenuButton();
    Main.panel.addToStatusArea('openWeatherMenu', openWeatherMenu);
}

function disable() {
    openWeatherMenu.stop();
    openWeatherMenu.destroy();
    openWeatherMenu = null;
}
