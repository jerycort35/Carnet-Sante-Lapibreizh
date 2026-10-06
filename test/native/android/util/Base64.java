package android.util;
public class Base64 {
 public static final int URL_SAFE=8,NO_WRAP=2,NO_PADDING=1;
 public static byte[] decode(String s,int flags){return java.util.Base64.getUrlDecoder().decode(s);}
 public static String encodeToString(byte[] b,int flags){return java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(b);}
}
