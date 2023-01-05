"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIconsPath = void 0;
const getIconsPath = (pkg, iconsId) => {
    const found = pkg.contributes.iconThemes.find(iconObj => iconObj.id === iconsId);
    return found ? found.path : '';
};
exports.getIconsPath = getIconsPath;
//# sourceMappingURL=icons.js.map