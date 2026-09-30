import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const gold = Color(0xFFD4AF67);
const ink = Color(0xFF171512);
const ivory = Color(0xFFFFFBF2);
const brown = Color(0xFF463622);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.init();
  runApp(const LapibreizhApp());
}

class LapibreizhApp extends StatelessWidget {
  const LapibreizhApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Carnet de Santé Lapibreizh',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.light),
      scaffoldBackgroundColor: ivory,
      inputDecorationTheme: InputDecorationTheme(filled:true, fillColor: Colors.white.withValues(alpha:.94), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color:gold,width:2))),
      cardTheme: CardThemeData(color: Colors.white.withValues(alpha:.94), elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color:gold,width:1))),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: ink, foregroundColor: gold, padding: const EdgeInsets.symmetric(horizontal:18,vertical:14), shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)))),
    ),
    home: const HomePage(),
  );
}


class Notifications {
  static final FlutterLocalNotificationsPlugin plugin=FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    try{
      final info=await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    }catch(_){}
    const android=AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(const InitializationSettings(android:android));
  }

  static Future<void> requestPermission() async {
    try{
      await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    }catch(_){}
  }

  static int notificationId(String seed){
    var hash=2166136261;
    for(final c in seed.codeUnits){
      hash^=c;
      hash=(hash*16777619)&0x7fffffff;
    }
    return hash;
  }

  static DateTime? parseDate(String? value){
    if(value==null||value.isEmpty)return null;
    final p=value.split('/');
    if(p.length!=3)return null;
    final d=int.tryParse(p[0]),m=int.tryParse(p[1]),y=int.tryParse(p[2]);
    if(d==null||m==null||y==null)return null;
    return DateTime(y,m,d);
  }

  static String formatDate(DateTime d)=>'${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  static DateTime addMonths(DateTime d,int months){
    final total=(d.month-1)+months;
    final year=d.year+(total~/12);
    final month=(total%12)+1;
    final last=DateTime(year,month+1,0).day;
    final day=d.day>last?last:d.day;
    return DateTime(year,month,day,d.hour,d.minute);
  }

  static Future<void> cancelToken(String token) async {
    if(token.isEmpty)return;
    try{
      final pending=await plugin.pendingNotificationRequests();
      for(final n in pending){
        if((n.payload??'').startsWith('$token|'))await plugin.cancel(n.id);
      }
    }catch(_){}
  }

  static const details=NotificationDetails(
    android:AndroidNotificationDetails(
      'lapibreizh_rappels',
      'Rappels santé Lapibreizh',
      channelDescription:'Vaccins, vermifuges et rendez-vous vétérinaires',
      importance:Importance.high,
      priority:Priority.high,
    ),
  );

  static Future<void> _schedule({
    required String token,
    required String idSeed,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if(!when.isAfter(DateTime.now()))return;
    final local=tz.TZDateTime(tz.local,when.year,when.month,when.day,when.hour,when.minute);
    await plugin.zonedSchedule(
      notificationId(idSeed),
      title,
      body,
      local,
      details,
      androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle,
      payload:'$token|$idSeed',
    );
  }

  static Future<void> scheduleTreatment({
    required String rabbitName,
    required String kind,
    required Map<String,dynamic> item,
  }) async {
    final token=(item['notificationKey']??'') as String;
    await cancelToken(token);
    final months=(item['reminderMonths']??0) as int;
    final date=parseDate(item['date'] as String?);
    if(token.isEmpty||months<=0||date==null)return;
    final days=((item['reminderDays'] as List?)??[0]).map((e)=>e as int).toList();
    if(days.isEmpty)return;
    await requestPermission();

    var due=addMonths(date,months);
    final recurring=(item['recurring']??true) as bool;
    final now=DateTime.now();
    while(due.add(const Duration(hours:9)).isBefore(now)){
      if(!recurring)return;
      due=addMonths(due,months);
    }

    final occurrences=recurring ? (months==3?20:months==6?10:5) : 1;
    final product=((item['product']??'') as String).trim();
    for(var n=0;n<occurrences;n++){
      final dueAt=DateTime(due.year,due.month,due.day,9);
      for(final before in days){
        final when=dueAt.subtract(Duration(days:before));
        final timing=before==0?'aujourd’hui':before==1?'demain':before==3?'dans 3 jours':before==7?'dans une semaine':'dans $before jours';
        final body=before==0
          ? '$kind pour $rabbitName${product.isEmpty?'':' • $product'} : rappel prévu aujourd’hui.'
          : '$kind pour $rabbitName${product.isEmpty?'':' • $product'} : échéance $timing.';
        await _schedule(
          token:token,
          idSeed:'$token|treatment|$n|$before',
          title:'Rappel $kind • $rabbitName',
          body:body,
          when:when,
        );
      }
      if(!recurring)break;
      due=addMonths(due,months);
    }
  }

  static Future<void> scheduleAppointment({
    required String rabbitName,
    required Map<String,dynamic> item,
  }) async {
    final token=(item['notificationKey']??'') as String;
    await cancelToken(token);
    final d=parseDate(item['date'] as String?);
    if(token.isEmpty||d==null)return;
    final time=((item['time']??'09:00') as String).split(':');
    final hour=time.isNotEmpty?int.tryParse(time[0])??9:9;
    final minute=time.length>1?int.tryParse(time[1])??0:0;
    final appointment=DateTime(d.year,d.month,d.day,hour,minute);
    final days=((item['reminderDays'] as List?)??[1]).map((e)=>e as int).toList();
    if(days.isEmpty)return;
    await requestPermission();
    final reason=((item['reason']??'') as String).trim();

    for(final before in days){
      final when=appointment.subtract(Duration(days:before));
      final body=before==0
        ? 'Rendez-vous vétérinaire aujourd’hui pour $rabbitName${reason.isEmpty?'':' : $reason'} à ${item['time']}.'
        : before==1
          ? 'Attention : demain, rendez-vous vétérinaire pour $rabbitName${reason.isEmpty?'':' : $reason'} à ${item['time']}.'
          : 'Rendez-vous vétérinaire pour $rabbitName${reason.isEmpty?'':' : $reason'} dans $before jours.';
      await _schedule(
        token:token,
        idSeed:'$token|appointment|$before',
        title:'Rendez-vous vétérinaire • $rabbitName',
        body:body,
        when:when,
      );
    }
  }

  static Future<void> refreshAll(List<Map<String,dynamic>> rabbits) async {
    for(final r in rabbits){
      final name=((r['name']??'Lapin') as String).trim().isEmpty?'Lapin':(r['name'] as String);
      for(final key in ['vaccines','dewormings']){
        final kind=key=='vaccines'?'vaccin':'vermifuge';
        for(final raw in ((r[key] as List?)??[])){
          await scheduleTreatment(rabbitName:name,kind:kind,item:Map<String,dynamic>.from(raw));
        }
      }
      for(final raw in ((r['appointments'] as List?)??[])){
        await scheduleAppointment(rabbitName:name,item:Map<String,dynamic>.from(raw));
      }
    }
  }

  static Future<void> cancelRabbit(Map<String,dynamic> rabbit) async {
    for(final key in ['vaccines','dewormings','appointments']){
      for(final raw in ((rabbit[key] as List?)??[])){
        final token=((raw['notificationKey']??'') as String);
        await cancelToken(token);
      }
    }
  }
}

class Store {
  static const key='lapibreizh_rabbits_v1';
  static Future<List<Map<String,dynamic>>> load() async {
    final p=await SharedPreferences.getInstance();
    final s=p.getString(key);
    if(s==null)return [];
    final list=(jsonDecode(s) as List).map((e)=>Map<String,dynamic>.from(e)).toList();
    var changed=await PrivateFiles.migrateAll(list);
    for(var ri=0;ri<list.length;ri++){
      final r=list[ri];
      if(r['id']==null||((r['id']??'') as String).isEmpty){r['id']='r_${DateTime.now().microsecondsSinceEpoch}_$ri';changed=true;}
      if(r['sterilized']==null){r['sterilized']='';changed=true;}
      if(r['appointments']==null){r['appointments']=[];changed=true;}
      for(final key in ['vaccines','dewormings']){
        for(final raw in ((r[key] as List?)??[])){
          final item=raw as Map<String,dynamic>;
          if(item['notificationKey']==null){item['notificationKey']='t_${DateTime.now().microsecondsSinceEpoch}_${list.indexOf(r)}_${(r[key] as List).indexOf(raw)}';changed=true;}
          if(item['reminderMonths']==null){item['reminderMonths']=0;changed=true;}
          if(item['reminderDays']==null){item['reminderDays']=[0];changed=true;}
          if(item['recurring']==null){item['recurring']=true;changed=true;}
        }
      }
    }
    if(changed)await p.setString(key,jsonEncode(list));
    return list;
  }
  static Future<void> save(List<Map<String,dynamic>> v) async { final p=await SharedPreferences.getInstance(); await p.setString(key,jsonEncode(v)); }
}


