/**
 * Prefs Dialog
 *
 * @author     Javad Rahmatzadeh <j.rahmatzadeh@gmail.com>
 * @copyright  2020-2022
 * @license    GPL-3.0-only
 */

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const {Prefs, PrefsKeys} = Me.imports.lib.Prefs;
const {Gtk, Gdk, Gio, GLib, GObject} = imports.gi;

const Config = imports.misc.config;
const shellVersion = parseFloat(Config.PACKAGE_VERSION);

const gettextDomain = Me.metadata['gettext-domain'];
const UIFolderPath = Me.dir.get_child('ui').get_path();
const binFolderPath = Me.dir.get_child('bin').get_path();

/**
 * prefs widget
 *
 * @param {boolean} isAdw whether it is calling for adw ui
 *
 * @returns {Prefs.Prefs}
 */
function getPrefs(isAdw)
{
    let builder = new Gtk.Builder();
    let settings = ExtensionUtils.getSettings();
    let prefsKeys = new PrefsKeys.PrefsKeys(shellVersion, isAdw);

    return new Prefs.Prefs(
        {
            Builder: builder,
            Settings: settings,
            GObjectBindingFlags: GObject.BindingFlags,
            Gtk,
            Gdk,
            Gio,
            GLib,
        },
        prefsKeys,
        shellVersion
    );
}

/**
 * prefs initiation
 *
 * @returns {void}
 */
function init()
{
    ExtensionUtils.initTranslations();
}

/**
 * fill prefs window
 *
 * @returns {Adw.PreferencesWindow}
 */
function fillPreferencesWindow(window)
{
    getPrefs(true).fillPrefsWindow(window, UIFolderPath, binFolderPath, gettextDomain);
}

/**
 * prefs widget
 *
 * @returns {Gtk.Widget}
 */
function buildPrefsWidget()
{
    return getPrefs(false).getPrefsWidget(UIFolderPath, binFolderPath, gettextDomain);
}

