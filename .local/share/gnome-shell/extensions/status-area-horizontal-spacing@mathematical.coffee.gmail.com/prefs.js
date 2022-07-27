const GLib = imports.gi.GLib;
const GObject = imports.gi.GObject;
const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;

const Gettext = imports.gettext.domain('gnome-shell-extensions');
const _ = Gettext.gettext;

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

function init() {
    ExtensionUtils.initTranslations();
}

const StatusAreaHorizontalSpacingPrefsWidget = new GObject.Class({
    Name: 'StatusAreaHorizontalSpacing.Prefs.Widget',
    GTypeName: 'StatusAreaHorizontalSpacingPrefsWidget',
    Extends: Gtk.Grid,

    _init: function(params) {
        this.parent(params);
            this.margin = this.row_spacing = this.column_spacing = 10;

        this._settings = ExtensionUtils.getSettings();
        this.attach(new Gtk.Label({ label: _("Horizontal Padding") }), 0, 0, 1, 1);
        let hscale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 12, 1);
            hscale.set_value(this._settings.get_int('hpadding'));
            hscale.set_digits(0);
            hscale.set_hexpand(true);
            hscale.connect('value-changed', this._onHpaddingChanged.bind(this));
        this.attach(hscale, 1, 0, 1, 1);
        this._hscale = hscale;
    },

    _onHpaddingChanged: function (hscale) {
        this._settings.set_int('hpadding', this._hscale.get_value());
        //log('hpadding changed! ' + this._settings.get_int('hpadding'));
    }
});

function buildPrefsWidget() {
    let widget = new StatusAreaHorizontalSpacingPrefsWidget();
    if (widget.show_all)
      widget.show_all();

    return widget;
}
