const assert=require('node:assert/strict');
const {KarutaMatch}=require('../../lib/emi_karuta/match.js');
let m=new KarutaMatch([1,2,3,35]);
assert.equal(m.pick('you',1,1).kind,'correct');
assert.equal(m.pick('you',1,2).kind,'ignored');
assert.equal(m.pick('you',3,2).transferred,1);
assert.deepEqual(m.hands,{you:[],cpu:[1]});
m.pick('cpu',2,2);assert.equal(m.pick('you',3,3).kind,'finished');
assert.deepEqual(m.hands,{you:[3,35],cpu:[1,2]});assert.equal(m.winner,'you');
m=new KarutaMatch([1,2,3,35]);m.pick('you',1,1);m.pick('cpu',2,2);m.pick('you',35,3);
assert.equal(m.remaining.length,0);assert.deepEqual(m.hands,{you:[],cpu:[2,1,3,35]});
m=new KarutaMatch([1,2]);assert.equal(m.pick('cpu',2,1).kind,'finished');assert.deepEqual(m.hands.you,[1,2]);
m=new KarutaMatch([1,2,3],false);m.pick('you',2,1);assert.equal(m.remaining.length,3);m.pick('you',1,1);m.pick('you',2,2);assert.equal(m.remaining.length,1);
m=new KarutaMatch([35,1,2,3,4,5]);m.pick('you',35,35);m.pick('you',1,1);m.pick('you',3,2);assert.deepEqual(m.hands.you,[35]);
assert.equal(new KarutaMatch([]).winner,'draw');
for(let k=0;k<100;k++){m=new KarutaMatch(Array.from({length:46},(_,i)=>i+1));while(m.remaining.length){const actor=Math.random()<.5?'you':'cpu',target=m.remaining[0],id=Math.random()<.1?m.remaining[1]:target;m.pick(actor,id??target,target);const all=[...m.remaining,...m.hands.you,...m.hands.cpu];assert.equal(all.length,46);assert.equal(new Set(all).size,46);}}
console.log('PASS: transfers, no duplicate capture, final pair, final mis-touch, ma tie-break, no-hand penalties, solo, 100 full matches / conservation');
