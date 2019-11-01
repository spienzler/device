import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend({
  buildURL: function() {
    return this._super(...arguments) + '.json';
  },

  namespace: 'data'
});
