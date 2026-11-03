'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const source = fs.readFileSync(path.join(__dirname, '../../lib/emi_karuta/app.js'), 'utf8');
const initialization = source.slice(0, source.indexOf('function shuffle'));
const topics = Object.fromEntries(Array.from({length: 46}, (_, i) => [i + 1, ['', '', '', `Default ${i + 1}`, '', `Old ${i + 1}`]]));
function load(saved) {
  const context = vm.createContext({TOPICS: topics, localStorage: {getItem: () => saved}});
  vm.runInContext(initialization, context);
  return JSON.parse(vm.runInContext('JSON.stringify(readings)', context));
}
assert.equal(Object.keys(load(null)).length, 46, 'first visit has defaults');
assert.deepEqual(load('{}'), {}, 'saved empty set stays empty');
assert.deepEqual(load('{"1":"Custom","2":"  "}'), {'1': 'Custom'}, 'partial set does not restore removed readings');
assert.equal(Object.keys(load('invalid json')).length, 46, 'corrupt data falls back to defaults');
assert.equal(Object.keys(load('[]')).length, 46, 'invalid structure falls back to defaults');
assert.deepEqual(load('{"1":"Old 1"}'), {'1': 'Default 1'}, 'legacy correction preserves partial set');
console.log('PASS: missing, empty, partial, invalid, and legacy saved readings');
