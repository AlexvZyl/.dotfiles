/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported UtilisationProperty PowerProperty TemperatureProperty MemoryProperty FanProperty */
'use strict';

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

const Property = Me.imports.property;
const Formatter = Me.imports.formatter;
const GIcons = Me.imports.gIcons;

var UtilisationProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Utilisation', 'utilization.gpu,', GIcons.Icon.Card.get(),
            new Formatter.PercentFormatter('UtilisationFormatter'), gpuCount);
    }
};

var PowerProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Power Usage (W)', 'power.draw,', GIcons.Icon.Power.get(),
            new Formatter.PowerFormatter(), gpuCount);
    }
};

var TemperatureProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Temperature', 'temperature.gpu,', GIcons.Icon.Temp.get(),
            new Formatter.TempFormatter(Formatter.CENTIGRADE), gpuCount);
    }

    setUnit(unit) {
        this._formatter.setUnit(unit);
    }
};

var MemoryProperty = class extends Property.Property {
    constructor(gpuCount, processor) {
        super(processor, 'Memory Usage', 'memory.used,memory.total,', GIcons.Icon.RAM.get(),
            new Formatter.MemoryFormatter('MemoryFormatter'), gpuCount);
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
        super(processor, 'Fan Speed', 'fan.speed,', GIcons.Icon.Fan.get(),
            new Formatter.PercentFormatter('FanFormatter'), gpuCount);
    }
};