class ReproductionStore {
  static const key='lapibreizh_reproduction_v1';

  static Future<List<Map<String,dynamic>>> load() async {
    final p=await SharedPreferences.getInstance();
    final s=p.getString(key);
    if(s==null)return [];
    return (jsonDecode(s) as List).map((e)=>Map<String,dynamic>.from(e)).toList();
  }

  static Future<void> save(List<Map<String,dynamic>> v) async {
    final p=await SharedPreferences.getInstance();
    await p.setString(key,jsonEncode(v));
  }

  static Future<void> upsert(Map<String,dynamic> record) async {
    final all=await load();
    final id=(record['id']??'') as String;
    final i=all.indexWhere((e)=>e['id']==id);
    if(i>=0){all[i]=record;}else{all.add(record);}
    await save(all);
  }

  static Future<void> remove(String id) async {
    final all=await load();
    all.removeWhere((e)=>e['id']==id);
    await save(all);
  }

  static Future<void> removeRabbit(String rabbitId) async {
    final all=await load();
    all.removeWhere((e)=>e['maleId']==rabbitId||e['femaleId']==rabbitId);
    await save(all);
  }

  static int n(dynamic value)=>value is int?value:int.tryParse('$value')??0;

  static Map<String,int> totals(Map<String,dynamic> r)=>{
    'liveBirth':n(r['liveMaleBirth'])+n(r['liveFemaleBirth']),
    'deadBirth':n(r['deadMaleBirth'])+n(r['deadFemaleBirth']),
    'born':n(r['liveMaleBirth'])+n(r['liveFemaleBirth'])+n(r['deadMaleBirth'])+n(r['deadFemaleBirth']),
    'maleTotal':n(r['liveMaleBirth'])+n(r['deadMaleBirth']),
    'femaleTotal':n(r['liveFemaleBirth'])+n(r['deadFemaleBirth']),
    'weaned':n(r['liveMaleWeaning'])+n(r['liveFemaleWeaning']),
  };

  static Map<String,int> aggregate(Iterable<Map<String,dynamic>> records){
    const keys=[
      'liveMaleBirth','liveFemaleBirth','deadMaleBirth','deadFemaleBirth',
      'liveMaleWeaning','liveFemaleWeaning',
    ];
    final result=<String,int>{for(final key in keys) key:0};
    for(final record in records){
      for(final key in keys){result[key]=(result[key]??0)+n(record[key]);}
    }
    return result;
  }

  static Map<String,double> sexProfile(Iterable<Map<String,dynamic>> records){
    final sums=aggregate(records);
    final male=n(sums['liveMaleBirth'])+n(sums['deadMaleBirth']);
    final female=n(sums['liveFemaleBirth'])+n(sums['deadFemaleBirth']);
    final total=male+female;
    if(total==0)return {'male':0,'female':0,'balance':0};
    final malePct=male*100/total;
    final femalePct=female*100/total;
    final balance=100-(malePct-femalePct).abs();
    return {'male':malePct,'female':femalePct,'balance':balance};
  }
}


class PrivateFiles {
  static Future<Directory> _root() async {
    final base=await getApplicationSupportDirectory();
    final dir=Directory('${base.path}/lapibreizh_files');
    if(!await dir.exists())await dir.create(recursive:true);
    final noMedia=File('${dir.path}/.nomedia');
    if(!await noMedia.exists())await noMedia.writeAsString('');
    return dir;
  }

  static Future<Directory> _legacyRoot() async {
    final base=await getApplicationDocumentsDirectory();
    return Directory('${base.path}/lapibreizh_files');
  }

  static bool _inside(String path,String root)=>path==root||path.startsWith('$root${Platform.pathSeparator}');

  static String extensionOf(String path){
    final name=path.split(RegExp(r'[/\\]')).last;
    final dot=name.lastIndexOf('.');
    return dot>=0?name.substring(dot).toLowerCase():'';
  }

  static bool isImage(String path){
    final e=extensionOf(path);
    return ['.jpg','.jpeg','.png','.webp','.gif','.bmp'].contains(e);
  }

  static Future<String> importFile(String sourcePath,String category) async {
    if(sourcePath.isEmpty)return '';
    final source=File(sourcePath);
    if(!await source.exists())return '';
    final root=await _root();
    final dir=Directory('${root.path}/$category');
    if(!await dir.exists())await dir.create(recursive:true);
    final ext=extensionOf(sourcePath);
    final target=File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}$ext');
    await source.copy(target.path);
    return target.path;
  }

  static Future<String> saveBytes(Uint8List bytes,String category,{String extension='.jpg'}) async {
    final root=await _root();
    final dir=Directory('${root.path}/$category');
    if(!await dir.exists())await dir.create(recursive:true);
    final ext=extension.startsWith('.')?extension:'.$extension';
    final target=File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}$ext');
    await target.writeAsBytes(bytes,flush:true);
    return target.path;
  }

  static Future<void> deleteFile(String? path) async {
    if(path==null||path.isEmpty)return;
    try{
      final root=await _root();
      final legacy=await _legacyRoot();
      if(!_inside(path,root.path)&&!_inside(path,legacy.path))return;
      final file=File(path);
      if(await file.exists())await file.delete();
    }catch(_){}
  }

  static Future<String> _migratePath(String path,String category) async {
    if(path.isEmpty)return '';
    final file=File(path);
    if(!await file.exists())return path;
    final root=await _root();
    if(_inside(path,root.path))return path;
    final legacy=await _legacyRoot();
    final copied=await importFile(path,category);
    if(copied.isEmpty)return path;
    if(_inside(path,legacy.path)){
      try{await file.delete();}catch(_){}
    }
    return copied;
  }

  static Future<bool> migrateAll(List<Map<String,dynamic>> rabbits) async {
    var changed=false;
    for(final r in rabbits){
      for(final entry in {'photo':'rabbit_photos','healthBook':'documents','passport':'documents'}.entries){
        final old=(r[entry.key]??'') as String;
        final moved=await _migratePath(old,entry.value);
        if(moved!=old){r[entry.key]=moved;changed=true;}
      }
      for(final key in ['vaccines','dewormings']){
        final items=(r[key] as List?)??[];
        for(final item in items){
          final old=(item['photo']??'') as String;
          final moved=await _migratePath(old,'treatments');
          if(moved!=old){item['photo']=moved;changed=true;}
        }
      }
    }
    try{
      final legacy=await _legacyRoot();
      if(await legacy.exists()){
        final remains=await legacy.list(recursive:true).toList();
        if(remains.whereType<File>().isEmpty)await legacy.delete(recursive:true);
      }
    }catch(_){}
    return changed;
  }
}

