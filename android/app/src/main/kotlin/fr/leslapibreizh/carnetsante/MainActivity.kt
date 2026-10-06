package fr.leslapibreizh.carnetsante

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

class MainActivity: FlutterActivity() {
 override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
  super.configureFlutterEngine(flutterEngine)
  val messenger = flutterEngine.dartExecutor.binaryMessenger
  val bridge by lazy { LicensingBridge(applicationContext) }
  MethodChannel(messenger,"fr.leslapibreizh.carnetsante/licences",StandardMethodCodec.INSTANCE,messenger.makeBackgroundTaskQueue()).setMethodCallHandler { call,result ->
   try { result.success(bridge.handle(call.method, call.arguments as? Map<*,*> ?: emptyMap<Any,Any>())) }
   catch(e:Exception){result.error("licence",e.message ?: "Licence non vérifiée",null)}
  }
 }
}
