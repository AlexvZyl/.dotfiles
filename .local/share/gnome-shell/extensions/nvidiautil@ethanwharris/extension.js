/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported init enable disable */
'use strict';

const {Clutter, GLib, GObject, St} = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const ProcessorHandler = Me.imports.processorHandler;
const SettingsProvider = Me.imports.settingsProvider;
const SmiProvider = Me.imports.smiProvider;
const SettingsAndSmiProvider = Me.imports.settingsAndSmiProvider;
const OptimusProvider = Me.imports.optimusProvider;
const GIcons = Me.imports.gIcons;

const SETTINGS_REFRESH = 'refreshrate';
const SETTINGS_PROVIDER = 'provider';
const SETTINGS_POSITION = 'position';
const SETTINGS_TEMP_UNIT = 'tempformat';
const SETTINGS_SPACING = 'spacing';
const SETTINGS_ICONS = 'icons';

const PROVIDERS = [
    SettingsAndSmiProvider.SettingsAndSmiProvider,
    SettingsProvider.SettingsProvider,
    SmiProvider.SmiProvider,
    OptimusProvider.OptimusProvider,
];

const PROVIDER_SETTINGS = [
    'settingsandsmiconfig',
    'settingsconfig',
    'smiconfig',
    'optimusconfig',
];

const PropertyMenuItem = GObject.registerClass(
class PropertyMenuItem extends PopupMenu.PopupBaseMenuItem {
    _init(property, box, labelManager, settings, setting, index) {
        super._init();

        this._destroyed = false;

        this._settings = settings;
        this._setting = setting;
        this._index = index;

        this._box = box;
        this.labelManager = labelManager;

        this.actor.add(new St.Icon({style_class: 'popup-menu-icon', gicon: property.getIcon(), icon_size: 16}));

        this.label = new St.Label({text: property.getName()});
        this.actor.add_child(this.label);
        this.actor.label_actor = this.label;

        this._icon = new St.Icon({style_class: 'system-status-icon', gicon: property.getIcon(), icon_size: 16});

        this._statisticLabelHidden = new St.Label({text: '0'});
        this._statisticLabelVisible = new St.Label({
            text: '0',
            style_class: 'label',
            y_expand: true,
            y_align: Clutter.ActorAlign.CENTER,
        });

        this._box.add_child(this._icon);
        this._box.add_child(this._statisticLabelVisible);

        this.actor.add(this._statisticLabelHidden);
        this._visible = false;
        this._box.visible = false;

        this.actor.old_add_style_pseudo_class = this.actor.add_style_pseudo_class;
        this.actor.old_remove_style_pseudo_class = this.actor.remove_style_pseudo_class;

        this.actor.add_style_pseudo_class = this.patch_add_pseudo_class;
        this.actor.remove_style_pseudo_class = this.patch_remove_pseudo_class;
    }

    set_pseudo_class() {
        if (this._visible)
            this.actor.old_add_style_pseudo_class('active');
        else
            this.actor.old_remove_style_pseudo_class('active');
    }

    patch_add_pseudo_class(css) {
        if (css === 'active')
            this.set_pseudo_class();
        else
            this.actor.old_add_style_pseudo_class(css);
    }

    patch_remove_pseudo_class(css) {
        if (css === 'active')
            this.set_pseudo_class();
        else
            this.actor.old_remove_style_pseudo_class(css);
    }

    reloadBox(spacing, icons) {
        if (!this._destroyed) {
            this._icon.visible = icons;

            this._statisticLabelVisible.set_style(`margin-right: ${spacing}px`);
        }
    }

    destroy() {
        this._destroyed = true;

        this._box.destroy();
        this._statisticLabelHidden.destroy();

        super.destroy();
        this.activate = function () {
            // Do Nothing
        };
        this.handle = function () {
            // Do Nothing
        };
        this.setActive = function () {
            // Do Nothing
        };
    }

    activate() {
        if (this._visible) {
            this._visible = false;
            this._box.visible = false;
            this.set_pseudo_class();
            this.labelManager.decrement();

            let flags = this._settings.get_strv(this._setting);
            flags[this._index] = 'inactive';
            this._settings.set_strv(this._setting, flags);
        } else {
            this._visible = true;
            this._box.visible = true;
            this.set_pseudo_class();
            this.labelManager.increment();

            let flags = this._settings.get_strv(this._setting);
            flags[this._index] = 'active';
            this._settings.set_strv(this._setting, flags);
        }
    }

    setActive(active) {
        super.setActive(active);
        if (this._visible)
            this.actor.add_style_pseudo_class('active');
    }

    handle(value) {
        this._statisticLabelHidden.text = value;
        this._statisticLabelVisible.text = value;
        if (value === 'ERR') {
            if (this._visible)
                this.activate('');


            this.destroy();
        }
    }
});

