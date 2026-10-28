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
  vm.runInContext(`let match=new KarutaMatch(${JSON.stringify(ids)},true),remaining=[...match.remaining],active=true,phase='playing',locked=false,target=${ids[0]},nextTimer,cpuTimer,roundLevel='hard';
    let finished=false;function render(){remaining=[...match.remaining];}function clearActions(){clearCaptureFeedback();clearTimeout(nextTimer);clearTimeout(cpuTimer);}function finish(){clearActions();finished=true;active=false;render();}function question(){}function countdown(){}`,context);
  vm.runInContext(source.slice(source.indexOf('function pick('),source.indexOf('function pause(')),context);
  vm.runInContext(source.slice(source.indexOf('function scheduleCPU('),source.indexOf('function countdown(')),context);
  vm.runInContext('Math.random=()=>.5',context);
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

function fire(game,delay){
 const entry=[...game.timers.entries()].find(([,t])=>t.ms===delay);
 assert(entry,`timer ${delay} exists`);game.timers.delete(entry[0]);entry[1].fn();
}
for(const ids of [[1,2,3,4],[1,2]]){
 game=setup(ids);game.run('scheduleCPU()');fire(game,2300);
 assert.equal(game.run('match.hands.cpu.length'),0,'CPU has not claimed the card during the 150ms tie window');
 game.run('pick(1)');
 assert.equal(game.run('match.hands.you.length'),ids.length===2?2:1,'human wins the close call, including the last pair');
 assert.equal(game.run('match.hands.cpu.length'),0);
 assert(![...game.timers.values()].some(t=>t.ms===150),'human capture cancels pending CPU capture');
 assert([...game.cards.values()].every(c=>c.children.length===0),'no misleading CPU hand or sound on a human win');
}
game=setup([1,2,3,4]);game.run('scheduleCPU()');fire(game,2300);fire(game,150);game.run('pick(1)');
assert.equal(game.run('match.hands.cpu.length'),1,'CPU wins when the human is outside the tie window');
assert.equal(game.run('match.hands.you.length'),0);
game=setup([1,2,3,4]);game.run('scheduleCPU()');fire(game,2300);game.run("clearActions();phase='paused'");
assert.equal(game.timers.size,0,'pause cancels the pending capture');
game=setup([1,2,3,4]);game.run('scheduleCPU()');fire(game,2300);game.run('pick(2)');fire(game,150);
assert.equal(game.run('match.hands.cpu.length'),1,'a wrong human card does not steal the CPU capture');
console.log('PASS: human-first close calls, final pair, late clicks, pause and mis-touch arbitration');
