/* SPDX-License-Identifier: GPL-3.0-or-later */
/* SPDX-FileCopyrightText: Contributors to the gnome-nvidia-extension project. */

/* exported Property */
'use strict';

var Property = class {
    // Abstract: true,
    constructor(processor, name, callExtension, icon, formatter, gpuCount) {
        this._processor = processor;
        this._name = name;
        this._callExtension = callExtension;
        this._icon = icon;
        this._formatter = formatter;
        this._gpuCount = gpuCount;
    }

    getName() {
        return this._name;
    }

    getCallExtension() {
        return this._callExtension;
    }

    getIcon() {
        return this._icon;
    }

    parse(lines) {
        let values = [];

        for (let i = 0; i < this._gpuCount; i++)
            values = values.concat(this._formatter.format([lines.shift()]));


        return values;
    }

    declare() {
        return this._processor;
    }
};
