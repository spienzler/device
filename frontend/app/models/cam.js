import DS from 'ember-data';
import { attr } from '@ember-data/model';
const { Model } = DS;

export default Model.extend({
  label: attr('string'),
  description: attr('string'),
  latestShotDay: attr('string')
});
