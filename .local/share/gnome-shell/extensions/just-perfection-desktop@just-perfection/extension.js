/**
 * Extension
 *
 * @author     Javad Rahmatzadeh <j.rahmatzadeh@gmail.com>
 * @copyright  2020-2022
 * @license    GPL-3.0-only
 */

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const {API, Manager} = Me.imports.lib;
const {GObject, GLib, Gio, St, Clutter, Meta} = imports.gi;

const Util = imports.misc.util;
const Config = imports.misc.config;
const shellVersion = parseFloat(Config.PACKAGE_VERSION);

const Main = imports.ui.main;
const BackgroundMenu = imports.ui.backgroundMenu;
const OverviewControls = imports.ui.overviewControls;
const WorkspaceSwitcherPopup = imports.ui.workspaceSwitcherPopup;
const ViewSelector = (shellVersion < 40) ? imports.ui.viewSelector : null;
const WorkspaceThumbnail = imports.ui.workspaceThumbnail;
const SearchController = (shellVersion >= 40) ? imports.ui.searchController : null;
const Panel = imports.ui.panel;
const WorkspacesView = imports.ui.workspacesView;
const WindowPreview = (shellVersion >= 3.38) ? imports.ui.windowPreview : null;
const Workspace = imports.ui.workspace;
const LookingGlass = imports.ui.lookingGlass;
const MessageTray = imports.ui.messageTray;
const OSDWindow = imports.ui.osdWindow;
const WindowMenu = imports.ui.windowMenu;
const AltTab = imports.ui.altTab;

let manager;
let api;

/**
 * initiate extension
 *
 * @returns {void}
 */
function init()
{
}

/**
 * enable extension
 *
 * @returns {void}
 */
function enable()
{
    // <3.36 can crash by enabling the extension
    // since <3.36 is not supported we simply return
    // to avoid bad experience for <3.36 users.
    if (shellVersion < 3.36) {
        return;
    }

    let InterfaceSettings = new Gio.Settings({schema_id: 'org.gnome.desktop.interface'});

    api = new API.API({
        Main,
        BackgroundMenu,
        OverviewControls,
        WorkspaceSwitcherPopup,
        InterfaceSettings,
        SearchController,
        ViewSelector,
        WorkspaceThumbnail,
        WorkspacesView,
        Panel,
        WindowPreview,
        Workspace,
        LookingGlass,
        MessageTray,
        OSDWindow,
        WindowMenu,
        AltTab,
        St,
        Gio,
        GLib,
        Clutter,
        Util,
        Meta,
        GObject,
    }, shellVersion);

    api.open();

    let settings = ExtensionUtils.getSettings();

    manager = new Manager.Manager({
        API: api,
        Settings: settings,
    }, shellVersion);

    manager.registerSettingsSignals();
    manager.applyAll();
}

/**
 * disable extension
 *
 * @returns {void}
 */
function disable()
{
    if (manager) {
        manager.revertAll();
        manager = null;
    }

    if (api) {
        api.close();
        api = null;
    }
}