class Scenic extends StatelessWidget {
  final Widget child; final bool compact;
  const Scenic({super.key,required this.child,this.compact=false});
  @override Widget build(BuildContext context)=>Container(
    decoration: const BoxDecoration(image:DecorationImage(image:AssetImage('assets/images/accueil.png'),fit:BoxFit.cover,alignment:Alignment.center)),
    child: Container(decoration:BoxDecoration(color:Colors.white.withValues(alpha: compact ? .78 : .36)),child:child),
  );
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage>{
  List<Map<String,dynamic>> rabbits=[]; bool loading=true;
  @override void initState(){super.initState();refresh();}
  Future<void> refresh() async {rabbits=await Store.load(); await Notifications.refreshAll(rabbits); if(mounted)setState(()=>loading=false);}
  Future<void> addRabbit() async { final r=emptyRabbit(); rabbits.add(r); await Store.save(rabbits); if(!mounted)return; await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:rabbits.length-1))); await refresh(); }
  @override Widget build(BuildContext context)=>Scaffold(
    body:Scenic(child:SafeArea(child:loading?const Center(child:CircularProgressIndicator()):CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,18,18,8),child:Column(children:[
        Container(width:150,height:150,decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),border:Border.all(color:gold,width:3),boxShadow:const [BoxShadow(blurRadius:18,color:Colors.black38)]),clipBehavior:Clip.antiAlias,child:Image.asset('assets/images/logo.png',fit:BoxFit.cover)),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.symmetric(horizontal:18,vertical:10),decoration:BoxDecoration(color:ink.withValues(alpha:.90),borderRadius:BorderRadius.circular(20),border:Border.all(color:gold)),child:const Column(children:[Text('CARNET DE SANTÉ',style:TextStyle(color:gold,fontWeight:FontWeight.w800,fontSize:22,letterSpacing:1.2)),Text('Les Lapibreizh',style:TextStyle(color:Colors.white,fontSize:16))])),
        const SizedBox(height:18),
      ]))),
      if(rabbits.isEmpty) SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(22),child:Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[const Icon(Icons.pets,size:46,color:brown),const SizedBox(height:12),const Text('Votre carnet commence ici',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Créez une fiche pour chaque lapin et gardez son suivi de santé au même endroit.',textAlign:TextAlign.center),const SizedBox(height:16),FilledButton.icon(onPressed:addRabbit,icon:const Icon(Icons.add),label:const Text('Créer mon premier lapin'))]))))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(14,0,14,110),sliver:SliverList.builder(itemCount:rabbits.length,itemBuilder:(c,i){final r=rabbits[i];return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(child:ListTile(contentPadding:const EdgeInsets.all(12),leading:Hero(tag:'rabbit$i',child:Container(width:68,height:68,decoration:BoxDecoration(color:gold.withValues(alpha:.20),borderRadius:BorderRadius.circular(14),border:Border.all(color:gold,width:2)),clipBehavior:Clip.antiAlias,child:(r['photo']??'').isEmpty?const Icon(Icons.pets,color:ink,size:32):Image.file(File(r['photo']),fit:BoxFit.cover))),title:Text((r['name']??'').isEmpty?'Lapin sans nom':r['name'],style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),subtitle:Text('${r['breed']?.isEmpty==false?r['breed']:'Race à renseigner'}${r['birth']?.isEmpty==false?'  •  ${r['birth']}':''}'),trailing:const Icon(Icons.chevron_right,color:brown),onTap:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:i)));await refresh();})));})),
    ]))),
    floatingActionButton:rabbits.isEmpty?null:FloatingActionButton.extended(onPressed:addRabbit,backgroundColor:ink,foregroundColor:gold,icon:const Icon(Icons.add),label:const Text('Nouveau lapin')),
  );
}

ImageProvider? fileImage(dynamic p){if(p is String&&p.isNotEmpty&&File(p).existsSync())return FileImage(File(p));return null;}
Map<String,dynamic> emptyRabbit()=>{'id':'r_${DateTime.now().microsecondsSinceEpoch}','name':'','sex':'','sterilized':'','breed':'','birth':'','weaning':'','photo':'','fatherName':'','fatherBreed':'','fatherBirth':'','motherName':'','motherBreed':'','motherBirth':'','vaccines':[],'dewormings':[],'appointments':[],'healthBook':'','passport':''};

