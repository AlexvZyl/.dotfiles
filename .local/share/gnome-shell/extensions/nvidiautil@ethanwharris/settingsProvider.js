/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported SettingsProvider */
'use strict';

const Shell = imports.gi.Shell;
const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const Processor = Me.imports.processor;
const SettingsProperties = Me.imports.settingsProperties;
const Subprocess = Me.imports.subprocess;

var SettingsProvider = class {
    getGpuNames() {
        return Subprocess.execCommunicate(['nvidia-settings', '-q', 'GpuUUID', '-t'])
      .then(output => output.split('\n').map((gpu, index) => `GPU ${index}`));
    }

    getProperties(gpuCount) {
        this.storedProperties = [
            new SettingsProperties.UtilisationProperty(gpuCount, Processor.NVIDIA_SETTINGS),
            new SettingsProperties.TemperatureProperty(gpuCount, Processor.NVIDIA_SETTINGS),
            new SettingsProperties.MemoryProperty(gpuCount, Processor.NVIDIA_SETTINGS),
            new SettingsProperties.FanProperty(gpuCount, Processor.NVIDIA_SETTINGS),
        ];
        return this.storedProperties;
    }

    retrieveProperties() {
        return this.storedProperties;
    }

    hasSettings() {
        return true;
    }

    openSettings() {
        let defaultAppSystem = Shell.AppSystem.get_default();
        let nvidiaSettingsApp = defaultAppSystem.lookup_app('nvidia-settings.desktop');

        if (!nvidiaSettingsApp) {
            Main.notifyError("Couldn't find nvidia-settings on your device", 'Check you have it installed correctly');
            return;
        }

        if (nvidiaSettingsApp.get_n_windows()) {
            nvidiaSettingsApp.activate();
        } else {
            Subprocess.execCheck(['nvidia-settings']).catch(e => {
                let title = 'Failed to open nvidia-settings:';
                Main.notifyError(title, e.message);
            });
        }
    }
};
