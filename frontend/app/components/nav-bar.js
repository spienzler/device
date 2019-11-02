import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  store: service(),

  cams: [],

  init() {
    this._super(...arguments);

    this._getCams();
  },

  _getCams() {
    return this.get('store').findAll('cam').then((cams) => {
      this.set('cams', cams);
    });
  }

});