class RabbitPage extends StatefulWidget{final int index;const RabbitPage({super.key,required this.index});@override State<RabbitPage> createState()=>_RabbitPageState();}
class _RabbitPageState extends State<RabbitPage>{
  List<Map<String,dynamic>> all=[]; List<Map<String,dynamic>> breedings=[]; Map<String,dynamic>? r; final picker=ImagePicker();
  @override void initState(){super.initState();load();}
  Future<void> load()async{all=await Store.load();r=all[widget.index];breedings=await ReproductionStore.load();if(mounted)setState((){});}
  Future<void> refreshBreedings()async{breedings=await ReproductionStore.load();if(mounted)setState((){});}
  Future<void> persist()async{all[widget.index]=r!;await Store.save(all);if(mounted)setState((){});}
  Future<String> pickSquareRabbitPhoto()async{
    final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:100);
    if(x==null)return '';
    final bytes=await File(x.path).readAsBytes();
    if(!mounted)return '';
    final cropped=await Navigator.push<Uint8List>(context,MaterialPageRoute(builder:(_)=>SquareCropPage(image:bytes)));
    if(cropped==null)return '';
    return PrivateFiles.saveBytes(cropped,'rabbit_photos',extension:'.jpg');
  }

  Future<void> replaceRabbitPhoto()async{
    final saved=await pickSquareRabbitPhoto();
    if(saved.isEmpty)return;
    final old=(r!['photo']??'') as String;
    r!['photo']=saved;
    await persist();
    await PrivateFiles.deleteFile(old);
  }

  Future<void> removeRabbitPhoto()async{
    final old=(r!['photo']??'') as String;
    if(old.isEmpty)return;
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer la photo ?'),
      content:const Text('La copie enregistrée dans le carnet sera supprimée. La photo originale de votre bibliothèque ne sera jamais supprimée.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    r!['photo']='';
    await persist();
    await PrivateFiles.deleteFile(old);
  }

  Future<void> showRabbitPhoto()async{
    final p=(r!['photo']??'') as String;
    if(p.isEmpty){await replaceRabbitPhoto();return;}
    if(!mounted)return;
    await showDialog(context:context,builder:(dialogContext)=>Dialog.fullscreen(child:Scaffold(
      backgroundColor:Colors.black,
      appBar:AppBar(
        backgroundColor:ink,foregroundColor:gold,title:const Text('Photo du lapin'),
        actions:[
          IconButton(tooltip:'Remplacer',onPressed:()async{Navigator.pop(dialogContext);await replaceRabbitPhoto();},icon:const Icon(Icons.photo_camera_back_outlined)),
          IconButton(tooltip:'Supprimer',onPressed:()async{Navigator.pop(dialogContext);await removeRabbitPhoto();},icon:const Icon(Icons.delete_outline)),
        ],
      ),
      body:Center(child:InteractiveViewer(minScale:.5,maxScale:5,child:Image.file(File(p),fit:BoxFit.contain))),
    )));
  }
  Future<void> editIdentity()async{
    final data=Map<String,dynamic>.from(r!);
    await showDialog(context:context,builder:(ctx)=>EditIdentity(data:data,onSave:(v)async{
      r=v;
      await persist();
      await Notifications.refreshAll([r!]);
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> addTreatment(String key,String title)async{
    final item={
      'date':'','product':'','photo':'',
      'reminderMonths':0,'reminderDays':[0],'recurring':true,
      'notificationKey':'t_${DateTime.now().microsecondsSinceEpoch}',
    };
    await showDialog(context:context,builder:(ctx)=>TreatmentDialog(title:title,item:item,onSave:(v)async{
      (r![key] as List).add(v);
      await persist();
      await Notifications.scheduleTreatment(
        rabbitName:(r!['name']??'Lapin') as String,
        kind:key=='vaccines'?'vaccin':'vermifuge',
        item:v,
      );
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> editTreatment(String key,int index,String title)async{
    final list=r![key] as List;
    final current=Map<String,dynamic>.from(list[index]);
    await showDialog(context:context,builder:(ctx)=>TreatmentDialog(title:title,item:current,onSave:(v)async{
      await Notifications.cancelToken((current['notificationKey']??'') as String);
      list[index]=v;
      await persist();
      await Notifications.scheduleTreatment(
        rabbitName:(r!['name']??'Lapin') as String,
        kind:key=='vaccines'?'vaccin':'vermifuge',
        item:v,
      );
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> removeTreatment(String key,int index)async{
    final list=r![key] as List;
    final item=Map<String,dynamic>.from(list[index]);
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer cet enregistrement ?'),
      content:const Text('Le rappel associé et la copie interne de la photo seront également supprimés.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    list.removeAt(index);
    await persist();
    await Notifications.cancelToken((item['notificationKey']??'') as String);
    await PrivateFiles.deleteFile((item['photo']??'') as String);
  }

  Future<void> addAppointment()async{
    final item={
      'date':'','time':'09:00','vet':'','reason':'','description':'',
      'reminderDays':[1],
      'notificationKey':'a_${DateTime.now().microsecondsSinceEpoch}',
    };
    await showDialog(context:context,builder:(ctx)=>AppointmentDialog(item:item,onSave:(v)async{
      (r!['appointments'] as List).add(v);
      await persist();
      await Notifications.scheduleAppointment(rabbitName:(r!['name']??'Lapin') as String,item:v);
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> editAppointment(Map<String,dynamic> appointment)async{
    final list=r!['appointments'] as List;
    final index=list.indexOf(appointment);
    if(index<0)return;
    final current=Map<String,dynamic>.from(appointment);
    await showDialog(context:context,builder:(ctx)=>AppointmentDialog(item:current,onSave:(v)async{
      await Notifications.cancelToken((current['notificationKey']??'') as String);
      list[index]=v;
      await persist();
      await Notifications.scheduleAppointment(rabbitName:(r!['name']??'Lapin') as String,item:v);
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> removeAppointment(Map<String,dynamic> appointment)async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer ce rendez-vous ?'),
      content:const Text('La notification associée sera également supprimée.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    (r!['appointments'] as List).remove(appointment);
    await persist();
    await Notifications.cancelToken((appointment['notificationKey']??'') as String);
  }
  String rabbitNameById(String id){
    final match=all.where((x)=>x['id']==id);
    if(match.isEmpty)return 'Lapin non trouvé';
    final name=((match.first['name']??'') as String).trim();
    return name.isEmpty?'Lapin sans nom':name;
  }

  Future<void> addBreeding()async{
    final sex=(r!['sex']??'') as String;
    if(sex!='Mâle'&&sex!='Femelle')return;
    final partners=all.where((x)=>x['id']!=r!['id']&&x['sex']==(sex=='Mâle'?'Femelle':'Mâle')).toList();
    if(partners.isEmpty){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Ajoutez d’abord ${sex=='Mâle'?'une femelle':'un mâle'} dans le carnet.')));
      return;
    }
    final rec=<String,dynamic>{
      'id':'b_${DateTime.now().microsecondsSinceEpoch}',
      'maleId':sex=='Mâle'?r!['id']:'',
      'femaleId':sex=='Femelle'?r!['id']:'',
      'matingDate':'','birthDate':'','weaningDate':'',
      'liveMaleBirth':0,'liveFemaleBirth':0,'deadMaleBirth':0,'deadFemaleBirth':0,
      'liveMaleWeaning':0,'liveFemaleWeaning':0,
    };
    await showDialog(context:context,builder:(ctx)=>BreedingDialog(
      currentRabbit:r!,allRabbits:all,record:rec,
      onSave:(v)async{await ReproductionStore.upsert(v);await refreshBreedings();if(ctx.mounted)Navigator.pop(ctx);}
    ));
  }

  Future<void> editBreeding(Map<String,dynamic> record)async{
    await showDialog(context:context,builder:(ctx)=>BreedingDialog(
      currentRabbit:r!,allRabbits:all,record:Map<String,dynamic>.from(record),
      onSave:(v)async{await ReproductionStore.upsert(v);await refreshBreedings();if(ctx.mounted)Navigator.pop(ctx);}
    ));
  }

  Future<void> deleteBreeding(Map<String,dynamic> record)async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer cette saillie ?'),
      content:const Text('Elle disparaîtra automatiquement de la fiche du mâle et de la femelle.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    await ReproductionStore.remove((record['id']??'') as String);
    await refreshBreedings();
  }

  Future<void> attach(String key)async{
    final res=await FilePicker.platform.pickFiles(type:FileType.any);
    final source=res?.files.single.path;
    if(source!=null){
      final old=(r![key]??'') as String;
      final saved=await PrivateFiles.importFile(source,'documents');
      if(saved.isNotEmpty){r![key]=saved;await persist();await PrivateFiles.deleteFile(old);}
    }
  }
  Future<void> viewDocument(String key,String label)async{
    final p=(r![key]??'') as String;
    if(p.isEmpty)return;
    if(PrivateFiles.isImage(p)){
      if(!mounted)return;
      await showDialog(context:context,builder:(dialogContext)=>Dialog.fullscreen(child:Scaffold(
        backgroundColor:Colors.black,
        appBar:AppBar(
          backgroundColor:ink,foregroundColor:gold,title:Text(label),
          actions:[
            IconButton(tooltip:'Remplacer',onPressed:()async{Navigator.pop(dialogContext);await attach(key);},icon:const Icon(Icons.swap_horiz)),
            IconButton(tooltip:'Supprimer',onPressed:()async{Navigator.pop(dialogContext);await removeDocument(key);},icon:const Icon(Icons.delete_outline)),
          ],
        ),
        body:Center(child:InteractiveViewer(minScale:.5,maxScale:6,child:Image.file(File(p),fit:BoxFit.contain))),
      )));
    }else{
      await OpenFilex.open(p);
    }
  }

  Future<void> removeDocument(String key)async{
    final p=(r![key]??'') as String;
    if(p.isEmpty)return;
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Supprimer ce document ?'),content:const Text('La copie enregistrée dans le carnet sera supprimée. Le fichier original ne sera pas touché.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))]))??false;
    if(ok){await PrivateFiles.deleteFile(p);r![key]='';await persist();}
  }
  Future<void> share()async{
    final rr=r!; final text="Carnet de santé – Les Lapibreizh\n\n${rr['name']}\nSexe : ${rr['sex']}\nRace : ${rr['breed']}\nNaissance : ${rr['birth']}\nSevrage : ${rr['weaning']}\n\nPère : ${rr['fatherName']} – ${rr['fatherBreed']} – ${rr['fatherBirth']}\nMère : ${rr['motherName']} – ${rr['motherBreed']} – ${rr['motherBirth']}\n\nVaccins :\n${lines(rr['vaccines'])}\n\nVermifuges :\n${lines(rr['dewormings'])}";
    final paths=<String>[]; for(final k in ['photo','healthBook','passport']){final p=rr[k];if(p is String&&p.isNotEmpty&&File(p).existsSync())paths.add(p);} for(final k in ['vaccines','dewormings']){for(final x in rr[k] as List){final p=x['photo'];if(p is String&&p.isNotEmpty&&File(p).existsSync())paths.add(p);}}
    if(paths.isEmpty){await Share.share(text,subject:'Carnet de santé de ${rr['name']}');}else{await Share.shareXFiles(paths.map((p)=>XFile(p)).toList(),text:text,subject:'Carnet de santé de ${rr['name']}');}
  }
  String lines(dynamic l){final x=l as List;if(x.isEmpty)return 'Aucun enregistrement';return x.map((e)=>'• ${e['date']} — ${e['product']}').join('\n');}
  Future<void> deleteRabbit()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Supprimer cette fiche ?'),content:const Text('Cette action retire la fiche du carnet.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))]))??false;if(ok){
    final doomed=Map<String,dynamic>.from(r!);
    await Notifications.cancelRabbit(doomed);
    await ReproductionStore.removeRabbit((doomed['id']??'') as String);
    for(final k in ['photo','healthBook','passport']){await PrivateFiles.deleteFile((doomed[k]??'') as String);}
    for(final k in ['vaccines','dewormings']){for(final x in doomed[k] as List){await PrivateFiles.deleteFile((x['photo']??'') as String);}}
    all.removeAt(widget.index);await Store.save(all);if(mounted)Navigator.pop(context);
  }}
  @override Widget build(BuildContext context){if(r==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));final rr=r!;return Scaffold(
    body:Scenic(compact:true,child:SafeArea(child:CustomScrollView(slivers:[
      SliverAppBar(backgroundColor:ink.withValues(alpha:.94),foregroundColor:gold,pinned:true,title:Text(rr['name'].isEmpty?'Fiche du lapin':rr['name']),actions:[IconButton(onPressed:share,icon:const Icon(Icons.share)),PopupMenuButton<String>(onSelected:(v){if(v=='delete')deleteRabbit();},itemBuilder:(_)=>const [PopupMenuItem(value:'delete',child:Text('Supprimer la fiche'))])]),
      SliverPadding(padding:const EdgeInsets.fromLTRB(14,16,14,40),sliver:SliverList.list(children:[
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[GestureDetector(onTap:showRabbitPhoto,child:Hero(tag:'rabbit${widget.index}',child:Container(width:180,height:180,decoration:BoxDecoration(color:gold.withValues(alpha:.18),borderRadius:BorderRadius.circular(22),border:Border.all(color:gold,width:3),boxShadow:const [BoxShadow(blurRadius:14,color:Colors.black26)]),clipBehavior:Clip.antiAlias,child:rr['photo'].isEmpty?const Icon(Icons.add_a_photo,size:48,color:ink):Image.file(File(rr['photo']),fit:BoxFit.cover)))),const SizedBox(height:8),Wrap(alignment:WrapAlignment.center,spacing:8,children:[
          OutlinedButton.icon(onPressed:replaceRabbitPhoto,icon:const Icon(Icons.crop),label:Text(rr['photo'].isEmpty?'Choisir et cadrer':'Remplacer / recadrer')),
          if(rr['photo'].isNotEmpty)IconButton(tooltip:'Supprimer la photo',onPressed:removeRabbitPhoto,icon:const Icon(Icons.delete_outline,color:Colors.redAccent)),
        ]),const SizedBox(height:12),Text(rr['name'].isEmpty?'Nom à renseigner':rr['name'],style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:ink)),if(rr['breed'].isNotEmpty)Text(rr['breed'],style:const TextStyle(fontSize:16,color:brown)),const SizedBox(height:12),FilledButton.icon(onPressed:editIdentity,icon:const Icon(Icons.edit),label:const Text('Identité & filiation'))]))),
        section('Identité',Icons.badge,[info('Sexe',rr['sex']),info('Statut',rr['sterilized']),info('Naissance',rr['birth']),info('Sevrage',rr['weaning']),info('Race',rr['breed'])]),
        section('Filiation',Icons.account_tree,[info('Père',rr['fatherName']),info('Race du père',rr['fatherBreed']),info('Naissance du père',rr['fatherBirth']),const Divider(),info('Mère',rr['motherName']),info('Race de la mère',rr['motherBreed']),info('Naissance de la mère',rr['motherBirth'])]),
        if(rr['sex']=='Mâle'||rr['sex']=='Femelle') reproductionSection(),
        treatmentSection('Vaccins','vaccines',Icons.vaccines), treatmentSection('Vermifuges','dewormings',Icons.medication),
        appointmentSection(),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header('Documents',Icons.folder_copy),docButton('Carnet de santé','healthBook'),const SizedBox(height:8),docButton('Passeport','passport')]))),
        const SizedBox(height:12),FilledButton.icon(onPressed:share,icon:const Icon(Icons.share),label:const Text('Partager la fiche complète')),
      ]))
    ]))),
  );}
  Widget header(String t,IconData i)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[Icon(i,color:brown),const SizedBox(width:8),Text(t,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w800,color:ink))]));
  Widget section(String t,IconData i,List<Widget> ch)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header(t,i),...ch])));
  Widget info(String a,dynamic b)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:145,child:Text(a,style:const TextStyle(fontWeight:FontWeight.w600,color:brown))),Expanded(child:Text((b??'').toString().isEmpty?'—':b.toString()))]));
  DateTime? _reproDate(String? s)=>Notifications.parseDate(s);

  Widget _profileBubble(String label,String value,Color color){
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:11,vertical:9),
      decoration:BoxDecoration(
        color:color.withValues(alpha:.12),
        borderRadius:BorderRadius.circular(18),
        border:Border.all(color:color.withValues(alpha:.70),width:1.4),
      ),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(label,style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:color)),
        const SizedBox(height:2),
        Text(value,style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:color)),
      ]),
    );
  }

  Widget _reproductionProfile(List<Map<String,dynamic>> records){
    final p=ReproductionStore.sexProfile(records);
    final sums=ReproductionStore.aggregate(records);
    final sexed=ReproductionStore.n(sums['liveMaleBirth'])+
        ReproductionStore.n(sums['deadMaleBirth'])+
        ReproductionStore.n(sums['liveFemaleBirth'])+
        ReproductionStore.n(sums['deadFemaleBirth']);
    if(sexed==0){
      return Container(
        padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(color:Colors.white70,borderRadius:BorderRadius.circular(16)),
        child:const Text('Les indicateurs apparaîtront dès que des lapereaux mâles ou femelles seront renseignés.',style:TextStyle(color:Colors.black54)),
      );
    }
    final female='${(p['female']??0).round()} %';
    final balance='${(p['balance']??0).round()} %';
    final male='${(p['male']??0).round()} %';
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Text('Profil cumulé de toutes les portées liées',style:TextStyle(fontWeight:FontWeight.w800,color:brown)),
      const SizedBox(height:9),
      Wrap(spacing:8,runSpacing:8,children:[
        _profileBubble('Femelles',female,const Color(0xFF2E7D32)),
        _profileBubble('Équilibre',balance,const Color(0xFF1565C0)),
        _profileBubble('Mâles',male,const Color(0xFFEF6C00)),
      ]),
      const SizedBox(height:7),
      Text('$sexed lapereaux sexés pris en compte • ${records.length} ${records.length>1?'portées liées':'portée liée'}',style:const TextStyle(fontSize:12,color:Colors.black54)),
    ]);
  }

  Widget _chartRow({required String label,required int male,required int female,required Color color,required int maxValue}){
    final value=male+female;
    final factor=maxValue<=0?0.0:value/maxValue;
    return Padding(
      padding:const EdgeInsets.only(bottom:11),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Expanded(child:Text(label,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700))),
          Text('$value',style:TextStyle(fontSize:14,fontWeight:FontWeight.w900,color:color)),
        ]),
        const SizedBox(height:5),
        Container(
          height:12,
          decoration:BoxDecoration(color:Colors.black.withValues(alpha:.07),borderRadius:BorderRadius.circular(20)),
          clipBehavior:Clip.antiAlias,
          child:Align(
            alignment:Alignment.centerLeft,
            child:FractionallySizedBox(
              widthFactor:factor,
              heightFactor:1,
              child:Container(decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(20))),
            ),
          ),
        ),
        const SizedBox(height:3),
        Text('♂ $male   •   ♀ $female',style:const TextStyle(fontSize:11,color:Colors.black54)),
      ]),
    );
  }

  Widget _breedingChart(Map<String,dynamic> data,{bool cumulative=false}){
    final liveMale=ReproductionStore.n(data['liveMaleBirth']);
    final liveFemale=ReproductionStore.n(data['liveFemaleBirth']);
    final deadMale=ReproductionStore.n(data['deadMaleBirth']);
    final deadFemale=ReproductionStore.n(data['deadFemaleBirth']);
    final weanedMale=ReproductionStore.n(data['liveMaleWeaning']);
    final weanedFemale=ReproductionStore.n(data['liveFemaleWeaning']);
    final lossMale=liveMale>weanedMale?liveMale-weanedMale:0;
    final lossFemale=liveFemale>weanedFemale?liveFemale-weanedFemale:0;
    final values=[liveMale+liveFemale,deadMale+deadFemale,weanedMale+weanedFemale,lossMale+lossFemale];
    final maxValue=values.fold<int>(1,(m,v)=>v>m?v:m);
    return Container(
      padding:const EdgeInsets.fromLTRB(12,12,12,2),
      decoration:BoxDecoration(
        color:Colors.white.withValues(alpha:.72),
        borderRadius:BorderRadius.circular(14),
        border:Border.all(color:gold.withValues(alpha:.42)),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text(cumulative?'Graphique cumulé':'Résultats de la portée',style:const TextStyle(fontWeight:FontWeight.w800,color:ink)),
        const SizedBox(height:10),
        _chartRow(label:'Vivants à la naissance',male:liveMale,female:liveFemale,color:const Color(0xFF2E7D32),maxValue:maxValue),
        _chartRow(label:'Morts à la naissance',male:deadMale,female:deadFemale,color:const Color(0xFFEF6C00),maxValue:maxValue),
        _chartRow(label:'Vivants au sevrage',male:weanedMale,female:weanedFemale,color:const Color(0xFF1565C0),maxValue:maxValue),
        _chartRow(label:'Pertes avant sevrage',male:lossMale,female:lossFemale,color:const Color(0xFF8D6E63),maxValue:maxValue),
      ]),
    );
  }

  Widget reproductionSection(){
    final id=(r!['id']??'') as String;
    final records=breedings.where((b)=>b['maleId']==id||b['femaleId']==id).toList();
    records.sort((a,b){
      final ad=_reproDate(a['matingDate'] as String?)??DateTime(1900);
      final bd=_reproDate(b['matingDate'] as String?)??DateTime(1900);
      return bd.compareTo(ad);
    });
    final sex=(r!['sex']??'') as String;
    final cumulative=ReproductionStore.aggregate(records);
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      header(sex=='Mâle'?'Reproduction / Saillies':'Reproduction / Portées',Icons.favorite),
      _reproductionProfile(records),
      if(records.isNotEmpty)...[
        const SizedBox(height:14),
        _breedingChart(cumulative,cumulative:true),
        const SizedBox(height:16),
      ],
      if(records.isEmpty)Padding(padding:const EdgeInsets.only(top:12,bottom:10),child:Text(sex=='Mâle'?'Aucune saillie enregistrée.':'Aucune portée enregistrée.',style:const TextStyle(color:Colors.black54))),
      ...records.map((b){
        final t=ReproductionStore.totals(b);
        final partner=sex=='Mâle'?rabbitNameById((b['femaleId']??'') as String):rabbitNameById((b['maleId']??'') as String);
        return Container(
          margin:const EdgeInsets.only(bottom:12),
          decoration:BoxDecoration(color:gold.withValues(alpha:.09),borderRadius:BorderRadius.circular(16),border:Border.all(color:gold.withValues(alpha:.65))),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            ListTile(
              onTap:()=>editBreeding(b),
              title:Text('${b['matingDate']?.toString().isEmpty==false?b['matingDate']:'Date à compléter'} • $partner',style:const TextStyle(fontWeight:FontWeight.bold)),
              subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                if(((b['birthDate']??'') as String).isNotEmpty)Text('Naissance : ${b['birthDate']}'),
                Text('Nés : ${t['born']} • vivants : ${t['liveBirth']} • morts : ${t['deadBirth']}'),
                Text('Mâles : ${t['maleTotal']} • femelles : ${t['femaleTotal']}'),
                if(((b['weaningDate']??'') as String).isNotEmpty)Text('Sevrage : ${b['weaningDate']} • vivants : ${t['weaned']}'),
              ]),
              trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>deleteBreeding(b)),
            ),
            Padding(padding:const EdgeInsets.fromLTRB(10,0,10,10),child:_breedingChart(b)),
          ]),
        );
      }),
      OutlinedButton.icon(onPressed:addBreeding,icon:const Icon(Icons.add),label:Text(sex=='Mâle'?'Ajouter une saillie':'Ajouter une portée / saillie')),
    ])));
  }

  String reminderLabel(Map<String,dynamic> item){
    final months=(item['reminderMonths']??0) as int;
    if(months<=0)return '';
    final d=Notifications.parseDate(item['date'] as String?);
    if(d==null)return '';
    var due=Notifications.addMonths(d,months);
    while(due.isBefore(DateTime.now()))due=Notifications.addMonths(due,months);
    final recurring=(item['recurring']??true) as bool;
    return 'Prochain rappel : ${Notifications.formatDate(due)}${recurring?' • récurrent':''}';
  }

  Widget treatmentSection(String title,String key,IconData icon){
    final list=r![key] as List;
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      header(title,icon),
      if(list.isEmpty)const Padding(padding:EdgeInsets.only(bottom:10),child:Text('Aucun enregistrement.',style:TextStyle(color:Colors.black54))),
      ...list.asMap().entries.map((e){
        final item=Map<String,dynamic>.from(e.value);
        final reminder=reminderLabel(item);
        return ListTile(
          contentPadding:EdgeInsets.zero,
          onTap:()=>editTreatment(key,e.key,title.substring(0,title.length-1)),
          leading:CircleAvatar(backgroundColor:gold.withValues(alpha:.25),backgroundImage:fileImage(item['photo']),child:(item['photo']??'').isEmpty?Icon(icon,color:brown):null),
          title:Text(item['product']?.isEmpty==false?item['product']:'Produit non renseigné',style:const TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(item['date']??''),
            if(reminder.isNotEmpty)Text(reminder,style:const TextStyle(color:brown,fontWeight:FontWeight.w600)),
          ]),
          trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>removeTreatment(key,e.key)),
        );
      }),
      OutlinedButton.icon(onPressed:()=>addTreatment(key,title.substring(0,title.length-1)),icon:const Icon(Icons.add),label:Text('Ajouter ${title.toLowerCase()}')),
    ])));
  }

  DateTime? appointmentDate(Map<String,dynamic> a){
    final d=Notifications.parseDate(a['date'] as String?);
    if(d==null)return null;
    final parts=((a['time']??'09:00') as String).split(':');
    return DateTime(d.year,d.month,d.day,int.tryParse(parts[0])??9,parts.length>1?int.tryParse(parts[1])??0:0);
  }

  Widget appointmentSection(){
    final source=((r!['appointments'] as List?)??[]);
    final items=source.map((e)=>e as Map<String,dynamic>).toList();
    final now=DateTime.now();
    final upcoming=items.where((a){final d=appointmentDate(a);return d!=null&&d.isAfter(now);}).toList()
      ..sort((a,b)=>appointmentDate(a)!.compareTo(appointmentDate(b)!));
    final past=items.where((a){final d=appointmentDate(a);return d!=null&&!d.isAfter(now);}).toList()
      ..sort((a,b)=>appointmentDate(b)!.compareTo(appointmentDate(a)!));

    Widget tile(Map<String,dynamic> a,{bool next=false})=>Container(
      margin:const EdgeInsets.only(bottom:8),
      decoration:next?BoxDecoration(color:gold.withValues(alpha:.13),borderRadius:BorderRadius.circular(14),border:Border.all(color:gold)):null,
      child:ListTile(
        onTap:()=>editAppointment(a),
        leading:Icon(next?Icons.event_available:Icons.event_note,color:brown),
        title:Text('${a['date']??''} • ${a['time']??''}',style:TextStyle(fontWeight:FontWeight.bold,color:next?ink:null)),
        subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          if(((a['reason']??'') as String).isNotEmpty)Text(a['reason']),
          if(((a['vet']??'') as String).isNotEmpty)Text(a['vet'],style:const TextStyle(color:Colors.black54)),
          if(((a['description']??'') as String).isNotEmpty)Text(a['description'],maxLines:2,overflow:TextOverflow.ellipsis),
        ]),
        trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>removeAppointment(a)),
      ),
    );

    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      header('Rendez-vous vétérinaire',Icons.local_hospital),
      if(upcoming.isNotEmpty)...[
        const Text('Prochain rendez-vous',style:TextStyle(fontWeight:FontWeight.bold,color:brown)),
        const SizedBox(height:6),
        tile(upcoming.first,next:true),
      ],
      if(upcoming.length>1)...[
        const SizedBox(height:6),
        const Text('À venir',style:TextStyle(fontWeight:FontWeight.bold)),
        ...upcoming.skip(1).map((a)=>tile(a)),
      ],
      if(past.isNotEmpty)...[
        const SizedBox(height:8),
        const Divider(),
        const Text('Historique',style:TextStyle(fontWeight:FontWeight.bold)),
        ...past.map((a)=>tile(a)),
      ],
      if(items.isEmpty)const Padding(padding:EdgeInsets.only(bottom:10),child:Text('Aucun rendez-vous enregistré.',style:TextStyle(color:Colors.black54))),
      OutlinedButton.icon(onPressed:addAppointment,icon:const Icon(Icons.add),label:const Text('Ajouter un rendez-vous')),
    ])));
  }

  Widget docButton(String label,String key){
    final p=(r![key]??'') as String;
    if(p.isEmpty){
      return OutlinedButton.icon(onPressed:()=>attach(key),icon:const Icon(Icons.attach_file,color:brown),label:Text('Ajouter $label'));
    }
    final image=PrivateFiles.isImage(p);
    return Container(
      padding:const EdgeInsets.all(10),
      decoration:BoxDecoration(color:Colors.white.withValues(alpha:.70),borderRadius:BorderRadius.circular(16),border:Border.all(color:gold.withValues(alpha:.65))),
      child:Row(children:[
        InkWell(
          onTap:()=>viewDocument(key,label),
          borderRadius:BorderRadius.circular(12),
          child:Container(
            width:92,height:118,
            decoration:BoxDecoration(color:ivory,borderRadius:BorderRadius.circular(12),border:Border.all(color:gold)),
            clipBehavior:Clip.antiAlias,
            child:image?Image.file(File(p),fit:BoxFit.contain):const Icon(Icons.description,size:48,color:brown),
          ),
        ),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(label,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold,color:ink)),
          const SizedBox(height:5),
          Text(image?'Appuyez sur la miniature pour l’agrandir.':'Appuyez pour ouvrir le document.',style:const TextStyle(color:Colors.black54)),
          const SizedBox(height:8),
          Wrap(spacing:6,children:[
            TextButton.icon(onPressed:()=>viewDocument(key,label),icon:const Icon(Icons.visibility),label:const Text('Voir')),
            TextButton.icon(onPressed:()=>attach(key),icon:const Icon(Icons.swap_horiz),label:const Text('Remplacer')),
            IconButton(tooltip:'Supprimer',onPressed:()=>removeDocument(key),icon:const Icon(Icons.delete_outline,color:Colors.redAccent)),
          ]),
        ])),
      ]),
    );
  }
}