class _PersistentPopupMenu extends PopupMenu.PopupMenu {
    constructor(actor, menuAlignment) {
        super(actor, menuAlignment, St.Side.TOP, 0);
    }

    _setOpenedSubMenu(submenu) {
        this._openedSubMenu = submenu;
    }
}

class _GpuLabelDisplayManager {
    constructor(gpuLabel) {
        this.gpuLabel = gpuLabel;
        this.count = 0;
        this.gpuLabel.visible = false;
    }

    increment() {
        this.count += 1;

        if (this.gpuLabel.visible === false)
            this.gpuLabel.visible = true;
    }

    decrement() {
        this.count -= 1;

        if (this.count === 0 && this.gpuLabel.visible === true)
            this.gpuLabel.visible = false;
    }
}

class _EmptyDisplayManager {
    increment() {
        // Do Nothing
    }

    decrement() {
        // Do Nothing
    }
}

const MainMenu = GObject.registerClass(
class MainMenu extends PanelMenu.Button {
    _init(settings) {
        super._init(0.0, 'GPU Statistics');
        this.timeoutId = -1;
        this._settings = settings;
        this._error = false;

        this.processor = new ProcessorHandler.ProcessorHandler();

        this.setMenu(new _PersistentPopupMenu(this, 0.0));

        let hbox = new St.BoxLayout({style_class: 'panel-status-menu-box'});

        this.properties = new St.BoxLayout({style_class: 'panel-status-menu-box'});

        hbox.add_actor(this.properties);
        hbox.add_actor(PopupMenu.arrowIcon(St.Side.BOTTOM));
        this.add_child(hbox);

        this._reload();
        this._updatePollTime();

        this._settingChangedSignals = [];
        this._addSettingChangedSignal(SETTINGS_PROVIDER, () => this._reload());
        this._addSettingChangedSignal(SETTINGS_REFRESH, () => this._updatePollTime());
        this._addSettingChangedSignal(SETTINGS_TEMP_UNIT, () => this._updateTempUnits());
        this._addSettingChangedSignal(SETTINGS_POSITION, () => this._updatePanelPosition());
        this._addSettingChangedSignal(SETTINGS_SPACING, () => this._updateSpacing());
        this._addSettingChangedSignal(SETTINGS_ICONS, () => this._updateSpacing());
    }

    _reload() {
        this.menu.removeAll();

        this._propertiesMenu = new PopupMenu.PopupMenuSection();
        this.menu.addMenuItem(this._propertiesMenu);

        this.properties.destroy_all_children();

        this.processor.reset();

        let p = this._settings.get_int(SETTINGS_PROVIDER);
        this.provider = new PROVIDERS[p]();

        let flags = this._settings.get_strv(PROVIDER_SETTINGS[p]);

        this.provider.getGpuNames().then(names => {
            this.names = names;

            let listeners = [];

            this.providerProperties = this.provider.getProperties(this.names.length);

            for (let i = 0; i < this.providerProperties.length; i++)
                listeners[i] = [];


            for (let n = 0; n < this.names.length; n++) {
                let submenu = new PopupMenu.PopupSubMenuMenuItem(this.names[n]);

                let manager;

                if (this.names.length > 1) {
                    let style = 'gpulabel';
                    if (n === 0)
                        style = 'gpulabelleft';

                    let label = new St.Label({text: `${n}:`, style_class: style});
                    manager = new _GpuLabelDisplayManager(label);
                    this.properties.add_child(label);
                } else {
                    manager = new _EmptyDisplayManager();
                }

                this._propertiesMenu.addMenuItem(submenu);

                for (let i = 0; i < this.providerProperties.length; i++) {
                    let box = new St.BoxLayout({style_class: 'panel-status-menu-box'});

                    let index = (n * this.providerProperties.length) + i;
                    let item = new PropertyMenuItem(this.providerProperties[i], box, manager, this._settings, PROVIDER_SETTINGS[p], index);

                    if (this.providerProperties[i].getName() === 'Temperature') {
                        let unit = this._settings.get_int(SETTINGS_TEMP_UNIT);
                        this.providerProperties[i].setUnit(unit);
                    }

                    listeners[i][n] = item;
                    submenu.menu.addMenuItem(item);
                    this.properties.add_child(box);
                }
            }

            for (let i = 0; i < this.providerProperties.length; i++)
                this.processor.addProperty(this.providerProperties[i], listeners[i]);


            this.processor.process();

            for (let n = 0; n < this.names.length; n++) {
                for (let i = 0; i < this.providerProperties.length; i++) {
                    let index = (n * this.providerProperties.length) + i;

                    if (!flags[index])
                        flags[index] = 'inactive';


                    if (flags[index] === 'active')
                        listeners[i][n].activate();
                }
            }

            this._items = listeners;

            this._updateSpacing();

            this._settings.set_strv(PROVIDER_SETTINGS[p], flags);
        }).catch(() => {
            this._error = true;
        });

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        let item = new PopupMenu.PopupBaseMenuItem({
            reactive: false,
            can_focus: false,
        });

        this.wrench = new St.Button({
            reactive: true,
            can_focus: true,
            track_hover: true,
            accessible_name: 'Open Preferences',
            style_class: 'button',
            child: new St.Icon({
                icon_name: GIcons.Icon.Wrench.name,
                gicon: GIcons.Icon.Wrench.get(),
            }),
        });
        this.wrench.connect('clicked', () => {
            ExtensionUtils.openPrefs();
        });
        item.add_child(this.wrench);

        if (this.provider.hasSettings()) {
            this.cog = new St.Button({
                reactive: true,
                can_focus: true,
                track_hover: true,
                accessible_name: 'Open Nvidia Settings',
                style_class: 'button',
                child: new St.Icon({
                    icon_name: GIcons.Icon.Cog.name,
                    gicon: GIcons.Icon.Cog.get(),
                }),
            });
            this.cog.connect('clicked', () => this.provider.openSettings());
            item.actor.add_child(this.cog);
        }

        this.menu.addMenuItem(item);
    }

    _updatePollTime() {
        if (!this._error)
            this._addTimeout(this._settings.get_int(SETTINGS_REFRESH));
    }

    _updateTempUnits() {
        let unit = 0;

        for (let i = 0; i < this.providerProperties.length; i++) {
            if (this.providerProperties[i].getName() === 'Temperature') {
                unit = this._settings.get_int(SETTINGS_TEMP_UNIT);
                this.providerProperties[i].setUnit(unit);
            }
        }
        this.processor.process();
    }

    _updatePanelPosition() {
        this.container.get_parent().remove_actor(this.container);

        let boxes = {
            left: Main.panel._leftBox,
            center: Main.panel._centerBox,
            right: Main.panel._rightBox,
        };

        let pos = this.getPanelPosition();
        boxes[pos].insert_child_at_index(this.container, pos === 'right' ? 0 : -1);
    }

    getPanelPosition() {
        let positions = ['left', 'center', 'right'];
        return positions[_settings.get_int(SETTINGS_POSITION)];
    }

    _updateSpacing() {
        let spacing = _settings.get_int(SETTINGS_SPACING);
        let icons = _settings.get_boolean(SETTINGS_ICONS);

        for (let n = 0; n < this.names.length; n++) {
            for (let i = 0; i < this.providerProperties.length; i++)
                this._items[i][n].reloadBox(spacing, icons);
        }
    }

    /* Create and add the timeout which updates values every t seconds */
    _addTimeout(t) {
        this._removeTimeout();

        this.timeoutId = GLib.timeout_add_seconds(0, t, () => {
            this.processor.process();
            return true;
        });
    }

    /* Remove current timeout */
    _removeTimeout() {
        if (this.timeoutId !== -1) {
            GLib.source_remove(this.timeoutId);
            this.timeoutId = -1;
        }
    }

    _addSettingChangedSignal(key, callback) {
        this._settingChangedSignals.push(this._settings.connect(`changed::${key}`, callback));
    }

    destroy() {
        this._removeTimeout();

        for (let signal of this._settingChangedSignals)
            this._settings.disconnect(signal);


        super.destroy();
    }
});

let _menu;
let _settings;

/**
 * When the extension is enabled, add the menu to gnome panel
 */
function enable() {
    _settings = ExtensionUtils.getSettings();
    _menu = new MainMenu(_settings);

    let pos = _menu.getPanelPosition();
    Main.panel.addToStatusArea('main-menu', _menu, pos === 'right' ? 0 : -1, pos);
}

/**
 * When the extension is disabled, remove the menu from gnome panel
 */
function disable() {
    _menu.destroy();
    _menu = null;
    _settings = null;
}
