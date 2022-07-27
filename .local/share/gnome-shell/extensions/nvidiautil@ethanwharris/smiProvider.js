/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported SmiProvider */
'use strict';

const Main = imports.ui.main;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const Processor = Me.imports.processor;
const SmiProperties = Me.imports.smiProperties;
const Subprocess = Me.imports.subprocess;

var SmiProvider = class {
    getGpuNames() {
        return Subprocess.execCommunicate(['nvidia-smi', '--query-gpu=gpu_name', '--format=csv,noheader'])
      .then(output => output.split('\n').map((gpu, index) => `${index}: ${gpu}`));
    }

    getProperties(gpuCount) {
        this.storedProperties = [
            new SmiProperties.UtilisationProperty(gpuCount, Processor.NVIDIA_SMI),
            new SmiProperties.TemperatureProperty(gpuCount, Processor.NVIDIA_SMI),
            new SmiProperties.MemoryProperty(gpuCount, Processor.NVIDIA_SMI),
            new SmiProperties.FanProperty(gpuCount, Processor.NVIDIA_SMI),
            new SmiProperties.PowerProperty(gpuCount, Processor.NVIDIA_SMI),
        ];
        return this.storedProperties;
    }

    retrieveProperties() {
        return this.storedProperties;
    }

    hasSettings() {
        return false;
    }

    openSettings() {
        Main.notifyError('Settings are not available in smi mode', 'Switch to a provider which supports nivida-settings');
    }
};