class SquareCropPage extends StatefulWidget{
  final Uint8List image;
  const SquareCropPage({super.key,required this.image});
  @override State<SquareCropPage> createState()=>_SquareCropPageState();
}

class _SquareCropPageState extends State<SquareCropPage>{
  final controller=CropController();
  bool cropping=false;

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:Colors.black,
    appBar:AppBar(
      backgroundColor:ink,foregroundColor:gold,title:const Text('Cadrer la photo'),
      actions:[TextButton(
        onPressed:cropping?null:(){setState(()=>cropping=true);controller.crop();},
        child:const Text('VALIDER',style:TextStyle(color:gold,fontWeight:FontWeight.bold)),
      )],
    ),
    body:Column(children:[
      const Padding(
        padding:EdgeInsets.all(12),
        child:Text('Déplacez et zoomez la photo dans le carré.',style:TextStyle(color:Colors.white,fontSize:16)),
      ),
      Expanded(child:Crop(
        image:widget.image,
        controller:controller,
        aspectRatio:1,
        initialRectBuilder:InitialRectBuilder.withSizeAndRatio(size:.92,aspectRatio:1),
        interactive:true,
        fixCropRect:true,
        baseColor:Colors.black,
        maskColor:Colors.black54,
        radius:0,
        filterQuality:FilterQuality.high,
        progressIndicator:const Center(child:CircularProgressIndicator()),
        onCropped:(result){
          if(result is CropSuccess){
            Navigator.pop(context,result.croppedImage);
          }else{
            if(mounted){
              setState(()=>cropping=false);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Impossible de recadrer cette image.')));
            }
          }
        },
      )),
    ]),
  );
}

