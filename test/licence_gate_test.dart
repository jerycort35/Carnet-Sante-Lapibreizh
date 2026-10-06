import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carnet_sante_lapibreizh/main.dart';
import 'package:carnet_sante_lapibreizh/licensing.dart';
import 'licence_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  setUp(() async {
    folder = await Directory.systemTemp.createTemp('gate-test-');
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => folder.path);
    await installTestLicence();
  });
  tearDown(() async {
    await folder.delete(recursive: true);
  });
  Future<void> show(WidgetTester tester) async {
    await tester.runAsync(() async {
      await LapiFrameAssets.instance.load();
    });
    await tester.pumpWidget(const MaterialApp(home: LicenceGate()));
    await tester.pump();
    await tester.runAsync(() async {
      await LicenceService.instance.load();
    });
    await tester.pump();
    if (find.byType(HomePage).evaluate().isNotEmpty)
      await tester.runAsync(() async {
        final dynamic s = tester.state(find.byType(HomePage));
        await s.refresh();
      });
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Propriétaire : accueil complet et retour Android dans le navigateur interne',
      (tester) async {
    await show(tester);
    expect(find.byType(HomePage), findsOneWidget);
    final context = tester.element(find.byType(HomePage));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Page interne de test'))));
    await tester.pumpAndSettle();
    expect(find.text('Page interne de test'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Page interne de test'), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'Perte des droits ferme les pages internes et conserve les fiches',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        Store.key, jsonEncode([emptyRabbit()..['id'] = 'preserved']));
    await show(tester);
    Navigator.of(tester.element(find.byType(HomePage))).push(MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Page fermée'))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await installTestLicence(null);
    });
    await tester.pumpAndSettle();
    expect(find.text('Page fermée'), findsNothing);
    expect(find.byType(LicencePage), findsOneWidget);
    expect(jsonDecode(prefs.getString(Store.key)!).single['id'], 'preserved');
    expect(find.text('Sauvegarder mes données'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
