package fr.leslapibreizh.carnetsante

import android.util.Base64
import org.json.JSONObject
import java.security.KeyFactory
import java.security.MessageDigest
import java.security.Signature
import java.security.spec.X509EncodedKeySpec

object LicenceTokenVerifier {
 fun decode(s:String):ByteArray=Base64.decode(s,Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
 fun encode(b:ByteArray):String=Base64.encodeToString(b,Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
 fun device(spki:ByteArray):String=encode(MessageDigest.getInstance("SHA-256").digest(spki))
 fun verify(token:JSONObject,signer:String,device:String,wall:Long,previousWall:Long=0):JSONObject {
  require(signer.isNotBlank()) { "Service de licences non configuré" }
  val payload=token.getString("payload")
  require(payload.length<8192) { "Licence incorrecte" }
  val key=KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(decode(signer)))
  val verifier=Signature.getInstance("SHA256withRSA");verifier.initVerify(key);verifier.update(payload.toByteArray(Charsets.UTF_8))
  require(verifier.verify(decode(token.getString("signature")))) { "Signature de licence incorrecte" }
  val p=JSONObject(String(decode(payload),Charsets.UTF_8))
  require(p.getString("iss")=="lapigestion"&&p.getString("aud")=="fr.leslapibreizh.carnetsante") { "Licence d’une autre application" }
  require(p.getString("device")==device) { "Licence d’une autre installation" }
  val tier=p.getString("tier");require(tier in listOf("1","2","3","4","owner")) { "Niveau incorrect" }
  require(p.getString("id").matches(Regex("[a-f0-9-]{36}"))&&p.getInt("revision")>0) { "Licence incorrecte" }
  val issued=p.getLong("iat")
  if(tier=="owner")require(p.isNull("exp")) { "Profil propriétaire incorrect" }
  else {
   val expiry=p.getLong("exp")
   require(issued<=wall+300&&expiry>wall&&expiry>issued&&expiry-issued<=7*86400) { "Contrôle en ligne de licence nécessaire" }
   require(previousWall<=wall+300) { "L’horloge a changé : contrôle en ligne nécessaire" }
  }
  return p
 }
}
