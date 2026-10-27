'use strict';
const $=id=>document.getElementById(id), ids=Array.from({length:46},(_,i)=>i+1);
let readings=Object.fromEntries(ids.map(id=>[id,TOPICS[id][3]])),deck=[],remaining=[],target=null,active=false,locked=false,mistakes=0,startTime=0,timer=null,nextTimer=null,cpuTimer=null,roundMode='topic',match=null,phase='idle',previousPhase='',pausedAt=0,preparationStart=0,roundLevel='normal';
try{const saved=localStorage.getItem('emi-karuta-readings');if(saved!==null)readings=validate(JSON.parse(saved));}catch{}
for(const id of ids){if(readings[id]===TOPICS[id][5])readings[id]=TOPICS[id][3];}
const correctedSpaceDragonPrevious={"5": "すみきった そらにむかって りゅうのまい", "24": "うちゅうまで ゆめをとどけた わかたこういち"};
for(const [id,previous] of Object.entries(correctedSpaceDragonPrevious)){if(readings[id]===previous)readings[id]=TOPICS[id][3];}
const correctedPairPrevious={"31": "やぶさめで やをいるこらの むしゃすがた", "41": "いざしゅつじん たいへいめざし なおざねこう"};
for(const [id,previous] of Object.entries(correctedPairPrevious)){if(readings[id]===previous)readings[id]=TOPICS[id][3];}
function validate(data){if(!data||typeof data!=='object'||Array.isArray(data))throw Error('ばんごうと ぶんしょうを くみにした ふぁいるをえらんでください。');const result={};for(const[key,value]of Object.entries(data)){if(!ids.includes(Number(key))||typeof value!=='string'||value.length>500)throw Error('ばんごうは1〜46、よみふだは500もじいないにしてください。');if(value.trim())result[Number(key)]=value.trim();}return result;}
function shuffle(list){const result=[...list];for(let i=result.length-1;i>0;i--){const j=Math.floor(Math.random()*(i+1));[result[i],result[j]]=[result[j],result[i]];}return result;}
function element(tag,text,className){const n=document.createElement(tag);if(text)n.textContent=text;if(className)n.className=className;return n;}
function cardImage(id){const img=new Image();img.src=typeof CARD_IMAGES!=='undefined'?CARD_IMAGES[id]:`assets/${id}.webp`;img.alt=`えふだ ${id}`;img.draggable=false;return img;}
function availability(){$('availability').textContent='さいたま きょうどかるたの よみふだ 46まい。ぜんぶ ひらがなで よめるよ。';}
function drawCards(){const board=$('cards');board.replaceChildren();const versus=!!match?.versus;document.body.classList.toggle('match-screen',versus);$('leave-match').hidden=!versus;let fields=[];if(versus){for(const name of ['あいての ば','あなたの ば']){const field=element('div',null,'tatami-side');field.setAttribute('aria-label',name);board.append(field);fields.push(field);}}deck.forEach((id,index)=>{const b=element('button',null,'card');b.dataset.id=id;b.setAttribute('aria-label',`えふだ ${id}をとる`);b.append(cardImage(id));b.disabled=!active;b.onclick=()=>pick(id);if(versus){const side=index<Math.ceil(deck.length/2)?0:1;fields[side].append(b);}else board.append(b);});render();}