class EditIdentity extends StatefulWidget{
  final Map<String,dynamic> data;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const EditIdentity({super.key,required this.data,required this.onSave});
  @override State<EditIdentity> createState()=>_EditIdentityState();
}
class _EditIdentityState extends State<EditIdentity>{
  late Map<String,dynamic>d;
  @override void initState(){super.initState();d=Map<String,dynamic>.from(widget.data);d['sterilized']??='';}

  @override Widget build(BuildContext context)=>Dialog.fullscreen(child:Scaffold(
    appBar:AppBar(title:const Text('Identité & filiation'),actions:[TextButton(onPressed:()=>widget.onSave(d),child:const Text('ENREGISTRER'))]),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      const Text('Le lapin',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      field('Nom','name'),
      const SizedBox(height:14),
      choiceTitle('Sexe'),
      Wrap(spacing:10,runSpacing:8,children:[
        ChoiceChip(label:const Text('Mâle'),selected:d['sex']=='Mâle',onSelected:(_)=>setState(()=>d['sex']='Mâle')),
        ChoiceChip(label:const Text('Femelle'),selected:d['sex']=='Femelle',onSelected:(_)=>setState(()=>d['sex']='Femelle')),
      ]),
      const SizedBox(height:14),
      choiceTitle('Stérilisation'),
      Wrap(spacing:10,runSpacing:8,children:[
        ChoiceChip(label:const Text('Stérilisé(e)'),selected:d['sterilized']=='Stérilisé(e)',onSelected:(_)=>setState(()=>d['sterilized']='Stérilisé(e)')),
        ChoiceChip(label:const Text('Non stérilisé(e)'),selected:d['sterilized']=='Non stérilisé(e)',onSelected:(_)=>setState(()=>d['sterilized']='Non stérilisé(e)')),
      ]),
      field('Race','breed'),
      dateField('Date de naissance','birth'),
      dateField('Date de sevrage','weaning'),
      const SizedBox(height:20),
      const Text('Père',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      field('Nom du père','fatherName'),field('Race du père','fatherBreed'),dateField('Date de naissance du père','fatherBirth'),
      const SizedBox(height:20),
      const Text('Mère',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      field('Nom de la mère','motherName'),field('Race de la mère','motherBreed'),dateField('Date de naissance de la mère','motherBirth'),
    ]),
  ));

  Widget choiceTitle(String label)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Text(label,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:brown)));
  Widget field(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(initialValue:d[key]??'',decoration:InputDecoration(labelText:label),onChanged:(v)=>d[key]=v));
  Widget dateField(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(
    readOnly:true,controller:TextEditingController(text:d[key]??''),decoration:InputDecoration(labelText:label,suffixIcon:const Icon(Icons.calendar_month)),
    onTap:()async{final x=await showDatePicker(context:context,firstDate:DateTime(1990),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:Notifications.parseDate(d[key])??DateTime.now());if(x!=null)setState(()=>d[key]=Notifications.formatDate(x));},
  ));
}

