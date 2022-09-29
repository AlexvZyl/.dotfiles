"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FILES = exports.PATHS = void 0;
const path_1 = require("path");
exports.PATHS = {
    rootDir: (0, path_1.join)(__dirname, '../../../'),
    extensionDir: (0, path_1.join)(__dirname, '../../'),
    defaults: './src/defaults.json',
    package: './package.json'
};
exports.FILES = {
    persistentSettings: 'eq-material-theme-icons.json',
};
//# sourceMappingURL=constants.js.map