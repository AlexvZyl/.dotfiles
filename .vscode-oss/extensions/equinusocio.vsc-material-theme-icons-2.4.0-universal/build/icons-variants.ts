import * as path from 'path';
import * as fs from 'fs';
import {PATHS} from './helpers/paths';
import {getDefaultsJson} from '../src/lib/fs';
import {IPackageJSON} from '../typings/interfaces/packagejson';
import {IDefaults} from '../typings/interfaces/defaults';
import {IThemeIconsVariants, IThemeIconsItem} from '../typings/interfaces/icons';

const writeIconVariant = (filepath: string, destpath: string, colour: string): void => {
  const regexp = new RegExp('(#4a616c)', 'i');
  const finalFilePath = path.join(process.cwd(), PATHS.icons, filepath);
  const finalDestpath = path.join(process.cwd(), PATHS.icons, destpath);

  fs.writeFileSync(
    finalDestpath,
    fs.readFileSync(finalFilePath, 'utf-8')
      .replace(regexp, ($0, $1) => $0.replace($1, colour)),
    {encoding: 'utf-8'}
  );
};

export default (): Promise<void> => {
  const {themeVariantsColours, variantsIcons}: IDefaults = getDefaultsJson();
  const PACKAGE_JSON: IPackageJSON = require(path.resolve('./package.json'));

  // For each Material Theme variant colours
  for (const variantName of Object.keys(themeVariantsColours)) {
    for (const contribute of PACKAGE_JSON.contributes.iconThemes) {
      const regexpCheck: RegExp = new RegExp(Object.keys(themeVariantsColours).join('|'), 'i');
      if (regexpCheck.test(contribute.path) || regexpCheck.test(contribute.id)) {
        continue;
      }

      const basepath: string = path.join(process.cwd(), contribute.path);
      const basetheme: IThemeIconsVariants = require(basepath);
      const theme: IThemeIconsVariants = JSON.parse(JSON.stringify(basetheme));
      const variant = themeVariantsColours[variantName];

      for (const iconName of variantsIcons) {
        const basethemeIcon: IThemeIconsItem = (basetheme.iconDefinitions as any)[iconName];
        const themeIcon: IThemeIconsItem = (theme.iconDefinitions as any)[iconName];

        if (themeIcon !== undefined) {
          themeIcon.iconPath = themeIcon.iconPath.replace('.svg', `${ variantName }.svg`);
        }

        if (basethemeIcon !== undefined && themeIcon !== undefined) {
          writeIconVariant(basethemeIcon.iconPath, themeIcon.iconPath, variant);
        }
      }
    }
  }

  return Promise.resolve();
};
