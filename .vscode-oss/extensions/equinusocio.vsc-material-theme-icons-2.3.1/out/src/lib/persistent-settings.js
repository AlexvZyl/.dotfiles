"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path_1 = require("path");
const fs_1 = require("fs");
const semver_1 = require("semver");
const os = require("os");
const path = require("path");
const constants_1 = require("./constants");
const fs_2 = require("./fs");
class PersistentSettings {
    constructor(vscode, globalStoragePath) {
        this.vscode = vscode;
        this.globalStoragePath = globalStoragePath;
        this.settings = this.getSettings();
        this.defaultState = {
            version: '0.0.0'
        };
    }
    getSettings() {
        const appName = this.vscode.env.appName || '';
        const isDev = /dev/i.test(appName);
        const isOSS = isDev && /oss/i.test(appName);
        const isInsiders = /insiders/i.test(appName);
        const vscodeVersion = new semver_1.SemVer(this.vscode.version).version;
        const isWin = /^win/.test(process.platform);
        const { version } = (0, fs_2.getPackageJson)();
        const extensionSettings = {
            version
        };
        const persistentSettingsFilePath = path.join(this.globalStoragePath, 'settings.json');
        this.settings = {
            isDev,
            isOSS,
            isInsiders,
            isWin,
            vscodeVersion,
            persistentSettingsFilePath,
            extensionSettings
        };
        if (!(0, fs_1.existsSync)(this.globalStoragePath)) {
            (0, fs_1.mkdirSync)(this.globalStoragePath);
        }
        this.migrateOldPersistentSettings(isInsiders, isOSS, isDev);
        return this.settings;
    }
    getOldPersistentSettingsPath(isInsiders, isOSS, isDev) {
        const vscodePath = this.vscodePath();
        const vscodeAppName = this.vscodeAppName(isInsiders, isOSS, isDev);
        const vscodeAppUserPath = (0, path_1.join)(vscodePath, vscodeAppName, 'User');
        return (0, path_1.join)(vscodeAppUserPath, constants_1.FILES.persistentSettings);
    }
    migrateOldPersistentSettings(isInsiders, isOSS, isDev) {
        const oldPersistentSettingsFilePath = this.getOldPersistentSettingsPath(isInsiders, isOSS, isDev);
        if ((0, fs_1.existsSync)(oldPersistentSettingsFilePath)) {
            let oldState = require(oldPersistentSettingsFilePath);
            this.setState(oldState);
            (0, fs_1.unlinkSync)(oldPersistentSettingsFilePath);
        }
    }
    getState() {
        if (!(0, fs_1.existsSync)(this.settings.persistentSettingsFilePath)) {
            return this.defaultState;
        }
        try {
            return require(this.settings.persistentSettingsFilePath);
        }
        catch (error) {
            // TODO: errorhandler
            // ErrorHandler.logError(error, true);
            console.log(error);
            return this.defaultState;
        }
    }
    setState(state) {
        try {
            (0, fs_1.writeFileSync)(this.settings.persistentSettingsFilePath, JSON.stringify(state));
        }
        catch (error) {
            // TODO: errorhandler
            // ErrorHandler.logError(error, true);
            console.log(error);
        }
    }
    deleteState() {
        (0, fs_1.unlinkSync)(this.settings.persistentSettingsFilePath);
    }
    updateStatus() {
        const state = this.getState();
        state.version = this.settings.extensionSettings.version;
        this.setState(state);
        return state;
    }
    isNewVersion() {
        const currentVersionInstalled = this.getState().version;
        // If is firstInstall
        return currentVersionInstalled === this.defaultState.version ? false : (0, semver_1.lt)(currentVersionInstalled, this.settings.extensionSettings.version);
    }
    isFirstInstall() {
        return this.getState().version === this.defaultState.version;
    }
    vscodeAppName(isInsiders, isOSS, isDev) {
        return process.env.VSCODE_PORTABLE
            ? 'user-data'
            : isInsiders
                ? 'Code - Insiders'
                : isOSS
                    ? 'Code - OSS'
                    : isDev
                        ? 'code-oss-dev'
                        : 'Code';
    }
    vscodePath() {
        switch (process.platform) {
            case 'darwin':
                return `${os.homedir()}/Library/Application Support`;
            case 'linux':
                return `${os.homedir()}/.config`;
            case 'win32':
                return process.env.APPDATA;
            default:
                return '/var/local';
        }
    }
}
exports.default = PersistentSettings;
//# sourceMappingURL=persistent-settings.js.map