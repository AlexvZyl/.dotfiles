import * as fs from 'fs';
import * as path from 'path';
import * as mustache from 'mustache';

import {IIcon} from '../typings/interfaces/icons';
import {IGenericObject} from '../typings/interfaces/common';
import {PATHS} from './helpers/paths';

const ensureDir = (dirname: string): void =>
  !fs.existsSync(dirname) ?
    fs.mkdirSync(dirname) : void 0;

/**
 * Returns an object implementing the IIcon interface
 */
const iconFactory = (fileName: string): IIcon => {
  let name: string = path.basename(fileName, path.extname(fileName));
  const filename: string = name;
  const last = false;

  // renaming icon for vscode
  // if the icon filename starts with a folder prefix,
  // the resulting name will be prefixed only by an underscore,
  // otherwise the icon will be prefixed by a _file_ prefix
  name = name.indexOf('folder') ?
    name.indexOf('file') ? `_file_${ name }` : `_${ name }` :
    name = `_${ name }`;

  return {filename, name, last};
};

export default (): Promise<void> => {
  let contents: string;
  const fileNames: string[] = fs.readdirSync(path.resolve(PATHS.srcSvgs));
  const icons: IIcon[] = fileNames.map(iconFactory);
  const partials: string[] = fs.readdirSync(path.resolve(PATHS.srcPartials));
  const partialsData: IGenericObject<any> = {};

  ensureDir(path.join(PATHS.variants));
  icons[icons.length - 1].last = true;

  for (const partial of partials) {
    partialsData[path.basename(partial, path.extname(partial))] = fs.readFileSync(
      path.join(PATHS.srcPartials, `./${partial}`), 'utf-8');
  }

  contents = mustache.render(
    fs.readFileSync(path.resolve(PATHS.srcIconsTheme), 'utf-8'),
    {icons},
    partialsData
  );

  contents = JSON.stringify(JSON.parse(contents), undefined, 2);

  fs.writeFileSync(PATHS.tmpPathIcons, contents, {encoding: 'utf-8'});
  return Promise.resolve();
};
