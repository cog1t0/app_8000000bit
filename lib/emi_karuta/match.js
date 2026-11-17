'use strict';
// Individual-game scoring, adapted from Saitama's competition handbook.
class KarutaMatch {
  constructor(ids, versus=true) { this.remaining=[...ids];this.versus=versus;this.hands={you:[],cpu:[]};this.mistakes={you:0,cpu:0}; }
  get winner(){const a=this.hands.you,b=this.hands.cpu;if(a.length!==b.length)return a.length>b.length?'you':'cpu';return a.includes(35)?'you':b.includes(35)?'cpu':'draw';}
  pick(actor,id,target){
    if(!this.remaining.includes(id)||!this.remaining.includes(target)||!this.hands[actor])return {kind:'ignored'};
    const other=actor==='you'?'cpu':'you';let transferred=null;
    if(id!==target){
      this.mistakes[actor]++;
      if(this.versus&&this.hands[actor].length){const hand=this.hands[actor];const index=hand.findIndex(n=>n!==35);transferred=hand.splice(index<0?0:index,1)[0];this.hands[other].push(transferred);}
      if(this.versus&&this.remaining.length===2){this.hands[other].push(...this.remaining);this.remaining=[];return {kind:'finished',actor:other,wrong:true,transferred};}
      return {kind:'wrong',actor,transferred};
    }
    const captured=this.versus&&this.remaining.length===2?[...this.remaining]:[id];
    this.hands[actor].push(...captured);this.remaining=this.remaining.filter(n=>!captured.includes(n));
    return {kind:this.remaining.length?'correct':'finished',actor,captured};
  }
}
if(typeof module!=='undefined')module.exports={KarutaMatch};
