import 'licence_fixture.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  setUp(()async{
    await installTestLicence();
    folder=await Directory.systemTemp.createTemp('lapi_document_pages_');
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),(call)async=>folder.path);
  });
  tearDown(()async{await folder.delete(recursive:true);});
  test('Lecture des anciennes fiches et conservation de l’ordre',(){
    expect(documentPages({'healthBook':'ancien.jpg'},'healthBook'),['ancien.jpg']);
    expect(documentPages({'passport':['page2.jpg','page1.pdf']},'passport'),['page2.jpg','page1.pdf']);
    expect(documentPages({'passport':''},'passport'),isEmpty);
  });
  test('Migration du fichier unique sans perdre sa copie',()async{
    final original=File('${folder.path}/ancien.jpg');await original.writeAsBytes([1,2,3]);
    final rabbit=emptyRabbit()..['healthBook']=original.path;
    await Store.save([rabbit]);
    final migrated=(await Store.load()).single;
    final pages=documentPages(migrated,'healthBook');
    expect(migrated['healthBook'],isA<List>());
    expect(pages,hasLength(1));
    expect(await File(pages.single).readAsBytes(),[1,2,3]);
    expect(await original.exists(),isTrue);
  });
  test('Sauvegarde et restauration de toutes les pages des deux documents',()async{
    final paths=<String>[];
    for(var i=0;i<4;i++){
      final file=File('${folder.path}/page$i.jpg');await file.writeAsBytes([i,7,9]);paths.add(file.path);
    }
    final rabbit=emptyRabbit()..['healthBook']=paths.take(2).toList()..['passport']=paths.skip(2).toList();
    await Store.save([rabbit]);
    final backup=await BackupService.createBackup();
    final payload=jsonDecode(await backup.readAsString()) as Map;
    expect((payload['files'] as Map).length,4);
    await Store.save([]);
    await BackupService.restoreFromFile(backup.path);
    final restored=(await Store.load()).single;
    final all=[...documentPages(restored,'healthBook'),...documentPages(restored,'passport')];
    expect(all,hasLength(4));
    for(var i=0;i<4;i++){expect(await File(all[i]).readAsBytes(),[i,7,9]);}
    expect(documentPages(restored,'healthBook'),hasLength(2));
    expect(documentPages(restored,'passport'),hasLength(2));
  });
  test('Ancienne sauvegarde avec chemin unique reste restaurable',()async{
    final file=File('${folder.path}/legacy.json');
    await file.writeAsString(jsonEncode({'format':BackupService.format,'appMode':'Adoptant','rabbits':[emptyRabbit()..['passport']='old.jpg'],'reproduction':[],'files':{'old.jpg':{'extension':'.jpg','data':base64Encode([4,5,6])}}}));
    await BackupService.restoreFromFile(file.path);
    final rabbit=(await Store.load()).single;
    final pages=documentPages(rabbit,'passport');
    expect(pages,hasLength(1));expect(await File(pages.single).readAsBytes(),[4,5,6]);
  });
}
