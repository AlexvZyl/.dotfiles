/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported UtilisationProperty TemperatureProperty MemoryProperty FanProperty */
'use strict';

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const Formatter = Me.imports.formatter;
const Property = Me.imports.property;
const GIcons = Me.imports.gIcons;

var UtilisationProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Utilisation', '-q GPUUtilization ', GIcons.Icon.Card.get(),
            new Formatter.PercentFormatter('UtilisationFormatter'), gpuCount);
    }

    parse(lines) {
        for (let i = 0; i < this._gpuCount; i++)
            lines[i] = lines[i].substring(9, 11);


        return super.parse(lines);
    }
};

var TemperatureProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Temperature', '-q [GPU]/GPUCoreTemp ', GIcons.Icon.Temp.get(),
            new Formatter.TempFormatter(Formatter.CENTIGRADE), gpuCount);
    }

    setUnit(unit) {
        this._formatter.setUnit(unit);
    }
};

var MemoryProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Memory Usage', '-q UsedDedicatedGPUMemory -q TotalDedicatedGPUMemory ', GIcons.Icon.RAM.get(),
            new Formatter.MemoryFormatter(), gpuCount);
    }

    parse(lines) {
        let values = [];
        let used_memory = [];

        for (let i = 0; i < this._gpuCount; i++)
            used_memory[i] = lines.shift();


        for (let i = 0; i < this._gpuCount; i++) {
            let total_memory = lines.shift();

            values = values.concat(this._formatter.format([used_memory[i], total_memory]));
        }

        return values;
    }
};

var FanProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Fan Speed', '-q GPUCurrentFanSpeed ', GIcons.Icon.Fan.get(),
            new Formatter.PercentFormatter('FanFormatter'), gpuCount);
    }
};
