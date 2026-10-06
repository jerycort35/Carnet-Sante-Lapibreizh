import java.security.*;
import java.util.*;
import org.json.JSONObject;
import fr.leslapibreizh.carnetsante.LicenceTokenVerifier;
public class NativeLicenceVerifierTest {
 static final String id="11111111-1111-1111-1111-111111111111";static KeyPair signer;static String publicKey;static long wall=2000000000;static int passed;
 static String encode(byte[] b){return Base64.getUrlEncoder().withoutPadding().encodeToString(b);}
 static JSONObject claim(String tier){return new JSONObject().put("iss","lapigestion").put("aud","fr.leslapibreizh.carnetsante").put("id",id).put("tier",tier).put("revision",1).put("device","installation").put("iat",wall).put("exp",tier.equals("owner")?JSONObject.NULL:wall+604800);}
 static JSONObject sign(JSONObject p)throws Exception{String payload=encode(p.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));Signature s=Signature.getInstance("SHA256withRSA");s.initSign(signer.getPrivate());s.update(payload.getBytes(java.nio.charset.StandardCharsets.UTF_8));return new JSONObject().put("payload",payload).put("signature",encode(s.sign()));}
 static void verify(JSONObject token,long w,long old){LicenceTokenVerifier.INSTANCE.verify(token,publicKey,"installation",w,old);}
 interface Action {void run()throws Exception;}
 static void test(String name,Action a)throws Exception{a.run();System.out.println("PASS "+name);passed++;}
 static void reject(JSONObject p,long w,long old)throws Exception{try{verify(sign(p),w,old);throw new AssertionError("Accepted forbidden token");}catch(IllegalArgumentException expected){}}
 public static void main(String[] args)throws Exception {
  KeyPairGenerator g=KeyPairGenerator.getInstance("RSA");g.initialize(2048);signer=g.generateKeyPair();publicKey=encode(signer.getPublic().getEncoded());
  for(String tier:new String[]{"1","2","3","4","owner"})test("profile "+tier,()->verify(sign(claim(tier)),wall,0));
  test("forged signature",()->{JSONObject token=sign(claim("4"));token.put("signature",encode(new byte[256]));try{verify(token,wall,0);throw new AssertionError();}catch(IllegalArgumentException expected){}});
  test("different installation",()->reject(claim("4").put("device","another"),wall,0));
  test("different application",()->reject(claim("4").put("aud","other"),wall,0));
  test("expired",()->reject(claim("4"),wall+604800,0));
  test("too long offline",()->reject(claim("4").put("exp",wall+604801),wall,0));
  test("unknown tier",()->reject(claim("root"),wall,0));
  test("owner permanent only",()->reject(claim("owner").put("exp",wall+604800),wall,0));
  test("clock rollback",()->reject(claim("4"),wall,wall+301));
  test("owner in 100 years",()->verify(sign(claim("owner")),wall+100L*365*86400,wall+1000));
  System.out.println(passed+" native verification tests passed");
 }
}
