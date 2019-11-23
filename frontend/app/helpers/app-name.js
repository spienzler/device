import { helper } from '@ember/component/helper';
import { htmlSafe } from '@ember/template';

export function appName() {
  return htmlSafe('&#60;o&#62; Spienzler');
}

export default helper(appName);
