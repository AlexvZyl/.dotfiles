import {join} from 'path';

import {IDefaults} from '../../typings/interfaces/defaults';
import {PATHS} from '../../src/lib/constants';

export const getDefaultsJson = (): IDefaults => {
  const defaults: IDefaults = require(join(PATHS.rootDir, PATHS.defaults));

  if (defaults === undefined || defaults === null) {
    throw new Error('Cannot find defaults params');
  }

  return defaults;
};
