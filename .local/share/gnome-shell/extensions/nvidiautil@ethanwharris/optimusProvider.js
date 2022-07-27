/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported OptimusProvider */
'use strict';

const Shell = imports.gi.Shell;
const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const Processor = Me.imports.processor;
const SmiProperties = Me.imports.smiProperties;
const Subprocess = Me.imports.subprocess;

var OptimusProvider = class {
    getGpuNames() {
        return Subprocess.execCommunicate(['optirun', 'nvidia-smi', '--query-gpu=gpu_name', '--format=csv,noheader'])
      .then(output => output.split('\n').map((gpu, index) => `${index}: ${gpu}`));
    }

    getProperties(gpuCount) {
        this.storedProperties = [
            new SmiProperties.UtilisationProperty(gpuCount, Processor.OPTIMUS),
            new SmiProperties.TemperatureProperty(gpuCount, Processor.OPTIMUS),
            new SmiProperties.MemoryProperty(gpuCount, Processor.OPTIMUS),
            new SmiProperties.FanProperty(gpuCount, Processor.OPTIMUS),
            new SmiProperties.PowerProperty(gpuCount, Processor.OPTIMUS),
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
            Subprocess.execCheck(['optirun', '-b', 'none', 'nvidia-settings', '-c', ':8']).catch(e => {
                let title = 'Failed to open nvidia-settings:';
                Main.notifyError(title, e.message);
            });
        }
    }
};
