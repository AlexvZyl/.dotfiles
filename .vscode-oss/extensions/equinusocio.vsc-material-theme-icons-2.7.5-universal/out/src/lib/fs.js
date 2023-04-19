"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAbsolutePath = exports.getIconsVariantJson = exports.getPackageJson = exports.getDefaultsJson = void 0;
const path_1 = require("path");
const constants_1 = require("./constants");
const getDefaultsJson = () => {
    const defaults = require((0, path_1.join)(constants_1.PATHS.extensionDir, constants_1.PATHS.defaults));
    if (defaults === undefined || defaults === null) {
        throw new Error('Cannot find defaults params');
    }
    return defaults;
};
exports.getDefaultsJson = getDefaultsJson;
const getPackageJson = () => require((0, path_1.join)(constants_1.PATHS.rootDir, constants_1.PATHS.package));
exports.getPackageJson = getPackageJson;
const getIconsVariantJson = (path) => require((0, path_1.join)(constants_1.PATHS.rootDir, path));
exports.getIconsVariantJson = getIconsVariantJson;
const getAbsolutePath = (input) => (0, path_1.join)(constants_1.PATHS.rootDir, input);
exports.getAbsolutePath = getAbsolutePath;
//# sourceMappingURL=fs.js.map