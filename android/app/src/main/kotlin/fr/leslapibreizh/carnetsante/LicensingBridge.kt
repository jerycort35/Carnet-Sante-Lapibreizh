package fr.leslapibreizh.carnetsante

import android.content.Context
import android.os.SystemClock
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.AtomicFile
import org.json.JSONObject
import java.io.File
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature

class LicensingBridge(private val context:Context) {
 private val alias="lapigestion.licence.installation.v1"
 private val cache=AtomicFile(File(context.noBackupFilesDir,"lapigestion-licence.json"))
 private val keys:KeyStore by lazy { KeyStore.getInstance("AndroidKeyStore").apply {load(null)} }
 private fun identity():ByteArray {
  if(!keys.containsAlias(alias)) {
   val generator=KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA,"AndroidKeyStore")
   generator.initialize(KeyGenParameterSpec.Builder(alias,KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY).setKeySize(2048).setDigests(KeyProperties.DIGEST_SHA256).setSignaturePaddings(KeyProperties.SIGNATURE_PADDING_RSA_PKCS1).build())
   generator.generateKeyPair()
  }
  return keys.getCertificate(alias).publicKey.encoded
 }
 private fun read():JSONObject?=try {JSONObject(String(cache.readFully(),Charsets.UTF_8))}catch(_:Exception){null}
 private fun write(data:JSONObject){val out=cache.startWrite();try{out.write(data.toString().toByteArray(Charsets.UTF_8));cache.finishWrite(out)}catch(e:Exception){cache.failWrite(out);throw e}}
 private fun map(p:JSONObject):Map<String,Any?> = p.keys().asSequence().associateWith {if(p.isNull(it))null else p.get(it)}
 fun handle(method:String,args:Map<*,*>):Any? {
  val spki=identity();val device=LicenceTokenVerifier.device(spki);val wall=System.currentTimeMillis()/1000
  when(method){
   "identity" -> return LicenceTokenVerifier.encode(spki)
   "sign" -> {val s=Signature.getInstance("SHA256withRSA");s.initSign(keys.getKey(alias,null) as java.security.PrivateKey);s.update((args["message"] as String).toByteArray(Charsets.UTF_8));return LicenceTokenVerifier.encode(s.sign())}
   "identifier" -> return try{JSONObject(String(LicenceTokenVerifier.decode(read()!!.getJSONObject("token").getString("payload")),Charsets.UTF_8)).getString("id")}catch(_:Exception){null}
   "clear" -> {val existing=read();if(existing!=null)try{if(LicenceTokenVerifier.verify(existing.getJSONObject("token"),args["signer"] as String,device,wall).getString("tier")=="owner")return null}catch(_:Exception){};cache.delete();return null}
   "load" -> {
    val saved=read()?:return null;val before=saved.optLong("wall",0);val elapsed=SystemClock.elapsedRealtime()/1000;val priorElapsed=saved.optLong("elapsed",0)
    val p=LicenceTokenVerifier.verify(saved.getJSONObject("token"),args["signer"] as String,device,wall,before)
    if(p.getString("tier")!="owner"&&elapsed>=priorElapsed)require(wall+300>=before+elapsed-priorElapsed){"L’horloge a changé : contrôle en ligne nécessaire"}
    saved.put("wall",maxOf(wall,before));saved.put("elapsed",elapsed);write(saved);return map(p)
   }
   "accept" -> {
    val signer=args["signer"] as String;val token=JSONObject(args["token"] as Map<*,*>);val p=LicenceTokenVerifier.verify(token,signer,device,wall)
    if(p.getString("tier")!="owner")require(kotlin.math.abs(wall-p.getLong("iat"))<=300){"Autorisation expirée"}
    val old=read();val previous=try{old?.let{LicenceTokenVerifier.verify(it.getJSONObject("token"),signer,device,wall)}}catch(_:Exception){null};if(previous?.getString("tier")=="owner")require(p.getString("tier")=="owner"&&p.getString("id")==previous.getString("id")){"L’accès propriétaire ne peut pas être remplacé"}
    write(JSONObject().put("token",token).put("wall",wall).put("elapsed",SystemClock.elapsedRealtime()/1000));return map(p)
   }
   else -> throw IllegalArgumentException("Commande inconnue")
  }
 }
}
