/* exported init enable disable */
// Drive menu extension
const { Clutter, Gio, GObject, Shell, St } = imports.gi;

const ExtensionUtils = imports.misc.extensionUtils;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const ShellMountOperation = imports.ui.shellMountOperation;

const _ = ExtensionUtils.gettext;

Gio._promisify(Gio.File.prototype, 'query_filesystem_info_async');

class MountMenuItem extends PopupMenu.PopupBaseMenuItem {
    static {
        GObject.registerClass(this);
    }

    constructor(mount) {
        super({
            style_class: 'drive-menu-item',
        });

        this.label = new St.Label({
            text: mount.get_name(),
            x_expand: true,
            y_align: Clutter.ActorAlign.CENTER,
        });
        this.add_child(this.label);
        this.label_actor = this.label;

        this.mount = mount;

        this.connect('destroy', this._onDestroy.bind(this));

        let ejectIcon = new St.Icon({
            icon_name: 'media-eject-symbolic',
            style_class: 'popup-menu-icon',
        });
        let ejectButton = new St.Button({
            child: ejectIcon,
            style_class: 'button',
        });
        ejectButton.connect('clicked', this._eject.bind(this));
        this.add(ejectButton);

        this.hide();

        this._changedId = mount.connect('changed', this._syncVisibility.bind(this));
        this._syncVisibility();
    }

    _onDestroy() {
        if (this._changedId) {
            this.mount.disconnect(this._changedId);
            this._changedId = 0;
        }

        super.destroy();
    }

    async _isInteresting() {
        if (!this.mount.can_eject() && !this.mount.can_unmount())
            return false;
        if (this.mount.is_shadowed())
            return false;

        let volume = this.mount.get_volume();

        if (volume)
            return volume.get_identifier('class') !== 'network';

        const root = this.mount.get_root();

        try {
            const attr = Gio.FILE_ATTRIBUTE_FILESYSTEM_REMOTE;
            const info = await root.query_filesystem_info_async(attr, null);
            return !info.get_attribute_boolean(attr);
        } catch (e) {
            log(`Failed to query filesystem: ${e.message}`);
        }

        // Hack, fall back to looking at GType
        return Gio._LocalFilePrototype.isPrototypeOf(root);
    }

    async _syncVisibility() {
        this.visible = await this._isInteresting();
    }

    _eject() {
        let unmountArgs = [
            Gio.MountUnmountFlags.NONE,
            new ShellMountOperation.ShellMountOperation(this.mount).mountOp,
            null, // Gio.Cancellable
        ];

        if (this.mount.can_eject()) {
            this.mount.eject_with_operation(...unmountArgs,
                this._ejectFinish.bind(this));
        } else {
            this.mount.unmount_with_operation(...unmountArgs,
                this._unmountFinish.bind(this));
        }
    }

    _unmountFinish(mount, result) {
        try {
            mount.unmount_with_operation_finish(result);
        } catch (e) {
            this._reportFailure(e);
        }
    }

    _ejectFinish(mount, result) {
        try {
            mount.eject_with_operation_finish(result);
        } catch (e) {
            this._reportFailure(e);
        }
    }

    _reportFailure(exception) {
        // TRANSLATORS: %s is the filesystem name
        let msg = _('Ejecting drive “%s” failed:').format(this.mount.get_name());
        Main.notifyError(msg, exception.message);
    }

    activate(event) {
        let uri = this.mount.get_root().get_uri();
        let context = global.create_app_launch_context(event.get_time(), -1);
        Gio.AppInfo.launch_default_for_uri(uri, context);

        super.activate(event);
    }
}

class DriveMenu extends PanelMenu.Button {
    static {
        GObject.registerClass(this);
    }

    constructor() {
        super(0.0, _('Removable devices'));

        let icon = new St.Icon({
            icon_name: 'media-eject-symbolic',
            style_class: 'system-status-icon',
        });

        this.add_child(icon);

        this._monitor = Gio.VolumeMonitor.get();
        this._addedId = this._monitor.connect('mount-added',
            (monitor, mount) => this._addMount(mount));
        this._removedId = this._monitor.connect('mount-removed', (monitor, mount) => {
            this._removeMount(mount);
            this._updateMenuVisibility();
        });

        this._mounts = [];

        this._monitor.get_mounts().forEach(this._addMount.bind(this));

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        this.menu.addAction(_('Open Files'), event => {
            let appSystem = Shell.AppSystem.get_default();
            let app = appSystem.lookup_app('org.gnome.Nautilus.desktop');
            app.activate_full(-1, event.get_time());
        });

        this._updateMenuVisibility();
    }

    _updateMenuVisibility() {
        if (this._mounts.filter(i => i.visible).length > 0)
            this.show();
        else
            this.hide();
    }

    _addMount(mount) {
        let item = new MountMenuItem(mount);
        this._mounts.unshift(item);
        this.menu.addMenuItem(item, 0);

        item.connect('notify::visible', () => this._updateMenuVisibility());
    }

    _removeMount(mount) {
        for (let i = 0; i < this._mounts.length; i++) {
            let item = this._mounts[i];
            if (item.mount === mount) {
                item.destroy();
                this._mounts.splice(i, 1);
                return;
            }
        }
        log('Removing a mount that was never added to the menu');
    }

    _onDestroy() {
        if (this._addedId) {
            this._monitor.disconnect(this._addedId);
            this._monitor.disconnect(this._removedId);
            this._addedId = 0;
            this._removedId = 0;
        }

        super._onDestroy();
    }
}

/** */
function init() {
    ExtensionUtils.initTranslations();
}

let _indicator;

/** */
function enable() {
    _indicator = new DriveMenu();
    Main.panel.addToStatusArea('drive-menu', _indicator);
}

/** */
function disable() {
    _indicator.destroy();
}