class BreedingDialog extends StatefulWidget{
  final Map<String,dynamic> currentRabbit;
  final List<Map<String,dynamic>> allRabbits;
  final Map<String,dynamic> record;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const BreedingDialog({super.key,required this.currentRabbit,required this.allRabbits,required this.record,required this.onSave});
  @override State<BreedingDialog> createState()=>_BreedingDialogState();
}

class _BreedingDialogState extends State<BreedingDialog>{
  late Map<String,dynamic>d;
  late bool currentIsMale;

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.record);
    currentIsMale=widget.currentRabbit['sex']=='Mâle';
    for(final k in ['liveMaleBirth','liveFemaleBirth','deadMaleBirth','deadFemaleBirth','liveMaleWeaning','liveFemaleWeaning']){d[k]=ReproductionStore.n(d[k]);}
  }

  List<Map<String,dynamic>> get partners=>widget.allRabbits.where((x)=>x['id']!=widget.currentRabbit['id']&&x['sex']==(currentIsMale?'Femelle':'Mâle')).toList();

  Future<void> pickDate(String key,String label)async{
    final current=Notifications.parseDate(d[key] as String?);
    final x=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime.now().add(const Duration(days:3650)),initialDate:current??DateTime.now());
    if(x!=null)setState(()=>d[key]=Notifications.formatDate(x));
  }

  Widget dateField(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(
    readOnly:true,controller:TextEditingController(text:d[key]??''),decoration:InputDecoration(labelText:label,suffixIcon:const Icon(Icons.calendar_month)),
    onTap:()=>pickDate(key,label),
  ));

  Widget countField(String label,String key)=>DropdownButtonFormField<int>(
    value:ReproductionStore.n(d[key]),
    decoration:InputDecoration(labelText:label),
    items:List.generate(16,(i)=>DropdownMenuItem(value:i,child:Text('$i'))),
    onChanged:(v)=>setState(()=>d[key]=v??0),
  );

  @override Widget build(BuildContext context){
    final partnerKey=currentIsMale?'femaleId':'maleId';
    final currentPartner=(d[partnerKey]??'') as String;
    return Dialog.fullscreen(child:Scaffold(
      appBar:AppBar(
        title:Text(currentIsMale?'Saillie du mâle':'Saillie / portée de la femelle'),
        actions:[TextButton(onPressed:(){
          if(((d['matingDate']??'') as String).isEmpty||((d[partnerKey]??'') as String).isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez la date de saillie et le partenaire.')));
            return;
          }
          if(currentIsMale){d['maleId']=widget.currentRabbit['id'];}else{d['femaleId']=widget.currentRabbit['id'];}
          widget.onSave(d);
        },child:const Text('ENREGISTRER'))],
      ),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        dateField('Date de la saillie','matingDate'),
        const SizedBox(height:10),
        DropdownButtonFormField<String>(
          value:partners.any((p)=>p['id']==currentPartner)?currentPartner:null,
          decoration:InputDecoration(labelText:currentIsMale?'Femelle saillie':'Mâle'),
          items:partners.map((p)=>DropdownMenuItem<String>(value:p['id'] as String,child:Text(((p['name']??'') as String).isEmpty?'Lapin sans nom':p['name']))).toList(),
          onChanged:(v)=>setState(()=>d[partnerKey]=v??''),
        ),
        dateField('Date de naissance des lapereaux','birthDate'),
        const SizedBox(height:22),
        const Text('À la naissance',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        const SizedBox(height:10),
        countField('Mâles vivants','liveMaleBirth'),
        const SizedBox(height:10),
        countField('Femelles vivantes','liveFemaleBirth'),
        const SizedBox(height:10),
        countField('Mâles morts','deadMaleBirth'),
        const SizedBox(height:10),
        countField('Femelles mortes','deadFemaleBirth'),
        const SizedBox(height:22),
        const Text('Au sevrage',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        dateField('Date de sevrage','weaningDate'),
        const SizedBox(height:10),
        countField('Mâles vivants au sevrage','liveMaleWeaning'),
        const SizedBox(height:10),
        countField('Femelles vivantes au sevrage','liveFemaleWeaning'),
        const SizedBox(height:20),
        Builder(builder:(_){
          final t=ReproductionStore.totals(d);
          return Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Totaux calculés automatiquement',style:TextStyle(fontWeight:FontWeight.bold)),
            const SizedBox(height:6),
            Text('Total nés : ${t['born']}'),
            Text('Vivants à la naissance : ${t['liveBirth']}'),
            Text('Morts à la naissance : ${t['deadBirth']}'),
            Text('Mâles : ${t['maleTotal']} • Femelles : ${t['femaleTotal']}'),
            Text('Vivants au sevrage : ${t['weaned']}'),
          ])));
        }),
      ]),
    ));
  }
}

