"use strict";

const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;

const Config = imports.misc.config;
const ShellVersion = parseFloat(Config.PACKAGE_VERSION);

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

function init() {}

function buildPrefsWidget() {
  this.settings = ExtensionUtils.getSettings();
  let prefsWidget;

  // gtk4 apps do not have a margin property
  if (ShellVersion >= 40) {
    prefsWidget = new Gtk.Grid({
      margin_start: 18,
      margin_end: 18,
      margin_top: 18,
      margin_bottom: 18,
      column_spacing: 12,
      row_spacing: 12,
    });
  } else {
    prefsWidget = new Gtk.Grid({
      margin: 18,
      column_spacing: 12,
      row_spacing: 12,
    });
  }

  let title = new Gtk.Label({
    label: "<b>Improved Workspace Indicator Preferences</b>",
    halign: Gtk.Align.START,
    use_markup: true,
  });

  prefsWidget.attach(title, 0, 0, 2, 1);

  // Panel Position Chooser

  let panel_position_label = new Gtk.Label({
    label: "Panel Position",
    halign: Gtk.Align.START,
  });

  let panel_position_combo = new Gtk.ComboBoxText();
  panel_position_combo.append("left", "left");
  panel_position_combo.append("right", "right");
  panel_position_combo.append("center", "center");

  panel_position_combo.active_id = this.settings.get_string("panel-position");

  prefsWidget.attach(panel_position_label, 0, 1, 2, 1);
  prefsWidget.attach(panel_position_combo, 2, 1, 2, 1);

  this.settings.bind(
    "panel-position",
    panel_position_combo,
    "active_id",
    Gio.SettingsBindFlags.DEFAULT
  );

  // Skip Taskbar Mode Selector

  let skip_taskbar_mode_label = new Gtk.Label({
    label:
      "Ignore Taskbar-Skipped Windows\r" +
      "<small>These include hidden windows from the desktop-icons-ng extension.</small>",
    halign: Gtk.Align.START,
    use_markup: true,
  });

  let skip_taskbar_mode_toggle = new Gtk.Switch({
    active: this.settings.get_boolean("skip-taskbar-mode"),
    halign: Gtk.Align.END,
    visible: true,
  });

  prefsWidget.attach(skip_taskbar_mode_label, 0, 2, 2, 1);
  prefsWidget.attach(skip_taskbar_mode_toggle, 2, 2, 2, 1);

  this.settings.bind(
    "skip-taskbar-mode",
    skip_taskbar_mode_toggle,
    "active",
    Gio.SettingsBindFlags.DEFAULT
  );

  // Enable / Disable change on click

  let change_on_click_label = new Gtk.Label({
    label: "Change workspace on indicator click",
    halign: Gtk.Align.START,
  });

  let change_on_click_toggle = new Gtk.Switch({
    active: this.settings.get_boolean("change-on-click"),
    halign: Gtk.Align.END,
    visible: true,
  });

  prefsWidget.attach(change_on_click_label, 0, 3, 2, 1);
  prefsWidget.attach(change_on_click_toggle, 2, 3, 2, 1);

  this.settings.bind(
    "change-on-click",
    change_on_click_toggle,
    "active",
    Gio.SettingsBindFlags.DEFAULT
  );

  // only gtk3 apps need to run show_all()
  if (ShellVersion < 40) {
    prefsWidget.show_all();
  }

  return prefsWidget;
}
