const enc=new TextEncoder();
export const AUD='fr.leslapibreizh.carnetsante';
export const tiers=['trial','1','2','3','4','owner'];
const b64=b=>btoa(String.fromCharCode(...new Uint8Array(b))).replace(/=/g,'').replace(/\+/g,'-').replace(/\//g,'_');
const un64=s=>Uint8Array.from(atob(s.replace(/-/g,'+').replace(/_/g,'/')),c=>c.charCodeAt(0));
const now=()=>Math.floor(Date.now()/1000);
const random=n=>b64(crypto.getRandomValues(new Uint8Array(n)));
const sha=async s=>b64(await crypto.subtle.digest('SHA-256',typeof s==='string'?enc.encode(s):s));
const fail=(message,status=400)=>{throw Object.assign(new Error(message),{status});};
function json(v,status=200){return new Response(JSON.stringify(v),{status,headers:{'Content-Type':'application/json;charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}});}
async function body(req){if(Number(req.headers.get('Content-Length')||0)>16384)fail('Requête trop longue.');const t=await req.text();if(t.length>16384)fail('Requête trop longue.');try{return JSON.parse(t);}catch{fail('JSON incorrect.');}}
const statement=(env,sql,...a)=>env.DB.prepare(sql).bind(...a);
async function log(env,actor,action,id){await statement(env,'INSERT INTO audit(at,actor,action,licence_id) VALUES(?,?,?,?)',now(),actor,action,id||null).run();}
async function rate(req,env,name,max){
 if(!env.RATE_PEPPER)fail('Service non configuré.',503);
 const bucket=await sha(`${env.RATE_PEPPER}:${req.headers.get('CF-Connecting-IP')||'unknown'}:${name}:${Math.floor(now()/60)}`);
 const r=await statement(env,'INSERT INTO rate_limits(bucket,count,expires) VALUES(?,1,?) ON CONFLICT(bucket) DO UPDATE SET count=count+1 RETURNING count',bucket,now()+120).first();
 if(r.count>max)fail('Trop de tentatives. Réessaie dans une minute.',429);
}
const jwksCache=new Map();
export async function admin(req,env){
 const team=env.ACCESS_TEAM||'';
 if(!/^https:\/\/[a-z0-9-]+\.cloudflareaccess\.com$/.test(team)||!env.ACCESS_AUD||!env.ADMIN_EMAIL)fail('Authentification administrateur non configurée.',503);
 const jwt=req.headers.get('Cf-Access-Jwt-Assertion')||'';const parts=jwt.split('.');if(parts.length!==3)fail('Connexion administrateur requise.',401);
 let h,p;try{h=JSON.parse(new TextDecoder().decode(un64(parts[0])));p=JSON.parse(new TextDecoder().decode(un64(parts[1])));}catch{fail('Session incorrecte.',401);}
 const auds=env.ACCESS_AUD.split(',').map(x=>x.trim());
 if(h.alg!=='RS256'||p.iss!==team||p.type!=='app'||!Array.isArray(p.aud)||!p.aud.some(a=>auds.includes(a))||p.exp<=now()||!Number.isInteger(p.iat)||p.iat>now()+60||p.email?.toLowerCase()!==env.ADMIN_EMAIL.toLowerCase())fail('Accès refusé.',403);
 let keys=jwksCache.get(team);if(!keys||keys.until<now()||!keys.keys.some(k=>k.kid===h.kid)){
  const r=await fetch(`${team}/cdn-cgi/access/certs`);if(!r.ok)fail('Authentification indisponible.',503);const j=await r.json();keys={keys:j.keys,until:now()+3600};jwksCache.set(team,keys);
 }
 const jwk=keys.keys.find(k=>k.kid===h.kid);if(!jwk)fail('Session non vérifiée.',401);
 const k=await crypto.subtle.importKey('jwk',jwk,{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['verify']);
 if(!await crypto.subtle.verify('RSASSA-PKCS1-v1_5',k,un64(parts[2]),enc.encode(`${parts[0]}.${parts[1]}`)))fail('Session non vérifiée.',401);
 if(!['GET','HEAD'].includes(req.method)&&(req.headers.get('Origin')!==env.PUBLIC_ORIGIN||req.headers.get('X-Lapi-Admin')!=='1'))fail('Origine incorrecte.',403);
 return p.email;
}
function key(){return 'LG-'+Array.from(crypto.getRandomValues(new Uint8Array(32)),v=>v.toString(16).padStart(2,'0')).join('').match(/.{1,8}/g).join('-').toUpperCase();}
export function normalizeKey(v){return String(v||'').toUpperCase().replace(/[-\s]/g,'');}
async function issue(env,row,device){
 if(!env.SIGNING_PRIVATE_JWK)fail('Clé de signature du service absente.',503);
 const issued=now();let exp=null;if(row.tier==='trial'){if(!row.activated_at)fail('Activation de l’essai incomplète.',409);exp=row.activated_at+7*86400;if(exp<=issued)fail('La période d’essai de 7 jours est terminée.',403);}else if(row.tier!=='owner')exp=issued+7*86400;const payload={iss:'lapigestion',aud:AUD,id:row.id,tier:row.tier,revision:row.revision,device,iat:issued,exp};
 const data=b64(enc.encode(JSON.stringify(payload)));
 const k=await crypto.subtle.importKey('jwk',JSON.parse(env.SIGNING_PRIVATE_JWK),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['sign']);
 return {payload:data,signature:b64(await crypto.subtle.sign('RSASSA-PKCS1-v1_5',k,enc.encode(data)))};
}
export async function authorize(req,env){
 await rate(req,env,'authorize',10);const b=await body(req);
 if(!['activate','refresh'].includes(b.action)||typeof b.spki!=='string'||b.spki.length>2048||typeof b.credential!=='string'||b.credential.length>128)fail('Demande incorrecte.');
 const taken=await statement(env,'DELETE FROM challenges WHERE nonce=? AND expires>? RETURNING nonce',b.nonce,now()).first();if(!taken)fail('Demande expirée. Recommence.',409);
 let deviceKey;try{deviceKey=await crypto.subtle.importKey('spki',un64(b.spki),{name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'},false,['verify']);}catch{fail('Installation incorrecte.');}
 if(deviceKey.algorithm.modulusLength<2048)fail('Installation incorrecte.');
 const message=`${b.nonce}\n${b.action}\n${b.credential}\n${b.spki}`;
 if(!await crypto.subtle.verify('RSASSA-PKCS1-v1_5',deviceKey,un64(b.proof||''),enc.encode(message)))fail('Preuve d’installation incorrecte.',403);
 const device=await sha(un64(b.spki));
 const row=b.action==='activate'?await statement(env,'SELECT * FROM licences WHERE key_hash=?',await sha(normalizeKey(b.credential))).first():await statement(env,'SELECT * FROM licences WHERE id=?',b.credential).first();
 if(!row)fail('Clé inexistante ou incorrecte.',404);if(row.status!=='active')fail('Licence révoquée.',403);
 if(b.action==='refresh'&&!row.device_hash)fail('Activation requise.',409);
 if(row.device_hash&&row.device_hash!==device)fail('Licence déjà liée à une autre installation. Contacte Les Lapibreizh.',409);
 const linked=await statement(env,"UPDATE licences SET device_hash=?,activated_at=CASE WHEN activated_at IS NULL THEN ? ELSE activated_at END,updated_at=? WHERE id=? AND status='active' AND (device_hash IS NULL OR device_hash=?) RETURNING *",device,now(),now(),row.id,device).first();
 if(!linked)fail('Licence indisponible. Recommence.',409);
 // A final read avoids issuing a stale level after a concurrent administrative change.
 const current=await statement(env,'SELECT * FROM licences WHERE id=?',row.id).first();
 if(current.status!=='active'||current.device_hash!==device)fail('Licence indisponible.',403);
 return json(await issue(env,current,device));
}
async function adminApi(req,env,actor,path){
 if(req.method==='GET'&&path==='/api/admin/licences')return json((await statement(env,'SELECT id,recipient,tier,status,revision,device_hash,activated_at,created_at,updated_at FROM licences ORDER BY created_at DESC').all()).results);
 if(req.method==='GET'&&path==='/api/admin/backup')return json({format:'lapigestion_licences_v1',createdAt:new Date().toISOString(),licences:(await statement(env,'SELECT * FROM licences').all()).results,audit:(await statement(env,'SELECT * FROM audit').all()).results});
 if(req.method==='POST'&&(path==='/api/admin/licences'||path==='/api/admin/owner')){
  const b=await body(req);const tier=path.endsWith('/owner')?'owner':String(b.tier);const recipient=String(b.recipient||'').trim();
  if(!recipient||recipient.length>160||!tiers.includes(tier)||(path.endsWith('/licences')&&tier==='owner'))fail('Nom ou niveau incorrect.');
  if(tier==='owner'&&b.confirm!=='PROPRIETAIRE')fail('Confirmation propriétaire requise.');
  if(tier==='owner'&&await statement(env,"SELECT id FROM licences WHERE tier='owner'").first())fail('Un profil propriétaire existe déjà. Utilise la récupération.',409);
  const activationKey=key(),id=crypto.randomUUID();await statement(env,'INSERT INTO licences(id,key_hash,recipient,tier,created_at,updated_at) VALUES(?,?,?,?,?,?)',id,await sha(normalizeKey(activationKey)),recipient,tier,now(),now()).run();await log(env,actor,'create',id);return json({id,key:activationKey},201);
 }
 const match=path.match(/^\/api\/admin\/licences\/([a-f0-9-]{36})$/);
 if(req.method==='PATCH'&&match){
  const row=await statement(env,'SELECT * FROM licences WHERE id=?',match[1]).first();if(!row)fail('Licence introuvable.',404);const b=await body(req);let activationKey=null;
  if(b.action==='recover'||b.action==='rotate'){
   activationKey=key();await statement(env,'UPDATE licences SET key_hash=?,device_hash=?,revision=revision+1,updated_at=? WHERE id=?',await sha(normalizeKey(activationKey)),b.action==='recover'?null:row.device_hash,now(),row.id).run();
  }else if(b.action==='level'){
   if(row.tier==='owner'||!['1','2','3','4'].includes(String(b.tier)))fail('Choisis un niveau utilisateur définitif 1 à 4.');
   await statement(env,'UPDATE licences SET tier=?,revision=revision+1,updated_at=? WHERE id=?',String(b.tier),now(),row.id).run();
  }else if(['revoke','reactivate'].includes(b.action)){
   if(row.tier==='owner')fail('Le profil propriétaire permanent ne peut pas être révoqué.');
   await statement(env,'UPDATE licences SET status=?,revision=revision+1,updated_at=? WHERE id=?',b.action==='revoke'?'revoked':'active',now(),row.id).run();
  }else fail('Commande inconnue.');await log(env,actor,b.action,row.id);return json({ok:true,...(activationKey?{key:activationKey}:{})});
 }
 fail('Commande inconnue.',404);
}
async function handle(req,env){
 const url=new URL(req.url),path=url.pathname;
 if(path==='/')return Response.redirect(`${env.PUBLIC_ORIGIN}/admin/`,302);
 if(path.startsWith('/api/admin/')||path.startsWith('/admin/')){
  const actor=await admin(req,env);
  if(path.startsWith('/api/admin/'))return adminApi(req,env,actor,path);
  const response=await env.ASSETS.fetch(req);const h=new Headers(response.headers);h.set('Cache-Control','no-store');h.set('X-Content-Type-Options','nosniff');h.set('Content-Security-Policy',"default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'");return new Response(response.body,{status:response.status,headers:h});
 }
 if(path==='/api/challenge'&&req.method==='POST'){await rate(req,env,'challenge',30);const nonce=random(32);await statement(env,'INSERT INTO challenges(nonce,expires) VALUES(?,?)',nonce,now()+120).run();return json({nonce});}
 if(path==='/api/authorize'&&req.method==='POST')return authorize(req,env);
 fail('Introuvable.',404);
}
export default {
 async fetch(req,env){try{return await handle(req,env);}catch(e){return json({error:e.status?e.message:'Service indisponible. Réessaie ou contacte Les Lapibreizh.'},e.status||503);}},
 async scheduled(_,env){await env.DB.batch([statement(env,'DELETE FROM challenges WHERE expires<?',now()),statement(env,'DELETE FROM rate_limits WHERE expires<?',now())]);}
};
