import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await LapiFrameAssets.instance.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    for (final family in ['LapiText', 'LapiEditorial', 'Roboto']) {
      final name = family == 'LapiEditorial' ? 'DejaVuSerif' : 'DejaVuSans';
      final loader = FontLoader(family)
        ..addFont(rootBundle.load('assets/fonts/$name.ttf'))
        ..addFont(rootBundle.load('assets/fonts/$name-Bold.ttf'));
      await loader.load();
    }
  });
  setUp(() {
    final rabbit = emptyRabbit()
      ..addAll({
        'id': 'ui_test_rabbit',
        'name': 'Nugget',
        'sex': 'Mâle',
        'sterilized': 'Non stérilisé(e)',
        'breed': 'Nain Bélier',
        'color': 'Chamois',
        'birth': '12/03/2024',
        'weaning': '10/05/2024',
        'vaccines': [
          {
            'product': 'Vaccination RHD1/RHD2',
            'date': '12/04/2025',
            'reminderMonths': 0,
            'notificationKey': 'test'
          }
        ],
        'dewormings': [
          {
            'product': 'Vermifuge',
            'date': '12/02/2025',
            'reminderMonths': 0,
            'notificationKey': 'test2'
          }
        ],
      });
    SharedPreferences.setMockInitialValues({
      Store.key: jsonEncode([rabbit]),
      AppModeStore.key: 'Éleveur'
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );
  });

  Future<void> show(WidgetTester tester, Widget page,
      {double width = 390, double scale = 1}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = const LapibreizhApp()
        .build(tester.element(find.byType(Container).first));
    // Reuse the application's actual ThemeData while bypassing splash/init plugins.
    await tester.pumpWidget(RepaintBoundary(
        key: const Key('capture'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: (app as MaterialApp).theme,
          home: page,
          builder: (context, child) => app.builder!(
              context,
              MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!)),
        )));
    await tester.runAsync(() async {
      final context = tester.element(find.byKey(const Key('capture')));
      await Future.wait([
        for (final name in [
          'lapigestion_background_master.jpg',
          'lapigestion_home_banner.png',
          'lapigestion_green_marble.jpg'
        ])
          precacheImage(AssetImage('assets/images/$name'), context),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
  }

  Future<void> begin(WidgetTester tester, Widget page,
      {double width = 390, double scale = 1}) async {
    await tester.pumpWidget(Container());
    await show(tester, page, width: width, scale: scale);
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (Platform.environment['LAPI_CAPTURE_DIR'] == null) return;
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('capture')));
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory(Platform.environment['LAPI_CAPTURE_DIR']!);
      await dir.create(recursive: true);
      await File('${dir.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      img.dispose();
    });
  }

  testWidgets('Accueil compact et filtres actifs conservent leurs actions',
      (tester) async {
    await begin(tester, const HomePage());
    expect(tester.takeException(), isNull);
    expect(find.text('Mode élevage'), findsOneWidget);
    await capture(tester, '01_accueil');
    await tester.tap(find.text('Adoptant').first);
    await tester.pumpAndSettle();
    expect(find.text('Mode adoptant'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString(AppModeStore.key),
        'Adoptant');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Identité : champs conservés et sélection sauvegardée',
      (tester) async {
    Map<String, dynamic>? saved;
    final data = emptyRabbit()
      ..addAll({
        'name': 'Nugget',
        'sex': 'Mâle',
        'breed': 'Nain Bélier',
        'color': 'Chamois'
      });
    await begin(
        tester,
        EditIdentity(
            data: data,
            onSave: (v) async {
              saved = v;
            }));
    await capture(tester, '03_identite');
    await tester.enterText(find.byType(TextFormField).first, 'Nugget modifié');
    await tester.tap(find.text('Femelle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENREGISTRER'));
    await tester.pumpAndSettle();
    expect(saved?['name'], 'Nugget modifié');
    expect(saved?['sex'], 'Femelle');
    expect(saved?['fatherName'], data['fatherName']);
    expect(saved?['birth'], data['birth']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Fiche : barre haute reste en place pendant le défilement',
      (tester) async {
    await begin(tester, const RabbitPage(index: 0));
    await capture(tester, '02_fiche_lapin');
    final before = tester.getRect(find.byType(AppBar).first);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    final after = tester.getRect(find.byType(AppBar).first);
    expect(after.top, before.top);
    expect(find.text('Nugget'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Le résumé santé ouvre et réduit son historique complet', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Container()));
    await show(tester, const RabbitPage(index: 0));
    expect(find.text('Voir tout'), findsOneWidget);
    await tester.ensureVisible(find.text('Voir tout'));
    await tester.tap(find.text('Voir tout'));
    await tester.pumpAndSettle();
    expect(find.text('Chronologie médicale'), findsOneWidget);
    await tester.ensureVisible(find.text('Réduire'));
    await tester.tap(find.text('Réduire'));
    await tester.pumpAndSettle();
    expect(find.text('Voir tout'), findsOneWidget);
    expect(find.text('Chronologie médicale'), findsNothing);
  });

  testWidgets('Tous les blocs accueil défilent sans erreur', (tester) async {
    await begin(tester, const HomePage());
    final scroll = find.byType(CustomScrollView);
    for (var i = 0; i < 12; i++) {
      await tester.drag(scroll, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (find
          .text('Je recherche une couleur')
          .hitTestable()
          .evaluate()
          .isNotEmpty) {
        await capture(tester, '04_recherche_outils');
      }
      if (find
          .text('Sécurité des données')
          .hitTestable()
          .evaluate()
          .isNotEmpty) {
        await capture(tester, '06_securite');
      }
    }
  });

  testWidgets('Tous les blocs fiche restent accessibles après la refonte',
      (tester) async {
    await begin(tester, const RabbitPage(index: 0));
    for (var i = 0; i < 22; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Adoption conserve la sélection et ses champs', (tester) async {
    Map<String, dynamic>? saved;
    await begin(
        tester,
        AdoptionDialog(
            data: emptyRabbit(),
            onSave: (v) async {
              saved = v;
            }));
    await capture(tester, '05_adoption');
    await tester.tap(find.text('Réservé'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENREGISTRER'));
    await tester.pumpAndSettle();
    expect(saved?['adoptionStatus'], 'Réservé');
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 768.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('Accueil et identité sans débordement : $width / $scale',
          (tester) async {
        await begin(tester, const HomePage(), width: width, scale: scale);
        expect(tester.takeException(), isNull);
        await begin(
            tester, EditIdentity(data: emptyRabbit(), onSave: (v) async {}),
            width: width, scale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
