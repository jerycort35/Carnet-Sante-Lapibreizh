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
    // The source update ZIP excludes two assets supplied by the Android repo.
    // Use its bundled banner only as a test background; production assets stay untouched.
    final messenger=TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final placeholder=File('assets/images/lapigestion_home_banner.png').readAsBytesSync();
    messenger.setMockMessageHandler('flutter/assets',(message)async{
      final name=utf8.decode(message!.buffer.asUint8List(message.offsetInBytes,message.lengthInBytes));
      if(name=='assets/images/lapigestion_background_master.jpg'||name=='assets/images/lapigestion_green_marble.jpg'){
        return ByteData.sublistView(placeholder);
      }
      final file=File('build/unit_test_assets/$name');
      return file.existsSync()?ByteData.sublistView(file.readAsBytesSync()):null;
    });
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
      if(page is RabbitPage){final dynamic state=tester.state(find.byType(RabbitPage));await state.load();}
      if(page is HomePage){final dynamic state=tester.state(find.byType(HomePage));await state.refresh();}
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
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await tester.pump();
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

  testWidgets('Croisements bloqués visibles avec tous les motifs et plus de cinq résultats',(tester)async{
    final date=Notifications.formatDate(DateTime.now().subtract(const Duration(days:3)));
    final female=emptyRabbit()..addAll({'id':'f','name':'Femelle test','sex':'Femelle','breed':'Géant Papillon Français',
      'medications':[{'startDate':date,'endDate':'','notificationKey':''}]});
    final males=[for(var i=1;i<=7;i++)emptyRabbit()..addAll({'id':'m$i','name':'Mâle $i','sex':'Mâle','breed':i==7?'Nain Bélier':'Géant Papillon Français'})];
    final records=[for(var i=1;i<=7;i++){'maleId':'m$i','femaleId':'f','birthDate':date,
      'liveMaleBirth':1,'colors':[{'color':'Noir','male':1,'female':0}]}];
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString(Store.key,jsonEncode([female,...males]));
    await prefs.setString(ReproductionStore.key,jsonEncode(records));
    await ReproductionSettingsStore.save(maxLitters:1,restDays:90);
    await tester.runAsync(()async{await Store.load();});
    await begin(tester,const HomePage());
    const warning='NE PAS RÉALISER CE CROISEMENT POUR LE MOMENT';
    await tester.scrollUntilVisible(find.text(warning).first,250,scrollable:find.byType(Scrollable).first);
    await tester.ensureVisible(find.text(warning).first);await tester.pumpAndSettle();
    expect(find.text(warning),findsNWidgets(6));
    expect(find.textContaining('Traitement médical actif chez'),findsNWidgets(6));
    expect(find.textContaining('Quota annuel atteint'),findsNWidgets(6));
    expect(find.textContaining('Période de repos non terminée'),findsNWidgets(6));
    expect(find.text('1 Noir sur 1 lapereaux • 100 % observés'),findsNWidgets(6));
    final text=tester.widget<Text>(find.text(warning).first);expect(text.style!.color,const Color(0xFFB71C1C));
    await capture(tester,'croisement_bloque');
    // End the treatment and relax only the user's quota/rest settings.
    female['medications']=[];
    await prefs.setString(Store.key,jsonEncode([female,...males]));
    await ReproductionSettingsStore.save(maxLitters:6,restDays:0);
    // Six births still reach a quota of six: keep a single matching record.
    await prefs.setString(ReproductionStore.key,jsonEncode([records.first]));
    final dynamic state=tester.state(find.byType(HomePage));
    await tester.runAsync(()async{await state.refresh();});await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('1 Noir sur 1 lapereaux • 100 % observés'),200,scrollable:find.byType(Scrollable).first);
    expect(find.text(warning),findsNothing);expect(find.textContaining('Traitement médical actif chez'),findsNothing);
    expect(find.text('1 Noir sur 1 lapereaux • 100 % observés'),findsOneWidget);
    // A nonmatching color must never become a result merely because it is blocked.
    records.first['colors']=[{'color':'Bleu','male':1,'female':0}];
    await prefs.setString(ReproductionStore.key,jsonEncode([records.first]));
    await tester.runAsync(()async{await state.refresh();});await tester.pumpAndSettle();
    expect(find.text('1 Noir sur 1 lapereaux • 100 % observés'),findsNothing);
    expect(tester.takeException(),isNull);
  });
}
