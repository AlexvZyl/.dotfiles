import * as fs from 'fs';
import * as path from 'path';
import {IThemeIconsAccents, IThemeIconsItem} from '../typings/interfaces/icons';
import {getDefaultsJson} from './helpers/fs';
import {PATHS} from './helpers/paths';

const ICON_VARIANTS_BASE_PATH: string = path.join(process.cwd(), PATHS.pathIcons);
const DEFAULTS = getDefaultsJson();

const normalizeIconPath = (iconPath: string): string =>
  path.join(process.cwd(), PATHS.icons, iconPath);

const replaceNameWithAccent = (name: string, accentName: string): string =>
  name.replace('.svg', `.accent.${ accentName }.svg`);

const replaceSVGColour = (filecontent: string, colour: string): string =>
  filecontent.replace(new RegExp('#(80CBC4)', 'i'), ($0, $1) => {
    const newColour = colour.replace('#', '');
    return $0.replace($1, newColour);
  });

const replaceWhiteSpaces = (input: string): string =>
  input.replace(/\s+/g, '-');

const writeSVGIcon = (fromFile: string, toFile: string, accent: string): void => {
  const fileContent: string = fs.readFileSync(normalizeIconPath(fromFile), 'utf-8');
  const content: string = replaceSVGColour(fileContent, DEFAULTS.accents[accent]);
  const pathToFile = normalizeIconPath(toFile);
  fs.writeFileSync(pathToFile, content);
};

export default (): Promise<void> => {
  const basetheme: IThemeIconsAccents = require(ICON_VARIANTS_BASE_PATH);

  for (const key of Object.keys(DEFAULTS.accents)) {
    const iconName = replaceWhiteSpaces(key);
    const themecopy: IThemeIconsAccents = JSON.parse(JSON.stringify(basetheme));

    for (const accentableIconName of DEFAULTS.accentableIcons) {
      const iconOriginDefinition: IThemeIconsItem = (basetheme.iconDefinitions as any)[accentableIconName];
      const iconCopyDefinition: IThemeIconsItem = (themecopy.iconDefinitions as any)[accentableIconName];

      if (iconOriginDefinition !== undefined && typeof iconOriginDefinition.iconPath === 'string' && iconCopyDefinition !== undefined && typeof iconCopyDefinition.iconPath === 'string') {
        iconCopyDefinition.iconPath = replaceNameWithAccent(iconOriginDefinition.iconPath, iconName);
        writeSVGIcon(iconOriginDefinition.iconPath, iconCopyDefinition.iconPath, key);
      } else {
        console.log(`Icon ${accentableIconName} not found`);
      }
    }
  }

  return Promise.resolve();
};
