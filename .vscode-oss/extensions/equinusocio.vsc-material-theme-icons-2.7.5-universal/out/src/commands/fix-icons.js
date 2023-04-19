"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const vscode_1 = require("../lib/vscode");
const material_theme_1 = require("../lib/material-theme");
const fs_1 = require("../lib/fs");
const icons_1 = require("../lib/icons");
const getIconDefinition = (definitions, iconName) => definitions[iconName];
const replaceIconPathWithAccent = (iconPath, accentName) => iconPath.replace('.svg', `.accent.${accentName}.svg`);
const isAccent = (accentName, accents) => Boolean(Object.keys(accents).find(name => name === accentName));
const newIconPath = (accent, accents, outIcon) => isAccent(accent, accents) ?
    replaceIconPathWithAccent(outIcon.iconPath, accent.replace(/\s+/, '-')) :
    outIcon.iconPath;
/**
 * Fix icons only when the Material Theme is installed and enabled
 */
exports.default = () => __awaiter(void 0, void 0, void 0, function* () {
    const deferred = {};
    const promise = new Promise((resolve, reject) => {
        deferred.resolve = resolve;
        deferred.reject = reject;
    });
    // Current theme id set on VSCode (id of the package.json of the extension theme)
    const themeLabel = (0, vscode_1.getCurrentThemeID)();
    // If this method was called without Material Theme set, just return
    if (!(0, material_theme_1.isMaterialTheme)(themeLabel)) {
        return deferred.resolve();
    }
    const DEFAULTS = (0, fs_1.getDefaultsJson)();
    const PKG = (0, fs_1.getPackageJson)();
    const MT_SETTINGS = (0, vscode_1.getMaterialThemeSettings)();
    const materialIconVariantID = (0, material_theme_1.getThemeIconVariant)(DEFAULTS, themeLabel);
    const currentThemeIconsID = (0, vscode_1.getCurrentIconsID)();
    const newThemeIconsID = materialIconVariantID ?
        `eq-material-theme-icons-${materialIconVariantID}` : 'eq-material-theme-icons';
    // Just set the correct Material Theme icons variant if wasn't
    // Or also change the current icons set to the Material Theme icons variant
    // (this is intended: this command was called directly or `autoFix` flag was already checked by other code)
    if (currentThemeIconsID !== newThemeIconsID) {
        yield (0, vscode_1.setIconsID)(newThemeIconsID);
    }
    // package.json iconThemes object for the current icons set
    const themeIconsPath = (0, icons_1.getIconsPath)(PKG, newThemeIconsID);
    // Actual json file of the icons theme (eg. Material-Theme-Icons-Darker.json)
    const theme = (0, fs_1.getIconsVariantJson)(themeIconsPath);
    for (const iconName of DEFAULTS.accentableIcons) {
        const distIcon = getIconDefinition(theme.iconDefinitions, iconName);
        const outIcon = getIconDefinition(DEFAULTS.icons.theme.iconDefinitions, iconName);
        if (typeof distIcon === 'object' && typeof outIcon === 'object') {
            distIcon.iconPath = newIconPath(MT_SETTINGS.accent, DEFAULTS.accents, outIcon);
        }
    }
    // Path of the icons theme .json
    const themePath = (0, fs_1.getAbsolutePath)(themeIconsPath);
    // Write changes to current JSON icon
    fs.writeFile(themePath, JSON.stringify(theme), { encoding: 'utf-8' }, (err) => __awaiter(void 0, void 0, void 0, function* () {
        if (err) {
            deferred.reject(err);
            return;
        }
        deferred.resolve();
    }));
    try {
        yield promise;
        yield (0, vscode_1.reloadWindow)();
    }
    catch (error) {
        console.trace(error);
    }
});
//# sourceMappingURL=fix-icons.js.map