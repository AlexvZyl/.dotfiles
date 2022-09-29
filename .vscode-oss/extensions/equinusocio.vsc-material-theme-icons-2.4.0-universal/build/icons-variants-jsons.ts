import * as fs from 'fs';
import * as path from 'path';

import {IDefaults} from '../typings/interfaces/defaults';
import {getDefaultsJson} from './helpers/fs';

import {PATHS} from './helpers/paths';

export default (): Promise<void> => {
  const {themeIconVariants, variantsIcons}: IDefaults = getDefaultsJson();
  const themIconsJson = fs.readFileSync(path.resolve(PATHS.pathIcons), 'utf8');
  for (const variantName of Object.keys(themeIconVariants)) {
    const jsonDefaults = JSON.parse(themIconsJson);

    for (const iconname of variantsIcons) {
      const newIconPath = jsonDefaults.iconDefinitions[iconname].iconPath.replace('.svg', `${variantName}.svg`);
      jsonDefaults.iconDefinitions[iconname].iconPath = newIconPath;

      fs.writeFileSync(
        PATHS.pathIconKey(variantName),
        JSON.stringify(jsonDefaults),
        {encoding: 'utf-8'}
      );
    }
  }

  return Promise.resolve();
};
