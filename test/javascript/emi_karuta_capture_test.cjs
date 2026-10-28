'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const {KarutaMatch} = require('../../lib/emi_karuta/match.js');
const source = fs.readFileSync(path.join(__dirname, '../../lib/emi_karuta/app.js'), 'utf8');
function node() {
  const classes = new Set();
  return {children: [], classList: {add: c => classes.add(c), remove: c => classes.delete(c), contains: c => classes.has(c)},
    append(...items) {this.children.push(...items); items.forEach(n => n.parent = this);},
    setAttribute() {}, remove() {this.parent.children = this.parent.children.filter(n => n !== this);}};
}
function setup(ids) {
  const cards = new Map(ids.map(id => [id,node()])), fields = {'cpu-points':node(),feedback:node()}, timers = new Map();
  let next = 0;
  const context = vm.createContext({KarutaMatch,window:{},TOPICS:Object.fromEntries(ids.map(id=>[id,['かな']])),
    $:id=>fields[id], element:()=>node(),
    document:{querySelector:s=>cards.get(Number(s.match(/data-id="(\d+)"/)[1])), querySelectorAll:s=>s==='.cpu-capture'?[...cards.values()].filter(c=>c.classList.contains('cpu-capture')):s==='.capture-effect'?[...cards.values()].flatMap(c=>c.children):[]},
    setTimeout:(fn,ms)=>{timers.set(++next,{fn,ms});return next;},clearTimeout:id=>timers.delete(id)});
  vm.runInContext(source.slice(source.indexOf('// Capture feedback'), source.indexOf('function cardImage')),context);
  vm.runInContext(`let match=new KarutaMatch(${JSON.stringify(ids)},true),remaining=[...match.remaining],active=true,phase='playing',locked=false,target=${ids[0]},nextTimer;
    let finished=false;function render(){remaining=[...match.remaining];}function clearActions(){clearCaptureFeedback();}function finish(){clearActions();finished=true;active=false;render();}function question(){}function countdown(){}`,context);
  vm.runInContext(source.slice(source.indexOf('function pick('),source.indexOf('function pause(')),context);
  return {run:s=>vm.runInContext(s,context),cards,fields,timers};
}
let game=setup([1,2,3,4]);
game.run("pick(1,'cpu')");
assert(game.cards.get(1).classList.contains('cpu-capture'));
assert.equal(game.run('match.hands.cpu.length'),1);
assert.deepEqual([...game.timers.values()].map(t=>t.ms).sort(),[1200,1600]);
game.run("pick(1,'cpu')");assert.equal(game.run('match.hands.cpu.length'),1,'feedback cannot cause duplicate captures');
[...game.timers.values()].find(t=>t.ms===1200).fn();
assert(!game.cards.get(1).classList.contains('cpu-capture'));assert.equal(game.cards.get(1).children.length,0);
game=setup([1,2]);game.run("pick(1,'cpu')");
assert(game.run('finished'));assert([...game.cards.values()].every(c=>c.classList.contains('cpu-capture')),'last pair stays visible even after finish');
game.run('clearActions()');assert([...game.cards.values()].every(c=>c.children.length===0),'stop/pause cleanup removes effects');
game=setup([1,2]);game.run("pick(2,'you')");
assert([...game.cards.values()].every(c=>c.classList.contains('cpu-capture')),'final mis-touch shows both cards awarded to CPU');
game=setup([1,2,3]);game.run("pick(2,'cpu')");assert.equal(game.timers.size,0,'CPU mis-touch is not shown as a capture');
game=setup([1,2,3]);game.run("pick(1,'you')");assert([...game.cards.values()].every(c=>c.children.length===0),'player capture has no opponent hand');
game.run('window.AudioContext=class{constructor(){throw Error("blocked")}};unlockCaptureAudio();playCaptureSound();');
console.log('PASS: CPU capture cue, final pair, final penalty, cancellation, duplicate prevention and unavailable audio');