function render(){if(!match)return;remaining=[...match.remaining];mistakes=match.mistakes.you;$('score').textContent=String(deck.length-remaining.length);$('you-points').textContent=match.hands.you.length;$('cpu-points').textContent=match.hands.cpu.length;document.querySelectorAll('#cards button').forEach(b=>{const id=Number(b.dataset.id),owner=match.hands.you.includes(id)?'you':match.hands.cpu.includes(id)?'cpu':null;b.classList.toggle('taken',!!owner);b.classList.toggle('you',owner==='you');b.classList.toggle('cpu',owner==='cpu');b.disabled=!!owner||!active||phase!=='playing'||locked;b.setAttribute('aria-label',owner?`えふだ ${id} ${owner==='you'?'あなた':'あいて'}がとったよ`:`えふだ ${id}をとる`);});}
function clearActions(){clearTimeout(nextTimer);clearTimeout(cpuTimer);cancelVoice();}
function stop(){active=false;clearInterval(timer);clearActions();phase='idle';$('pause').hidden=true;$('advance').hidden=true;}
function preview(){stop();match=null;deck=shuffle(ids).slice(0,Number($('count').value));drawCards();$('score').textContent='0';$('total').textContent=` / ${deck.length} まい`;$('versus-score').hidden=true;}
let voiceGeneration=0,voiceWatchdog=null,voiceQueue=[];
function voiceStatus(message){$('voice-status').textContent=message;}
function cancelVoice(){voiceGeneration++;clearTimeout(voiceWatchdog);voiceQueue=[];const player=$('voice-player');player.onended=null;player.onplaying=null;player.onerror=null;player.pause();window.speechSynthesis?.cancel();}
function speakText(text,repeat=1){
 cancelVoice();
 if(typeof READING_AUDIO!=='undefined' && READING_AUDIO[text]){
  const player=$('voice-player'),generation=voiceGeneration;let remainingPlays=repeat;
  player.src=READING_AUDIO[text];player.volume=1;player.muted=false;player.dataset.state='loading';
  voiceStatus('こえを じゅんびしています');
  const failed=()=>{if(generation!==voiceGeneration)return;player.dataset.state='blocked';voiceStatus('おとの ▶ を おしてね。');};
  const play=()=>{if(generation!==voiceGeneration)return;player.currentTime=0;player.play().catch(failed);};
  player.onplaying=()=>{if(generation!==voiceGeneration)return;player.dataset.state='playing';voiceStatus('よみあげちゅう');};
  player.onerror=failed;
  player.onended=()=>{if(generation!==voiceGeneration)return;if(--remainingPlays>0){play();}else{player.dataset.state='ended';voiceStatus('もういちど きくときは ▶ を おしてね。');}};
  play();return;
 }
 const synth=window.speechSynthesis;
 if(!synth||typeof SpeechSynthesisUtterance==='undefined'){voiceStatus('このぶらうざでは こえが つかえません。さふぁりか くろーむで ひらいてね。');return;}
 const generation=voiceGeneration;
 const voice=synth.getVoices().find(v=>/^ja(?:-|_)/i.test(v.lang));
 synth.resume();
 voiceStatus('こえを じゅんびしています');
 for(let i=0;i<repeat;i++){
  const u=new SpeechSynthesisUtterance(text);u.lang='ja-JP';u.rate=.85;u.volume=1;u.pitch=1;if(voice)u.voice=voice;
  u.onstart=()=>{if(generation!==voiceGeneration)return;clearTimeout(voiceWatchdog);voiceStatus('よみあげちゅう');};
  u.onend=()=>{if(generation!==voiceGeneration)return;voiceQueue=voiceQueue.filter(item=>item!==u);if(!voiceQueue.length){clearTimeout(voiceWatchdog);voiceStatus('こえが きこえないときは、おんりょうと しゅつりょくさきを たしかめてね。');}};
  u.onerror=e=>{if(generation!==voiceGeneration||['canceled','interrupted'].includes(e.error))return;clearTimeout(voiceWatchdog);voiceStatus('こえを だせませんでした。「こえを ためす」を おしてね。');};
  voiceQueue.push(u);
 }
 for(const u of voiceQueue)synth.speak(u);
 voiceWatchdog=setTimeout(()=>{if(generation!==voiceGeneration)return;voiceStatus('こえが はじまりません。「こえを ためす」を おしてね。きこえなければ さふぁりか くろーむで ひらいてね。');},5000);
}

