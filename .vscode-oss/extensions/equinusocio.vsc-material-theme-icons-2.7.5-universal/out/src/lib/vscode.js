"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reloadWindow = exports.openMaterialThemeExt = exports.getMaterialThemeSettings = exports.setIconsID = exports.getCurrentIconsID = exports.getCurrentThemeID = void 0;
const vscode_1 = require("vscode");
const getCurrentThemeID = () => vscode_1.workspace.getConfiguration().get('workbench.colorTheme', '');
exports.getCurrentThemeID = getCurrentThemeID;
const getCurrentIconsID = () => vscode_1.workspace.getConfiguration().get('workbench.iconTheme', '');
exports.getCurrentIconsID = getCurrentIconsID;
const setIconsID = (id) => vscode_1.workspace.getConfiguration().update('workbench.iconTheme', id, true);
exports.setIconsID = setIconsID;
const getMaterialThemeSettings = () => vscode_1.workspace
    .getConfiguration()
    .get('materialTheme', { accent: '' });
exports.getMaterialThemeSettings = getMaterialThemeSettings;
const openMaterialThemeExt = () => vscode_1.commands.executeCommand('workbench.extensions.action.showExtensionsWithIds', ['equinusocio.vsc-material-theme']);
exports.openMaterialThemeExt = openMaterialThemeExt;
const reloadWindow = () => vscode_1.commands.executeCommand('workbench.action.reloadWindow');
exports.reloadWindow = reloadWindow;
//# sourceMappingURL=vscode.js.map