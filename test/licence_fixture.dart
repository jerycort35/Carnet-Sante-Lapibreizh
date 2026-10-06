import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/licensing.dart';

// Test-only native-channel fixture. Never included in lib/ or the APK.
Future<void> installTestLicence([String? tier = 'owner']) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(LicenceService.channel, (call) async {
    if (call.method == 'load')
      return tier == null
          ? null
          : {
              'id': '11111111-1111-1111-1111-111111111111',
              'tier': tier,
              'revision': 1,
              'exp': tier == 'owner' ? null : now + 604800
            };
    if (call.method == 'identifier') return null;
    return null;
  });
  await LicenceService.instance.recheck();
}