function speak(){if(!active||phase!=='playing'||roundMode==='picture'||!target)return;speakText(roundMode==='topic'?TOPICS[target][2]:readings[target],match.versus?2:1);}
function promptText(title,detail){$('prompt').replaceChildren(element('span','✳','prompt-icon'));const text=element('div');text.append(element('b',title),element('p',detail));$('prompt').append(text);}
function question(){if(!active)return;clearActions();phase='playing';target=remaining[Math.floor(Math.random()*remaining.length)];locked=false;const prompt=$('prompt');prompt.replaceChildren();const text=element('div');if(roundMode==='picture'){prompt.append(cardImage(target));text.append(element('b','このえと、おなじふだはどれ？'),element('p','さきにふだをおしてね。'));}else{prompt.append(element('span','♪','prompt-icon'));text.append(element('p',roundMode==='topic'?TOPICS[target][4]:'じぶんの よみふだ'),element('b',roundMode==='topic'?TOPICS[target][3]:readings[target]));const replay=element('button','もういちどきく ↻','text-button');replay.onclick=speak;text.append(replay);}prompt.append(text);render();speak();scheduleCPU();}
function scheduleCPU(){clearTimeout(cpuTimer);if(!active||phase!=='playing'||!match.versus||locked)return;const ranges={easy:[6500,9500,.15],normal:[3500,5500,.07],hard:[1700,2900,.02]},[min,max,error]=ranges[roundLevel];const delay=(min+Math.random()*(max-min))*(1+Math.max(0,remaining.length-12)/40);cpuTimer=setTimeout(()=>{if(!active||phase!=='playing'||locked)return;const wrong=remaining.filter(n=>n!==target);const id=Math.random()<error&&wrong.length?wrong[Math.floor(Math.random()*wrong.length)]:target;pick(id,'cpu');if(phase==='playing'&&!locked)scheduleCPU();},delay);}
function countdown(finalPair=false){clearActions();phase='countdown';locked=true;$('advance').hidden=true;promptText(finalPair?'さいごの 2まい。つぎの1まいでしょうぶ！':'もうすぐ はじまるよ','おしらせの あいだはふだをとれません。');$('feedback').textContent=finalPair?'あたりなら2まいもらえる。おてつきならあいてに2まいともちふだ1まい。':'おたがいに おじぎをして、はじめましょう。';speakText(finalPair?'さいごの ふたつの ふだです。つぎのふだからとります。':'これからはじめます。つぎのふだからとります。',2);render();nextTimer=setTimeout(()=>{if(!active)return;if(!startTime)startTime=Date.now();question();},4000);}
function clockText(){const sec=startTime?Math.floor(((phase==='paused'?pausedAt:Date.now())-startTime)/1000):0;return `${String(Math.floor(sec/60)).padStart(2,'0')}:${String(sec%60).padStart(2,'0')}`;}
function start(){const mode=$('mode').value,pool=mode==='reading'?ids.filter(id=>readings[id]):ids;if(pool.length<2){$('feedback').textContent='よみふだを2まいいじょうとうろくしてください。';openEditor();return;}stop();roundMode=mode;roundLevel=$('level').value;const versus=$('opponent').value==='cpu';deck=shuffle(pool).slice(0,versus?46:Number($('count').value));if(versus&&pool.includes(35)&&!deck.includes(35))deck[deck.length-1]=35;deck=shuffle(deck);match=new KarutaMatch(deck,versus);remaining=[...deck];active=true;locked=true;startTime=0;target=null;$('score').textContent='0';$('total').textContent=` / ${deck.length} まい`;$('versus-score').hidden=!versus;$('timer').textContent='00:00';$('board-label').textContent=versus?'あいてと、ふだとりしょうぶ。':'じっくり、ひとりで れんしゅう。';$('board-title').textContent=versus?'どちらがおおく、とれるかな。':'さあ、ふだをとろう。';$('start').textContent='あたらしくあそぶ →';$('restart').hidden=false;$('pause').hidden=false;$('pause').textContent='ひとやすみ';phase=versus?'preparing':'playing';drawCards();if(versus){preparationStart=Date.now();promptText('ふだのばしょをおぼえよう','5ふんいないに「じゅんびできた」をおしてください。');$('feedback').textContent='「ま」（まがたま）はおなじ てんすうのときのきめて。';$('advance').hidden=false;nextTimer=setTimeout(()=>countdown(remaining.length===2),300000);}else{locked=false;startTime=Date.now();question();}timer=setInterval(()=>{$('timer').textContent=phase==='preparing'?`じゅんび ${Math.max(0,300-Math.floor((Date.now()-preparationStart)/1000))}びょう`:clockText();},1000);}
function finish(){const elapsed=clockText();stop();phase='finished';render();$('timer').textContent=elapsed;const who=match.winner;const title=match.versus?(who==='you'?'あなたのかち！':who==='cpu'?'あいての かち。またちょうせんしよう！':'ひきわけ！'):'ぜんぶ、とれました。';$('board-title').textContent=title;const tie=match.hands.you.length===match.hands.cpu.length&&who!=='draw';promptText(title,match.versus?`あなた ${match.hands.you.length}まい / あいて ${match.hands.cpu.length}まい${tie?' · 「ま」のふだでしょうぶ':''}`:`${deck.length}まい、みつけたね。`);$('feedback').textContent+=` かかった じかん ${elapsed}・おてつき あなた${match.mistakes.you}かい / あいて${match.mistakes.cpu}かい`;$('pause').hidden=true;}
function pick(id,actor='you'){if(!active||phase!=='playing'||locked||!remaining.includes(id))return;const result=match.pick(actor,id,target);if(result.kind==='ignored')return;const name=actor==='you'?'あなた':'あいて';if(result.kind==='wrong'||result.wrong){const b=document.querySelector(`#cards button[data-id="${id}"]`);b?.classList.add('wrong');$('feedback').textContent=`${name}のおてつき。${result.transferred!==null?'もちふだ1まいをあいてへ。':'もちふだがないためいどうなし。'}${result.wrong?'さいごの 2まいはあいてがもらえる。':''}`;render();if(result.kind==='finished')finish();return;}locked=true;clearActions();$('feedback').textContent=actor==='you'?'はいっ！ あなたがとりました。':'あいてがとりました。つぎのふだにちょうせん！';render();if(result.kind==='finished'){finish();return;}phase='between';nextTimer=setTimeout(()=>remaining.length===2&&match.versus?countdown(true):question(),1100);}
function pause(){if(!active)return;if(phase==='paused'){const delta=Date.now()-pausedAt;if(startTime)startTime+=delta;preparationStart+=delta;phase=previousPhase;$('pause').textContent='ひとやすみ';if(phase==='preparing'){promptText('ふだのばしょをおぼえよう','じゅんびができたら、はじめましょう。');$('advance').hidden=false;nextTimer=setTimeout(()=>countdown(remaining.length===2),Math.max(0,300000-(Date.now()-preparationStart)));}else if(phase==='countdown'||phase==='between'){countdown(remaining.length===2);}else{phase='playing';locked=false;render();speak();scheduleCPU();}return;}previousPhase=phase;pausedAt=Date.now();clearActions();phase='paused';$('pause').textContent='つづける';$('advance').hidden=true;$('feedback').textContent='ひとやすみちゅう。「つづける」でさいかいします。';render();}
$('advance').onclick=()=>countdown(remaining.length===2);$('pause').onclick=pause;
document.addEventListener('visibilitychange',()=>{if(document.hidden&&active&&phase!=='paused')pause();});
function openEditor(){if(active)stop();$('reading-list').replaceChildren();ids.forEach(id=>{const row=element('div',null,'reading-row');row.append(cardImage(id));const label=element('label',`${TOPICS[id][0]} · ${TOPICS[id][1]}（${id}） · ${TOPICS[id][4]}`);const input=element('textarea');input.dataset.id=id;input.value=readings[id]||'';input.placeholder='このえのよみふだ';input.maxLength=500;label.append(input);row.append(label);$('reading-list').append(row);});$('editor-status').textContent='';$('editor').showModal();}
$('start').onclick=start;$('restart').onclick=start;$('edit').onclick=openEditor;$('close').onclick=()=>$('editor').close();
$('editor').addEventListener('close',()=>{if(remaining.length&&startTime){$('feedback').textContent='あそびをおやすみしました。「あたらしくあそぶ」ではじめてください。';document.querySelectorAll('.card').forEach(b=>b.disabled=true);}});
$('count').onchange=()=>{if(!active)preview();};
$('save').onclick=()=>{const next={};document.querySelectorAll('#reading-list textarea').forEach(t=>{if(t.value.trim())next[t.dataset.id]=t.value.trim();});readings=next;try{localStorage.setItem('emi-karuta-readings',JSON.stringify(readings));$('editor').close();availability();}catch{$('editor-status').textContent='ぶらうざへのほぞんができませんでした。ふぁいるに ほぞんしてください。このがめんをひらいている あいだはあそべます。';availability();}};
$('export').onclick=()=>{const data={};document.querySelectorAll('#reading-list textarea').forEach(t=>{if(t.value.trim())data[t.dataset.id]=t.value.trim();});const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download='emi-karuta-readings.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);};
$('import').onchange=async e=>{try{const file=e.target.files[0];if(!file)return;if(file.size>100000)throw Error('ふぁいるが おおきすぎるよ。ちいさな ふぁいるを えらんでね。');const data=validate(JSON.parse(await file.text()));document.querySelectorAll('#reading-list textarea').forEach(t=>t.value=data[t.dataset.id]||'');$('editor-status').textContent='よみこみました。「ほぞんする」を おしてください。';}catch(error){$('editor-status').textContent='よみこめなかったよ。よみふだの ふぁいるか たしかめてね。';}finally{e.target.value='';}};
window.addEventListener('pagehide',stop);availability();preview();

$('leave-match').onclick=()=>{stop();preview();$('restart').hidden=true;promptText('どのえが、すき？','あそびかたを えらんでね。');};

$('test-voice').onclick=()=>{
 if(active&&phase!=='paused')pause();
 speakText('えみのかるたです。こえが きこえますか。');
};