class TreatmentDialog extends StatefulWidget{
  final String title;
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const TreatmentDialog({super.key,required this.title,required this.item,required this.onSave});
  @override State<TreatmentDialog> createState()=>_TreatmentDialogState();
}

class _TreatmentDialogState extends State<TreatmentDialog>{
  late Map<String,dynamic>d;

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.item);
    d['reminderMonths']??=0;
    d['reminderDays']=List<int>.from((d['reminderDays'] as List?)??[0]);
    d['recurring']??=true;
    d['notificationKey']??='t_${DateTime.now().microsecondsSinceEpoch}';
  }

  void toggleDay(int value,bool selected){
    final days=List<int>.from(d['reminderDays'] as List);
    if(selected&&!days.contains(value))days.add(value);
    if(!selected)days.remove(value);
    days.sort((a,b)=>b.compareTo(a));
    setState(()=>d['reminderDays']=days);
  }

  @override Widget build(BuildContext context)=>AlertDialog(
    title:Text('${widget.item['date']?.toString().isEmpty==false?'Modifier':'Ajouter'} ${widget.title.toLowerCase()}'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      TextFormField(initialValue:d['product'],decoration:const InputDecoration(labelText:'Produit utilisé'),onChanged:(v)=>d['product']=v),
      const SizedBox(height:10),
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['date']??''),
        decoration:const InputDecoration(labelText:'Date',suffixIcon:Icon(Icons.calendar_month)),
        onTap:()async{
          final x=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:Notifications.parseDate(d['date'])??DateTime.now());
          if(x!=null)setState(()=>d['date']='${x.day.toString().padLeft(2,'0')}/${x.month.toString().padLeft(2,'0')}/${x.year}');
        },
      ),
      const SizedBox(height:12),
      DropdownButtonFormField<int>(
        value:d['reminderMonths'] as int,
        decoration:const InputDecoration(labelText:'Rappel'),
        items:const [
          DropdownMenuItem(value:0,child:Text('Aucun rappel')),
          DropdownMenuItem(value:3,child:Text('Tous les 3 mois')),
          DropdownMenuItem(value:6,child:Text('Tous les 6 mois')),
          DropdownMenuItem(value:12,child:Text('Tous les 1 an')),
        ],
        onChanged:(v)=>setState(()=>d['reminderMonths']=v??0),
      ),
      if((d['reminderMonths'] as int)>0)...[
        const SizedBox(height:10),
        const Text('Notifications',style:TextStyle(fontWeight:FontWeight.bold)),
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('1 semaine avant'),value:(d['reminderDays'] as List).contains(7),onChanged:(v)=>toggleDay(7,v??false)),
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('3 jours avant'),value:(d['reminderDays'] as List).contains(3),onChanged:(v)=>toggleDay(3,v??false)),
        CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('Le jour même'),value:(d['reminderDays'] as List).contains(0),onChanged:(v)=>toggleDay(0,v??false)),
        SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Récurrence permanente'),subtitle:const Text('Le rappel se renouvelle automatiquement.'),value:d['recurring'] as bool,onChanged:(v)=>setState(()=>d['recurring']=v)),
      ],
      const SizedBox(height:10),
      OutlinedButton.icon(
        onPressed:()async{
          final x=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:88);
          if(x!=null){
            final old=(d['photo']??'') as String;
            final saved=await PrivateFiles.importFile(x.path,'treatments');
            if(saved.isNotEmpty){
              setState(()=>d['photo']=saved);
              if(old.isNotEmpty&&old!=widget.item['photo'])await PrivateFiles.deleteFile(old);
            }
          }
        },
        icon:Icon(((d['photo']??'') as String).isEmpty?Icons.add_a_photo:Icons.check_circle),
        label:Text(((d['photo']??'') as String).isEmpty?'Ajouter la photo du produit':'Photo ajoutée / remplacer'),
      ),
    ])),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Annuler')),
      FilledButton(
        onPressed:(){
          if(((d['date']??'') as String).isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez une date.')));
            return;
          }
          widget.onSave(d);
        },
        child:const Text('Enregistrer'),
      ),
    ],
  );
}

class AppointmentDialog extends StatefulWidget{
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const AppointmentDialog({super.key,required this.item,required this.onSave});
  @override State<AppointmentDialog> createState()=>_AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog>{
  late Map<String,dynamic>d;

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.item);
    d['reminderDays']=List<int>.from((d['reminderDays'] as List?)??[1]);
    d['notificationKey']??='a_${DateTime.now().microsecondsSinceEpoch}';
    d['time']??='09:00';
  }

  void toggleDay(int value,bool selected){
    final days=List<int>.from(d['reminderDays'] as List);
    if(selected&&!days.contains(value))days.add(value);
    if(!selected)days.remove(value);
    days.sort((a,b)=>b.compareTo(a));
    setState(()=>d['reminderDays']=days);
  }

  @override Widget build(BuildContext context)=>Dialog.fullscreen(child:Scaffold(
    appBar:AppBar(
      title:Text(widget.item['date']?.toString().isEmpty==false?'Modifier le rendez-vous':'Nouveau rendez-vous'),
      actions:[TextButton(onPressed:(){
        if(((d['date']??'') as String).isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez une date.')));
          return;
        }
        widget.onSave(d);
      },child:const Text('ENREGISTRER'))],
    ),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['date']??''),
        decoration:const InputDecoration(labelText:'Date du rendez-vous',suffixIcon:Icon(Icons.calendar_month)),
        onTap:()async{
          final x=await showDatePicker(context:context,firstDate:DateTime.now().subtract(const Duration(days:3650)),lastDate:DateTime.now().add(const Duration(days:3650)),initialDate:Notifications.parseDate(d['date'])??DateTime.now());
          if(x!=null)setState(()=>d['date']='${x.day.toString().padLeft(2,'0')}/${x.month.toString().padLeft(2,'0')}/${x.year}');
        },
      ),
      const SizedBox(height:10),
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['time']??'09:00'),
        decoration:const InputDecoration(labelText:'Heure',suffixIcon:Icon(Icons.schedule)),
        onTap:()async{
          final p=((d['time']??'09:00') as String).split(':');
          final t=await showTimePicker(context:context,initialTime:TimeOfDay(hour:int.tryParse(p[0])??9,minute:p.length>1?int.tryParse(p[1])??0:0));
          if(t!=null)setState(()=>d['time']='${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}');
        },
      ),
      const SizedBox(height:10),
      TextFormField(initialValue:d['vet']??'',decoration:const InputDecoration(labelText:'Vétérinaire / clinique'),onChanged:(v)=>d['vet']=v),
      const SizedBox(height:10),
      TextFormField(initialValue:d['reason']??'',decoration:const InputDecoration(labelText:'Motif du rendez-vous'),onChanged:(v)=>d['reason']=v),
      const SizedBox(height:10),
      TextFormField(initialValue:d['description']??'',minLines:3,maxLines:6,decoration:const InputDecoration(labelText:'Description / notes'),onChanged:(v)=>d['description']=v),
      const SizedBox(height:18),
      const Text('Notifications',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const Text('Vous pouvez en choisir plusieurs.',style:TextStyle(color:Colors.black54)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('1 semaine avant'),value:(d['reminderDays'] as List).contains(7),onChanged:(v)=>toggleDay(7,v??false)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('3 jours avant'),value:(d['reminderDays'] as List).contains(3),onChanged:(v)=>toggleDay(3,v??false)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('La veille'),value:(d['reminderDays'] as List).contains(1),onChanged:(v)=>toggleDay(1,v??false)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('Le jour même'),value:(d['reminderDays'] as List).contains(0),onChanged:(v)=>toggleDay(0,v??false)),
    ]),
  ));
}
