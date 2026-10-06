import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carnet_sante_lapibreizh/main.dart';
import 'package:carnet_sante_lapibreizh/licensing.dart';
import 'licence_fixture.dart';

LicencePolicy policy(String tier) => LicencePolicy({
      'tier': tier,
      'exp': tier == 'owner'
          ? null
          : DateTime.now().millisecondsSinceEpoch ~/ 1000 + 604800
    });
Map<String, dynamic> rabbit(String id,
        {bool active = false, String sex = 'Mâle'}) =>
    emptyRabbit()
      ..addAll({
        'id': id,
        'sex': sex,
        'sterilized': 'Non stérilisé(e)',
        'activeBreeder': active
      });
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    folder = await Directory.systemTemp.createTemp('licences-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => folder.path);
    await installTestLicence();
  });
  tearDown(() async {
    await folder.delete(recursive: true);
  });
  test('Installation neuve : aucune fiche ni portée de démonstration',
      () async {
    expect(await Store.load(), isEmpty);
    expect(await ReproductionStore.load(), isEmpty);
  });
  for (final tier in ['trial', '1', '2', '3', '4', 'owner'])
    test('Droits précis du profil $tier', () {
      final p = policy(tier);
      expect(p.usable, true);
      expect(p.breeding, ['trial', '3', '4', 'owner'].contains(tier));
      expect(p.rabbitLimit, tier == '1' ? 1 : null);
      expect(p.breederLimit, tier == '3' ? 2 : null);
    });

  test('Essai 7 jours : accès complet tant que non expiré', () {
    final p = policy('trial');
    expect(p.usable, true);
    expect(p.breeding, true);
    expect(p.rabbitLimit, isNull);
    expect(p.breederLimit, isNull);
    expect(p.label, contains('Essai 7 jours'));
    expect(const LicencePolicy({'tier': 'trial', 'exp': 1}).usable, false);
  });
  test('Niveau 1 limite réellement les créations, même après réinstallation',
      () async {
    await installTestLicence('1');
    await Store.save([rabbit('a')]);
    expect(() => Store.save([rabbit('a'), rabbit('b')]),
        throwsA(isA<LicenceException>()));
    expect((await Store.snapshot()).length, 1);
  });
  for (final tier in ['trial', '2', '3', '4', 'owner'])
    test('Fiches illimitées $tier', () async {
      await installTestLicence(tier);
      await Store.save(List.generate(50, (i) => rabbit('$i')));
      expect((await Store.snapshot()).length, 50);
    });
  test('Niveaux Adoptant : pas de mode Élevage ni de nouvelle portée',
      () async {
    for (final tier in ['1', '2']) {
      await installTestLicence(tier);
      expect(await AppModeStore.load(), 'Adoptant');
      expect(
          () => AppModeStore.save('Éleveur'), throwsA(isA<LicenceException>()));
      expect(
          () => ReproductionStore.upsert(
              {'id': 'b', 'maleId': 'm', 'femaleId': 'f'}),
          throwsA(isA<LicenceException>()));
    }
  });
  test('Niveau 3 : deux reproducteurs combinés, troisième refusé', () async {
    await installTestLicence('3');
    final a = rabbit('m', active: true),
        b = rabbit('f', active: true, sex: 'Femelle');
    await Store.save([a, b]);
    expect(() => Store.save([a, b, rabbit('c', active: true)]),
        throwsA(isA<LicenceException>()));
    expect((await Store.snapshot()).length, 2);
  });
  test('Essai, niveau 4 et propriétaire : reproducteurs illimités', () async {
    for (final tier in ['trial', '4', 'owner']) {
      await installTestLicence(tier);
      await Store.save(List.generate(10, (i) => rabbit('$i', active: true)));
      expect((await Store.snapshot()).where(LicencePolicy.active).length, 10);
    }
  });
  test('Stérilisé ou parti ne compte plus comme reproducteur actif', () {
    expect(
        LicencePolicy.active(
            rabbit('a', active: true)..['sterilized'] = 'Stérilisé(e)'),
        false);
    expect(
        LicencePolicy.active(
            rabbit('a', active: true)..['adoptionStatus'] = 'Adopté / parti'),
        false);
  });
  test(
      'Niveau 3 : nouvelle saillie exige les deux actifs ; historique conserve ses soins',
      () async {
    await installTestLicence('3');
    await Store.save(
        [rabbit('m', active: true), rabbit('f', active: true, sex: 'Femelle')]);
    final r = {
      'id': 'portee',
      'maleId': 'm',
      'femaleId': 'f',
      'matingDate': '01/01/2026'
    };
    await ReproductionStore.upsert(r);
    await Store.save([rabbit('m'), rabbit('f', sex: 'Femelle')]);
    await ReproductionStore.upsert({...r, 'deadMaleWeaning': 1});
    expect(() => ReproductionStore.upsert({...r, 'matingDate': '02/01/2026'}),
        throwsA(isA<LicenceException>()));
  });
  test(
      'Rétrogradation vers 1 : consultation, suppression volontaire, aucune perte automatique',
      () async {
    await Store.save([rabbit('a'), rabbit('b')]);
    await installTestLicence('1');
    expect((await Store.snapshot()).length, 2);
    expect(() => Store.requireWritable(), throwsA(isA<LicenceException>()));
    await Store.save([rabbit('a')]);
    await Store.requireWritable();
  });
  test('Restauration niveau 1 rejetée avant écriture des fichiers', () async {
    await installTestLicence('1');
    final f = File('${folder.path}/restore.json');
    await f.writeAsString(jsonEncode({
      'format': BackupService.format,
      'rabbits': [rabbit('a'), rabbit('b')],
      'files': {
        'private.jpg': {
          'data': base64Encode([1, 2]),
          'extension': '.jpg'
        }
      }
    }));
    expect(() => BackupService.restoreFromFile(f.path),
        throwsA(isA<LicenceException>()));
    expect(await Store.snapshot(), isEmpty);
    expect(folder.listSync().whereType<Directory>(), isEmpty);
  });
  test('Restauration garde les anciennes données élevage en Adoptant',
      () async {
    await installTestLicence('2');
    final f = File('${folder.path}/restore.json');
    await f.writeAsString(jsonEncode({
      'format': BackupService.format,
      'rabbits': [rabbit('a')],
      'reproduction': [
        {'id': 'historique'}
      ],
      'appMode': 'Éleveur',
      'files': {}
    }));
    await BackupService.restoreFromFile(f.path);
    expect((await ReproductionStore.load()).single['id'], 'historique');
    expect(await AppModeStore.load(), 'Adoptant');
  });
  test('Révocation : écritures bloquées, sauvegarde conserve mode et données',
      () async {
    await Store.save([rabbit('a')]);
    await AppModeStore.save('Éleveur');
    await installTestLicence(null);
    expect(() => Store.save([]), throwsA(isA<LicenceException>()));
    final f = await BackupService.createBackup();
    final b = jsonDecode(await f.readAsString());
    expect(b['appMode'], 'Éleveur');
    expect((b['rabbits'] as List).length, 1);
  });
  test('Propriétaire ne peut pas remplacer son accès par une clé utilisateur',
      () async {
    expect(() => LicenceService.instance.activate('LG-test'),
        throwsA(isA<LicenceException>()));
  });
  test('Licence expirée et niveau inconnu refusés', () {
    expect(const LicencePolicy({'tier': '4', 'exp': 1}).usable, false);
    expect(const LicencePolicy({'tier': 'super-admin', 'exp': null}).usable,
        false);
  });
}
