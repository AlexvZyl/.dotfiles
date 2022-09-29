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
exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const fix_icons_1 = require("./commands/fix-icons");
const persistent_settings_1 = require("./lib/persistent-settings");
const messages_1 = require("./lib/messages");
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        const settings = new persistent_settings_1.default(vscode, context.globalStoragePath);
        // const materialThemeInstalled = await isMaterialTheme(await getCurrentThemeID());
        // if (settings.isFirstInstall() && !materialThemeInstalled && await installationMessage()) {
        //     await openMaterialThemeExt();
        // }
        // TODO implement show changelog
        // if (settings.isNewVersion() && await changelogMessage()) {
        //
        // }
        if (settings.isNewVersion()) {
            (0, messages_1.changelogMessage)(settings.getSettings().extensionSettings.version);
        }
        settings.updateStatus();
        const fixIconsCommand = vscode.commands.registerCommand('eqMaterialThemeIcons.fixIcons', fix_icons_1.default);
        context.subscriptions.push(fixIconsCommand);
    });
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() {
    // TODO
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map