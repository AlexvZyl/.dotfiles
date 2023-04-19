import * as execa from 'execa';

import {PATHS} from './helpers/paths';

export default (): execa.ExecaChildProcess =>
  execa(`json-minify ${PATHS.tmpPathIcons} > ${PATHS.pathIcons} && rimraf ${PATHS.tmpPathIcons}`, { shell: true });
