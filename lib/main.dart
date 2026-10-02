import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

const gold = Color(0xFFD4AF67);
const ink = Color(0xFF171512);
const ivory = Color(0xFFFFFCF5);
const brown = Color(0xFF405044);
const lapiGreen = Color(0xFF247A4B);
const lapiGreenDark = Color(0xFF155A36);
const paper = Color(0xFFF8F6EE);
const mist = Color(0xFFF1F5EF);
const premiumCard = Color(0xF7FFFEFA);
const lineSoft = Color(0xFFE4DDC8);
const heroGreen = Color(0xFF0B3F2D);
const heroGreen2 = Color(0xFF155C42);
const warmGoldText = Color(0xFFF2D88D);
const cream = Color(0xFFFFFCF5);
const softGoldLine = Color(0xFFDCC47B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.init();
  runApp(const LapibreizhApp());
}

class LapibreizhApp extends StatelessWidget {
  const LapibreizhApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LapiGestion',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: lapiGreen, brightness: Brightness.light),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: lapiGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize:20,
          fontWeight:FontWeight.w800,
          color:Colors.white,
          letterSpacing:.2,
          fontFamily:'serif',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:true,
        fillColor: premiumCard,
        contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:15),
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:softGoldLine)),
        enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:softGoldLine)),
        focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:gold,width:1.6)),
      ),
      cardTheme:CardThemeData(
        color: premiumCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x140A1A10),
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: softGoldLine, width: 1.0),
        ),
      ),
      filledButtonTheme:FilledButtonThemeData(
        style:FilledButton.styleFrom(
          backgroundColor:heroGreen,
          foregroundColor:Colors.white,
          padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
          side:const BorderSide(color:gold,width:.8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme:OutlinedButtonThemeData(
        style:OutlinedButton.styleFrom(
          foregroundColor:lapiGreenDark,
          backgroundColor: premiumCard,
          padding: const EdgeInsets.symmetric(horizontal:18, vertical:16),
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),
          side:const BorderSide(color:softGoldLine,width:.9),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states)=>states.contains(WidgetState.selected)?gold:Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states)=>states.contains(WidgetState.selected)?heroGreen2:const Color(0xFFB8C5BC),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states)=>states.contains(WidgetState.selected)?gold:lapiGreenDark,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states)=>states.contains(WidgetState.selected)?heroGreen:heroGreen2,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states)=>states.contains(WidgetState.selected)?warmGoldText:Colors.white,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states)=>states.contains(WidgetState.selected)?warmGoldText:Colors.white,
          ),
          side: WidgetStateProperty.resolveWith(
            (states)=>BorderSide(
              color:states.contains(WidgetState.selected)?gold:Colors.white24,
              width:states.contains(WidgetState.selected)?1.2:.7,
            ),
          ),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
      ),
    ),
    builder:(context,child)=>Container(
      decoration:const BoxDecoration(
        image:DecorationImage(
          image:AssetImage('assets/images/lapigestion_background_master.jpg'),
          fit:BoxFit.cover,
          alignment:Alignment.topCenter,
        ),
      ),
      child:child??const SizedBox.shrink(),
    ),
    home: const LapiSplashPage(),
  );
}


class LapiSplashPage extends StatefulWidget {
  const LapiSplashPage({super.key});
  @override State<LapiSplashPage> createState()=>_LapiSplashPageState();
}

class _LapiSplashPageState extends State<LapiSplashPage> {
  bool leaving=false;

  @override void initState(){
    super.initState();
    Future.delayed(const Duration(milliseconds:1800),_enterApp);
  }

  void _enterApp(){
    if(leaving||!mounted)return;
    leaving=true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:const Duration(milliseconds:450),
        pageBuilder:(_,animation,secondaryAnimation)=>const HomePage(),
        transitionsBuilder:(_,animation,secondaryAnimation,child)=>FadeTransition(
          opacity:CurvedAnimation(parent:animation,curve:Curves.easeOut),
          child:child,
        ),
      ),
    );
  }

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xFF10291B),
    body:GestureDetector(
      behavior:HitTestBehavior.opaque,
      onTap:_enterApp,
      child:SizedBox.expand(
        child:Image.asset(
          'assets/images/lapigestion_splash.png',
          fit:BoxFit.cover,
          filterQuality:FilterQuality.high,
        ),
      ),
    ),
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


  static Future<void> scheduleMedication({
    required String rabbitName,
    required Map<String,dynamic> item,
  }) async {
    final token=(item['notificationKey']??'') as String;
    await cancelToken(token);
    if(token.isEmpty||(item['notificationsEnabled']??true)!=true)return;

    final start=parseDate(item['startDate'] as String?);
    if(start==null)return;
    final end=parseDate(item['endDate'] as String?);
    final times=((item['times'] as List?)??[]).map((e)=>e.toString()).where((e)=>e.contains(':')).toList();
    if(times.isEmpty)return;

    await requestPermission();
    final now=DateTime.now();
    final horizon=end??now.add(const Duration(days:60));
    var day=DateTime(start.year,start.month,start.day);
    var scheduled=0;

    while(!day.isAfter(horizon)&&scheduled<180){
      for(final time in times){
        final p=time.split(':');
        final hour=int.tryParse(p[0])??9;
        final minute=p.length>1?int.tryParse(p[1])??0:0;
        final when=DateTime(day.year,day.month,day.day,hour,minute);
        if(!when.isAfter(now))continue;
        final medicine=((item['name']??'Médicament') as String).trim();
        final dose=((item['dose']??'') as String).trim();
        final route=((item['route']??'') as String).trim();
        await _schedule(
          token:token,
          idSeed:'$token|medication|${day.toIso8601String()}|$time',
          title:'Traitement • $rabbitName',
          body:'$medicine${dose.isEmpty?'':' • $dose'}${route.isEmpty?'':' • $route'}',
          when:when,
        );
        scheduled++;
        if(scheduled>=180)break;
      }
      day=day.add(const Duration(days:1));
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
      for(final raw in ((r['medications'] as List?)??[])){
        await scheduleMedication(rabbitName:name,item:Map<String,dynamic>.from(raw));
      }
    }
  }

  static Future<void> cancelRabbit(Map<String,dynamic> rabbit) async {
    for(final key in ['vaccines','dewormings','appointments','medications']){
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
      if(r['identification']==null){r['identification']='';changed=true;}
      if(r['tattoo']==null){r['tattoo']='';changed=true;}
      if(r['engagementRecipientName']==null){r['engagementRecipientName']='';changed=true;}
      if(r['engagementRecipientAddress']==null){r['engagementRecipientAddress']='';changed=true;}
      if(r['engagementRecipientEmail']==null){r['engagementRecipientEmail']='';changed=true;}
      if(r['engagementDeliveryDate']==null){r['engagementDeliveryDate']='';changed=true;}
      if(r['engagementSignedDate']==null){r['engagementSignedDate']='';changed=true;}
      if(r['engagementPlace']==null){r['engagementPlace']='';changed=true;}
      if(r['engagementIssuerName']==null){r['engagementIssuerName']='';changed=true;}
      if(r['engagementIssuerQualification']==null){r['engagementIssuerQualification']='';changed=true;}
      if(r['engagementIssuerReference']==null){r['engagementIssuerReference']='';changed=true;}
      if(r['engagementMentionImage']==null){r['engagementMentionImage']='';changed=true;}
      if(r['engagementSignatureImage']==null){r['engagementSignatureImage']='';changed=true;}
      if(r['engagementCertificatePdf']==null){r['engagementCertificatePdf']='';changed=true;}
      if(r['engagementAccepted']==null){r['engagementAccepted']=false;changed=true;}
      if(r['adoptionStatus']==null){r['adoptionStatus']='À l’élevage';changed=true;}
      if(r['adopterName']==null){r['adopterName']='';changed=true;}
      if(r['adopterContact']==null){r['adopterContact']='';changed=true;}
      if(r['departureDate']==null){r['departureDate']='';changed=true;}
      if(r['adoptionNotes']==null){r['adoptionNotes']='';changed=true;}
      if(r['healthBookGiven']==null){r['healthBookGiven']=false;changed=true;}
      if(r['healthCertificateGiven']==null){r['healthCertificateGiven']=false;changed=true;}
      if(r['adoptionInfoGiven']==null){r['adoptionInfoGiven']=false;changed=true;}
      if(r['appointments']==null){r['appointments']=[];changed=true;}
      if(r['weights']==null){r['weights']=[];changed=true;}
      if(r['competitions']==null){r['competitions']=[];changed=true;}
      if(r['medications']==null){r['medications']=[];changed=true;}
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


class AppModeStore {
  static const key='lapibreizh_app_mode_v2';
  static Future<String> load() async {
    final p=await SharedPreferences.getInstance();
    final value=p.getString(key);
    return value=='Adoptant'?'Adoptant':'Éleveur';
  }
  static Future<void> save(String value) async {
    final p=await SharedPreferences.getInstance();
    await p.setString(key,value=='Adoptant'?'Adoptant':'Éleveur');
  }
}

class ReproductionSettingsStore {
  static const _maxKey='lapibreizh_repro_max_litters_v1';
  static const _restKey='lapibreizh_repro_rest_days_v1';

  static Future<Map<String,int>> load() async {
    final p=await SharedPreferences.getInstance();
    return {
      'maxLitters':(p.getInt(_maxKey)??4).clamp(1,6) as int,
      'restDays':p.getInt(_restKey)??90,
    };
  }

  static Future<void> save({required int maxLitters,required int restDays}) async {
    final p=await SharedPreferences.getInstance();
    await p.setInt(_maxKey,maxLitters.clamp(1,6) as int);
    await p.setInt(_restKey,restDays<0 ? 0 : restDays);
  }
}

class RabbitBreedCatalog {
  static const categories=<String>[
    'Toutes','Grandes races','Races moyennes','Petites races','Races naines','Fourrure caractéristique','Autres',
  ];

  // Base exhaustive issue de la nomenclature FFC 2026-2027.
  // Les entrées marquées standard:true correspondent aux races/variétés reconnues.
  static const breeds=<Map<String,dynamic>>[
    {'name':'Bélier Français','category':'Grandes races'},
    {'name':'Bleu de Ham','category':'Grandes races'},
    {'name':'Bleu de Saint Nicolas','category':'Grandes races'},
    {'name':'Géant Blanc du Bouscat','category':'Grandes races'},
    {'name':'Géant des Flandres','category':'Grandes races'},
    {'name':'Géant Papillon Français','category':'Grandes races'},
    {'name':'Alaska','category':'Races moyennes'},
    {'name':'Argenté de Champagne','category':'Races moyennes'},
    {'name':'Argenté de Saint-Hubert','category':'Races moyennes'},
    {'name':'Bélier Anglais','category':'Races moyennes'},
    {'name':'Bélier Meissner','category':'Races moyennes'},
    {'name':'Beveren','category':'Races moyennes'},
    {'name':'Blanc de Hotot','category':'Races moyennes'},
    {'name':'Blanc de Moravie aux yeux brun','category':'Races moyennes'},
    {'name':'Blanc de Termonde','category':'Races moyennes'},
    {'name':'Blanc de Vendée','category':'Races moyennes'},
    {'name':'Bourguignon – Fauve Suisse','category':'Races moyennes'},
    {'name':'Californien','category':'Races moyennes'},
    {'name':'Chamois de Thuringe','category':'Races moyennes'},
    {'name':'Fauve de Bourgogne','category':'Races moyennes'},
    {'name':'Grand Argenté','category':'Races moyennes'},
    {'name':'Grand Argenté clair','category':'Races moyennes'},
    {'name':'Grand Chinchilla','category':'Races moyennes'},
    {'name':'Grand Russe','category':'Races moyennes'},
    {'name':'Gris de l\'Artois','category':'Races moyennes'},
    {'name':'Gris de Touraine','category':'Races moyennes'},
    {'name':'Gris du Bourbonnais','category':'Races moyennes'},
    {'name':'Havane type allemand','category':'Races moyennes'},
    {'name':'Japonais','category':'Races moyennes'},
    {'name':'Lapin chèvre','category':'Races moyennes'},
    {'name':'Lièvre Belge','category':'Races moyennes'},
    {'name':'Néo-Zélandais','category':'Races moyennes'},
    {'name':'Noir / Bleu / Havane et Blanc','category':'Races moyennes'},
    {'name':'Normand','category':'Races moyennes'},
    {'name':'Papillon Rhénan','category':'Races moyennes'},
    {'name':'Petit Papillon','category':'Races moyennes'},
    {'name':'Sallander','category':'Races moyennes'},
    {'name':'Séparator','category':'Races moyennes'},
    {'name':'Tacheté de Mecklembourg','category':'Races moyennes'},
    {'name':'Vienne – Blanc de Vienne','category':'Races moyennes'},
    {'name':'Vienne – Bleu de Vienne','category':'Races moyennes'},
    {'name':'Vienne – Gris de Vienne','category':'Races moyennes'},
    {'name':'Vienne – Gris fer de Vienne','category':'Races moyennes'},
    {'name':'Vienne – Gris bleu de Vienne','category':'Races moyennes'},
    {'name':'Vienne – Noir de Vienne','category':'Races moyennes'},
    {'name':'Angora (race européenne)','category':'Fourrure caractéristique'},
    {'name':'Angora Français','category':'Fourrure caractéristique'},
    {'name':'Barbu de Gand','category':'Fourrure caractéristique'},
    {'name':'Renard','category':'Fourrure caractéristique'},
    {'name':'Rex','category':'Fourrure caractéristique'},
    {'name':'Satin','category':'Fourrure caractéristique'},
    {'name':'Argenté Anglais','category':'Petites races'},
    {'name':'Bleu de Holice','category':'Petites races'},
    {'name':'Brun Marron de Lorraine','category':'Petites races'},
    {'name':'Chinchilla','category':'Petites races'},
    {'name':'Deilenaar','category':'Petites races'},
    {'name':'Doré de Saxe','category':'Petites races'},
    {'name':'Feh de Marbourg','category':'Petites races'},
    {'name':'Feu','category':'Petites races'},
    {'name':'Gouwenaar','category':'Petites races'},
    {'name':'Gris Perle de Hal','category':'Petites races'},
    {'name':'Havane Français','category':'Petites races'},
    {'name':'Hollandais','category':'Petites races'},
    {'name':'Hulstlander','category':'Petites races'},
    {'name':'Jarres Noirs','category':'Petites races'},
    {'name':'Lynx','category':'Petites races'},
    {'name':'Papillon Anglais','category':'Petites races'},
    {'name':'Perlfeh','category':'Petites races'},
    {'name':'Petit Argenté','category':'Petites races'},
    {'name':'Petit Argenté clair','category':'Petites races'},
    {'name':'Petit Bélier','category':'Petites races'},
    {'name':'Petit Rex','category':'Petites races'},
    {'name':'Rhön','category':'Petites races'},
    {'name':'Russe','category':'Petites races'},
    {'name':'Sablé des Vosges','category':'Petites races'},
    {'name':'Steenkonijn – Lapin pierre','category':'Petites races'},
    {'name':'Thrianta','category':'Petites races'},
    {'name':'Zibeline','category':'Petites races'},
    {'name':'Hermine','category':'Races naines'},
    {'name':'Nain de Couleur','category':'Races naines'},
    {'name':'Nain Lièvre','category':'Races naines'},
    {'name':'Nain Bélier','category':'Races naines'},
    {'name':'Nain Papillon','category':'Races naines'},
    {'name':'Nain Bélier Angora','category':'Races naines'},
    {'name':'Nain Bélier Rex','category':'Races naines'},
    {'name':'Nain Bélier Satin','category':'Races naines'},
    {'name':'Nain Bélier Tête de Lion','category':'Races naines'},
    {'name':'Nain Angora','category':'Races naines'},
    {'name':'Nain Renard','category':'Races naines'},
    {'name':'Nain Rex','category':'Races naines'},
    {'name':'Nain Satin','category':'Races naines'},
    {'name':'Nain Tête de Lion','category':'Races naines'},
    {'name':'Croisé','category':'Autres'},
    {'name':'Autre / non reconnu','category':'Autres'},
    {'name':'Race inconnue','category':'Autres'},
  ];

  static const colorsByBreed=<String,List<Map<String,dynamic>>>{
    'Bélier Français':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Sallander','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Japonais','standard':true},
      {'name':'Rhön','standard':true},
      {'name':'À manteau gris garenne','standard':true},
      {'name':'À manteau gris fer','standard':true},
      {'name':'À manteau gris lièvre','standard':true},
      {'name':'À manteau gris bleu','standard':true},
      {'name':'À manteau chinchilla','standard':true},
      {'name':'À manteau jaune','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau havane','standard':true},
      {'name':'À manteau feh','standard':true},
      {'name':'À manteau chamois','standard':true},
      {'name':'À manteau isabelle','standard':true},
    ],
    'Bleu de Ham':[
      {'name':'Bleu ardoise','standard':true},
    ],
    'Bleu de Saint Nicolas':[
      {'name':'Bleu clair intense','standard':true},
    ],
    'Géant Blanc du Bouscat':[
      {'name':'Blanc','standard':true},
    ],
    'Géant des Flandres':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
    ],
    'Géant Papillon Français':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Tricolore blanc/jaune/noir','standard':true},
      {'name':'Tricolore blanc/jaune/bleu','standard':true},
      {'name':'Noir uni','standard':false},
      {'name':'Bleu uni','standard':false},
      {'name':'Havane uni','standard':false},
      {'name':'Chamois uni','standard':false},
      {'name':'Charlot','standard':false},
    ],
    'Alaska':[
      {'name':'Noir','standard':true},
    ],
    'Argenté de Champagne':[
      {'name':'Vieil argent','standard':true},
    ],
    'Argenté de Saint-Hubert':[
      {'name':'Gris garenne argenté','standard':true},
    ],
    'Bélier Anglais':[
      {'name':'Blanc YR','standard':true},
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Siamois','standard':true},
      {'name':'À manteau gris garenne','standard':true},
      {'name':'À manteau gris fer','standard':true},
      {'name':'À manteau gris bleu','standard':true},
      {'name':'À manteau chinchilla','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau chamois','standard':true},
      {'name':'À manteau isabelle','standard':true},
    ],
    'Bélier Meissner':[
      {'name':'Gris garenne','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Beveren':[
      {'name':'Blanc aux yeux bleus','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Noir','standard':true},
    ],
    'Blanc de Hotot':[
      {'name':'Blanc à lunettes noires','standard':true},
    ],
    'Blanc de Moravie aux yeux brun':[
      {'name':'Blanc pur aux yeux bruns','standard':true},
    ],
    'Blanc de Termonde':[
      {'name':'Blanc','standard':true},
    ],
    'Blanc de Vendée':[
      {'name':'Blanc YR (albinos)','standard':true},
    ],
    'Bourguignon – Fauve Suisse':[
      {'name':'Fauve / jaune-roux','standard':true},
    ],
    'Californien':[
      {'name':'Blanc à extrémités noires','standard':true},
    ],
    'Chamois de Thuringe':[
      {'name':'Chamois','standard':true},
    ],
    'Fauve de Bourgogne':[
      {'name':'Fauve roux','standard':true},
    ],
    'Grand Argenté':[
      {'name':'Jaune','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Grand Argenté clair':[
      {'name':'Argenté clair','standard':true},
    ],
    'Grand Chinchilla':[
      {'name':'Chinchilla','standard':true},
    ],
    'Grand Russe':[
      {'name':'Blanc à marques noires','standard':true},
    ],
    'Gris de l\'Artois':[
      {'name':'Lièvre roux foncé','standard':true},
    ],
    'Gris de Touraine':[
      {'name':'Gris cendré clair','standard':true},
    ],
    'Gris du Bourbonnais':[
      {'name':'Gris de fer atténué','standard':true},
    ],
    'Havane type allemand':[
      {'name':'Havane','standard':true},
    ],
    'Japonais':[
      {'name':'Noir / jaune','standard':true},
    ],
    'Lapin chèvre':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
    ],
    'Lièvre Belge':[
      {'name':'Roux foncé','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Albinos','standard':true},
      {'name':'Noir','standard':true},
    ],
    'Néo-Zélandais':[
      {'name':'Blanc aux yeux roses','standard':true},
    ],
    'Noir / Bleu / Havane et Blanc':[
      {'name':'Noir et Blanc','standard':true},
      {'name':'Bleu et Blanc','standard':true},
      {'name':'Havane et Blanc','standard':true},
    ],
    'Normand':[
      {'name':'Gris garenne atténué','standard':true},
    ],
    'Papillon Rhénan':[
      {'name':'Blanc / noir / jaune','standard':true},
    ],
    'Petit Papillon':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
    ],
    'Sallander':[
      {'name':'Sallander','standard':true},
    ],
    'Séparator':[
      {'name':'Beige','standard':true},
    ],
    'Tacheté de Mecklembourg':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Chamois','standard':true},
    ],
    'Vienne – Blanc de Vienne':[
      {'name':'Blanc','standard':true},
    ],
    'Vienne – Bleu de Vienne':[
      {'name':'Bleu','standard':true},
    ],
    'Vienne – Gris de Vienne':[
      {'name':'Gris de Vienne','standard':true},
    ],
    'Vienne – Gris fer de Vienne':[
      {'name':'Gris fer','standard':true},
    ],
    'Vienne – Gris bleu de Vienne':[
      {'name':'Gris bleu','standard':true},
    ],
    'Vienne – Noir de Vienne':[
      {'name':'Noir','standard':true},
    ],
    'Angora (race européenne)':[
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
    ],
    'Angora Français':[
      {'name':'Blanc YR (Albinos)','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Gris garenne','standard':true},
    ],
    'Barbu de Gand':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Renard':[
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chinchilla','standard':true},
    ],
    'Rex':[
      {'name':'Castor','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Opale','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Loutre feh','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Gris perle','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Hotot','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Dalmatien noir','standard':true},
      {'name':'Dalmatien bleu','standard':true},
      {'name':'Dalmatien havane','standard':true},
      {'name':'Dalmatien tricolore blanc/jaune/noir','standard':true},
      {'name':'Papillon noir','standard':true},
      {'name':'Papillon tricolore blanc/jaune/noir','standard':true},
      {'name':'Japonais jaune/noir','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Satin':[
      {'name':'Ivoire YB','standard':true},
      {'name':'Ivoire YR','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Rouge','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Castor','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Siamois','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Himalayen noir','standard':true},
      {'name':'Himalayen havane','standard':true},
      {'name':'Himalayen bleu','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Argenté Anglais':[
      {'name':'Gris garenne','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Bleu de Holice':[
      {'name':'Bleu acier clair','standard':true},
    ],
    'Brun Marron de Lorraine':[
      {'name':'Brun marron (gris lièvre)','standard':true},
    ],
    'Chinchilla':[
      {'name':'Chinchilla','standard':true},
    ],
    'Deilenaar':[
      {'name':'Lièvre roux','standard':true},
    ],
    'Doré de Saxe':[
      {'name':'Doré / orange-rouge','standard':true},
    ],
    'Feh de Marbourg':[
      {'name':'Feh','standard':true},
    ],
    'Feu':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
    ],
    'Gouwenaar':[
      {'name':'Gris bleu tendre','standard':true},
    ],
    'Gris Perle de Hal':[
      {'name':'Gris perle','standard':true},
    ],
    'Havane Français':[
      {'name':'Havane','standard':true},
    ],
    'Hollandais':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Tricolore blanc/jaune/noir','standard':true},
      {'name':'Tricolore blanc/jaune/bleu','standard':true},
    ],
    'Hulstlander':[
      {'name':'Blanc immaculé','standard':true},
    ],
    'Jarres Noirs':[
      {'name':'Jarres noirs','standard':true},
    ],
    'Lynx':[
      {'name':'Lynx','standard':true},
    ],
    'Papillon Anglais':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Tricolore blanc/jaune/noir','standard':true},
    ],
    'Perlfeh':[
      {'name':'Perlfeh','standard':true},
    ],
    'Petit Argenté':[
      {'name':'Gris garenne','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Petit Argenté clair':[
      {'name':'Argenté clair','standard':true},
    ],
    'Petit Bélier':[
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Noir et blanc','standard':true},
      {'name':'Bleu et blanc','standard':true},
      {'name':'Havane et blanc','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Sallander','standard':true},
      {'name':'Rhön','standard':true},
      {'name':'À manteau gris garenne','standard':true},
      {'name':'À manteau gris fer','standard':true},
      {'name':'À manteau gris bleu','standard':true},
      {'name':'À manteau chinchilla','standard':true},
      {'name':'À manteau fauve','standard':true},
      {'name':'À manteau jaune','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau havane','standard':true},
      {'name':'À manteau feh','standard':true},
      {'name':'À manteau chamois','standard':true},
      {'name':'À manteau isabelle','standard':true},
    ],
    'Petit Rex':[
      {'name':'Castor','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Dalmatien noir','standard':true},
      {'name':'Dalmatien bleu','standard':true},
      {'name':'Dalmatien havane','standard':true},
      {'name':'Dalmatien tricolore blanc/jaune/noir','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau havane','standard':true},
      {'name':'À manteau tacheté jaune/noir','standard':true},
    ],
    'Rhön':[
      {'name':'Rhön','standard':true},
    ],
    'Russe':[
      {'name':'Marques bleues','standard':true},
      {'name':'Marques havane','standard':true},
      {'name':'Marques noires','standard':true},
    ],
    'Sablé des Vosges':[
      {'name':'Brun','standard':true},
      {'name':'Bleu','standard':true},
    ],
    'Steenkonijn – Lapin pierre':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Lièvre roux','standard':true},
    ],
    'Thrianta':[
      {'name':'Orange-rouge','standard':true},
    ],
    'Zibeline':[
      {'name':'Bleu','standard':true},
      {'name':'Brun','standard':true},
    ],
    'Hermine':[
      {'name':'Yeux bleus','standard':true},
      {'name':'Yeux roses','standard':true},
    ],
    'Nain de Couleur':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Cendré écru','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Perlfeh','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Feu havane','standard':true},
      {'name':'Feu feh','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Loutre feh','standard':true},
      {'name':'Noir et blanc','standard':true},
      {'name':'Bleu et blanc','standard':true},
      {'name':'Havane et blanc','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Argenté noir','standard':true},
      {'name':'Argenté bleu','standard':true},
      {'name':'Argenté havane','standard':true},
      {'name':'Argenté gris garenne','standard':true},
      {'name':'Argenté jaune','standard':true},
      {'name':'Argenté clair','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Sallander','standard':true},
      {'name':'Séparator','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Siamois brun','standard':true},
      {'name':'Siamois bleu','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Russe marques bleues','standard':true},
      {'name':'Sablé brun','standard':true},
      {'name':'Sablé bleu','standard':true},
      {'name':'Oreilles panachées/colorées noires (Lutterbach)','standard':true},
      {'name':'Oreilles panachées/colorées bleues (Lutterbach)','standard':true},
      {'name':'Oreilles panachées/colorées havane (Lutterbach)','standard':true},
      {'name':'Japonais jaune/noir','standard':true},
      {'name':'Rhön','standard':true},
      {'name':'Hotot','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau havane','standard':true},
      {'name':'À manteau feh','standard':true},
      {'name':'À manteau garenne','standard':true},
      {'name':'Hollandais noir','standard':true},
      {'name':'Hollandais bleu','standard':true},
      {'name':'Hollandais havane','standard':true},
      {'name':'Hollandais gris garenne','standard':true},
      {'name':'Hollandais gris fer','standard':true},
      {'name':'Hollandais gris lièvre','standard':true},
      {'name':'Hollandais chamois','standard':true},
      {'name':'Hollandais jaune','standard':true},
      {'name':'Hollandais chinchilla','standard':true},
      {'name':'Hollandais tricolore blanc/jaune/noir','standard':true},
    ],
    'Nain Lièvre':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Noir et blanc','standard':true},
      {'name':'Bleu et blanc','standard':true},
      {'name':'Havane et blanc','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
    ],
    'Nain Bélier':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Noir et blanc','standard':true},
      {'name':'Bleu et blanc','standard':true},
      {'name':'Havane et blanc','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Feu havane','standard':true},
      {'name':'Feu feh','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Loutre feh','standard':true},
      {'name':'Perlfeh','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Sallander','standard':true},
      {'name':'Siamois brun','standard':true},
      {'name':'Siamois bleu','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Russe marques bleues','standard':true},
      {'name':'Hotot','standard':true},
      {'name':'Rhön','standard':true},
      {'name':'Japonais jaune/noir','standard':true},
      {'name':'À manteau gris garenne','standard':true},
      {'name':'À manteau gris lièvre','standard':true},
      {'name':'À manteau gris fer','standard':true},
      {'name':'À manteau chinchilla','standard':true},
      {'name':'À manteau fauve','standard':true},
      {'name':'À manteau jaune','standard':true},
      {'name':'À manteau lynx','standard':true},
      {'name':'À manteau perlfeh','standard':true},
      {'name':'À manteau noir','standard':true},
      {'name':'À manteau bleu','standard':true},
      {'name':'À manteau havane','standard':true},
      {'name':'À manteau feh','standard':true},
      {'name':'À manteau chamois','standard':true},
      {'name':'À manteau isabelle','standard':true},
    ],
    'Nain Papillon':[
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Isabelle','standard':true},
      {'name':'Tricolore blanc/jaune/noir','standard':true},
    ],
    'Nain Bélier Angora':[
      {'name':'Gris garenne','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
    ],
    'Nain Bélier Rex':[
      {'name':'Castor','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jarres noirs','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Opale','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Loutre feh','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Siamois brun','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Hotot','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Dalmatien noir','standard':true},
      {'name':'Dalmatien bleu','standard':true},
      {'name':'Dalmatien havane','standard':true},
      {'name':'Dalmatien tricolore blanc/jaune/noir','standard':true},
      {'name':'Papillon noir','standard':true},
      {'name':'Papillon tricolore blanc/jaune/noir','standard':true},
      {'name':'Japonais jaune/noir','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Nain Bélier Satin':[
      {'name':'Castor','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Rouge','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Ivoire YR','standard':true},
      {'name':'Ivoire YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Siamois brun','standard':true},
      {'name':'Californien noir','standard':true},
      {'name':'Californien bleu','standard':true},
      {'name':'Californien havane','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Nain Bélier Tête de Lion':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Nain Angora':[
      {'name':'Gris garenne','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
    ],
    'Nain Renard':[
      {'name':'Chinchilla','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Havane','standard':true},
    ],
    'Nain Rex':[
      {'name':'Castor','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Fauve','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Opale','standard':true},
      {'name':'Feu noir','standard':true},
      {'name':'Feu bleu','standard':true},
      {'name':'Loutre noir','standard':true},
      {'name':'Loutre bleu','standard':true},
      {'name':'Loutre havane','standard':true},
      {'name':'Loutre feh','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Zibeline brun','standard':true},
      {'name':'Zibeline bleu','standard':true},
      {'name':'Zibeline brun et blanc','standard':true},
      {'name':'Zibeline bleu et blanc','standard':true},
      {'name':'Russe marques noires','standard':true},
      {'name':'Hotot','standard':true},
      {'name':'Papillon noir','standard':true},
      {'name':'Papillon tricolore blanc/jaune/noir','standard':true},
      {'name':'Dalmatien noir','standard':true},
      {'name':'Dalmatien bleu','standard':true},
      {'name':'Dalmatien havane','standard':true},
      {'name':'Dalmatien tricolore blanc/jaune/noir','standard':true},
      {'name':'Japonais noir/jaune','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Nain Satin':[
      {'name':'Castor','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Rouge','standard':true},
      {'name':'Lynx','standard':true},
      {'name':'Ivoire YR','standard':true},
      {'name':'Ivoire YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Feh','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Siamois brun','standard':true},
      {'name':'Californien noir','standard':true},
      {'name':'Californien bleu','standard':true},
      {'name':'Californien havane','standard':true},
      {'name':'Rhön','standard':true},
    ],
    'Nain Tête de Lion':[
      {'name':'Gris garenne','standard':true},
      {'name':'Gris lièvre','standard':true},
      {'name':'Lièvre roux','standard':true},
      {'name':'Gris fer','standard':true},
      {'name':'Gris bleu','standard':true},
      {'name':'Chinchilla','standard':true},
      {'name':'Jaune','standard':true},
      {'name':'Blanc YR','standard':true},
      {'name':'Blanc YB','standard':true},
      {'name':'Noir','standard':true},
      {'name':'Bleu','standard':true},
      {'name':'Havane','standard':true},
      {'name':'Chamois','standard':true},
      {'name':'Rhön','standard':true},
    ],
  };

  static String _canonicalBreed(String? breed){
    final key=(breed??'').trim();
    if(key=='Nain de couleur')return 'Nain de Couleur';
    return key;
  }

  static List<String> racesFor({String category='Toutes',String query=''}){
    final q=query.trim().toLowerCase();
    final out=breeds.where((b){
      final categoryOk=category=='Toutes'||b['category']==category;
      final name=(b['name']??'').toString();
      final queryOk=q.isEmpty||name.toLowerCase().contains(q);
      return categoryOk&&queryOk;
    }).map((b)=>(b['name']??'').toString()).where((x)=>x.isNotEmpty).toList();
    out.sort((a,b)=>a.toLowerCase().compareTo(b.toLowerCase()));
    return out;
  }

  static List<Map<String,dynamic>> colorsFor(String? breed){
    final key=_canonicalBreed(breed);
    final exact=colorsByBreed[key];
    final out=<Map<String,dynamic>>[];
    if(exact!=null)out.addAll(exact.map((e)=>Map<String,dynamic>.from(e)));
    if(exact==null){
      out.addAll(ReproductionStore.colorOptions.map((c)=>{'name':c,'standard':false}));
    }
    const generic=[
      {'name':'Non déterminé','standard':false},
      {'name':'Autre / non standard','standard':false},
    ];
    for(final item in generic){
      if(!out.any((e)=>e['name']==item['name']))out.add(Map<String,dynamic>.from(item));
    }
    return out;
  }

  static bool isStandard(String? breed,String? color)=>colorsFor(breed).any((e)=>e['name']==color&&e['standard']==true);
}
class RacePickerDialog extends StatefulWidget{
  final String initial;
  final String title;
  const RacePickerDialog({super.key,this.initial='',this.title='Choisir la race'});
  @override State<RacePickerDialog> createState()=>_RacePickerDialogState();
}

class _RacePickerDialogState extends State<RacePickerDialog>{
  String category='Toutes';
  String query='';
  @override Widget build(BuildContext context){
    final races=RabbitBreedCatalog.racesFor(category:category,query:query);
    return Dialog.fullscreen(child:Scaffold(
      appBar:AppBar(title:Text(widget.title),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
      body:Column(children:[
        Padding(padding:const EdgeInsets.all(14),child:TextField(
          autofocus:false,
          decoration:const InputDecoration(labelText:'Rechercher une race',prefixIcon:Icon(Icons.search)),
          onChanged:(v)=>setState(()=>query=v),
        )),
        SizedBox(height:44,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),children:[
          for(final c in RabbitBreedCatalog.categories) Padding(
            padding:const EdgeInsets.only(right:7),
            child:ChoiceChip(label:Text(c),selected:category==c,onSelected:(_)=>setState(()=>category=c)),
          ),
        ])),
        const SizedBox(height:6),
        Expanded(child:races.isEmpty
          ? const Center(child:Text('Aucune race trouvée.'))
          : ListView.separated(
              itemCount:races.length,
              separatorBuilder:(_,__)=>const Divider(height:1),
              itemBuilder:(context,i){
                final race=races[i];
                return ListTile(
                  title:Text(race,style:const TextStyle(fontWeight:FontWeight.w700)),
                  trailing:race==widget.initial?const Icon(Icons.check_circle,color:lapiGreen):null,
                  onTap:()=>Navigator.pop(context,race),
                );
              },
            )),
      ]),
    ));
  }
}

class BreedColorPickerDialog extends StatefulWidget{
  final String breed;
  final String initial;
  final Set<String> unavailable;
  const BreedColorPickerDialog({super.key,required this.breed,this.initial='',this.unavailable=const <String>{}});
  @override State<BreedColorPickerDialog> createState()=>_BreedColorPickerDialogState();
}

class _BreedColorPickerDialogState extends State<BreedColorPickerDialog>{
  String query='';
  @override Widget build(BuildContext context){
    final q=query.trim().toLowerCase();
    final items=RabbitBreedCatalog.colorsFor(widget.breed).where((e){
      final name=(e['name']??'').toString();
      final available=name==widget.initial||!widget.unavailable.contains(name);
      return available&&(q.isEmpty||name.toLowerCase().contains(q));
    }).toList();
    return Dialog.fullscreen(child:Scaffold(
      appBar:AppBar(title:const Text('Choisir la couleur / variété'),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),
      body:Column(children:[
        Padding(
          padding:const EdgeInsets.fromLTRB(14,14,14,6),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Text(widget.breed.trim().isEmpty?'Race non renseignée':widget.breed,style:const TextStyle(fontWeight:FontWeight.w900,color:ink)),
            const SizedBox(height:4),
            const Text('🏅 = variété reconnue au standard de la race',style:TextStyle(fontSize:11,color:brown)),
            const SizedBox(height:10),
            TextField(decoration:const InputDecoration(labelText:'Rechercher une couleur / variété',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState(()=>query=v)),
          ]),
        ),
        Expanded(child:ListView.separated(
          itemCount:items.length,
          separatorBuilder:(_,__)=>const Divider(height:1),
          itemBuilder:(context,i){
            final item=items[i];
            final name=(item['name']??'').toString();
            final standard=item['standard']==true;
            return ListTile(
              leading:standard?const Text('🏅',style:TextStyle(fontSize:20)):const SizedBox(width:22),
              title:Text(name,style:const TextStyle(fontWeight:FontWeight.w700)),
              subtitle:name=='Charlot'?const Text('Type de marquage non standard'):null,
              trailing:name==widget.initial?const Icon(Icons.check_circle,color:lapiGreen):null,
              onTap:()=>Navigator.pop(context,name),
            );
          },
        )),
      ]),
    ));
  }
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

  static const colorOptions=<String>[
    'Noir','Noir uni',
    'Bleu','Bleu uni',
    'Havane','Havane uni',
    'Feh','Feh uni',
    'Garenne','Garenne uni',
    'Gris fer','Gris fer uni',
    'Gris brun','Gris brun uni',
    'Gris bleu / Perlfeh','Gris bleu / Perlfeh uni',
    'Lynx','Lynx uni',
    'Jaune / Fauve','Jaune / Fauve uni',
    'Madagascar / Chamois','Madagascar / Chamois uni',
    'Isabelle','Isabelle uni',
    'Tricolore / Japonais noir',
    'Tricolore / Japonais bleu',
    'Tricolore / Japonais havane',
    'Tricolore / Japonais feh',
    'Non déterminé',
  ];

  static List<Map<String,dynamic>> colorsOf(Map<String,dynamic> record){
    final out=<Map<String,dynamic>>[];
    for(final raw in ((record['colors'] as List?)??[])){
      if(raw is! Map)continue;
      final e=Map<String,dynamic>.from(raw);
      final color=(e['color']??'').toString().trim();
      if(color.isEmpty)continue;
      out.add({'color':color,'male':n(e['male']),'female':n(e['female'])});
    }
    return out;
  }

  static List<Map<String,dynamic>> aggregateColors(Iterable<Map<String,dynamic>> records){
    final totals=<String,Map<String,int>>{};
    for(final record in records){
      for(final item in colorsOf(record)){
        final color=item['color'] as String;
        final entry=totals.putIfAbsent(color,()=>{'male':0,'female':0});
        entry['male']=(entry['male']??0)+n(item['male']);
        entry['female']=(entry['female']??0)+n(item['female']);
      }
    }
    final ordered=<Map<String,dynamic>>[];
    for(final color in colorOptions){
      final entry=totals.remove(color);
      if(entry!=null&&(entry['male']!+entry['female']!)>0){
        ordered.add({'color':color,'male':entry['male'],'female':entry['female']});
      }
    }
    for(final entry in totals.entries){
      if((entry.value['male']!+entry.value['female']!)>0){
        ordered.add({'color':entry.key,'male':entry.value['male'],'female':entry.value['female']});
      }
    }
    return ordered;
  }

  static Map<String,int> colorSexTotals(Iterable<Map<String,dynamic>> colors){
    var male=0,female=0;
    for(final item in colors){
      male+=n(item['male']);
      female+=n(item['female']);
    }
    return {'male':male,'female':female,'total':male+female};
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
      for(final raw in ((r['competitions'] as List?)??[])){
        final item=raw as Map<String,dynamic>;
        for(final entry in {'photo':'competitions','judgingSheet':'competitions'}.entries){
          final old=((item[entry.key]??'') as String);
          final moved=await _migratePath(old,entry.value);
          if(moved!=old){item[entry.key]=moved;changed=true;}
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



class LayoutStore {
  static String _key(String name)=>'lapibreizh_layout_$name';

  static Future<List<String>> load(String name,List<String> defaults) async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getString(_key(name));
    if(raw==null||raw.isEmpty)return List<String>.from(defaults);
    try{
      final saved=(jsonDecode(raw) as List).map((e)=>e.toString()).toList();
      final result=<String>[];
      for(final id in saved){
        if(defaults.contains(id)&&!result.contains(id))result.add(id);
      }
      for(final id in defaults){
        if(!result.contains(id))result.add(id);
      }
      return result;
    }catch(_){
      return List<String>.from(defaults);
    }
  }

  static Future<void> save(String name,List<String> order,List<String> defaults) async {
    final merged=<String>[];
    for(final id in order){
      if(defaults.contains(id)&&!merged.contains(id))merged.add(id);
    }
    for(final id in defaults){
      if(!merged.contains(id))merged.add(id);
    }
    final p=await SharedPreferences.getInstance();
    await p.setString(_key(name),jsonEncode(merged));
  }
}

class BackupService {
  static const format='lapibreizh_backup_v1';

  static Iterable<MapEntry<String,String>> _rabbitFiles(Map<String,dynamic> rabbit) sync* {
    final photo=((rabbit['photo']??'') as String);
    if(photo.isNotEmpty)yield MapEntry(photo,'rabbit_photos');
    for(final key in ['healthBook','passport']){
      final p=((rabbit[key]??'') as String);
      if(p.isNotEmpty)yield MapEntry(p,'documents');
    }
    for(final entry in {
      'engagementMentionImage':'documents',
      'engagementSignatureImage':'documents',
      'engagementCertificatePdf':'documents',
    }.entries){
      final p=((rabbit[entry.key]??'') as String);
      if(p.isNotEmpty)yield MapEntry(p,entry.value);
    }
    for(final key in ['vaccines','dewormings']){
      for(final raw in ((rabbit[key] as List?)??[])){
        final item=raw as Map<String,dynamic>;
        final p=((item['photo']??'') as String);
        if(p.isNotEmpty)yield MapEntry(p,'treatments');
      }
    }
    for(final raw in ((rabbit['medications'] as List?)??[])){
      final item=raw as Map<String,dynamic>;
      for(final key in ['photo','prescription']){
        final p=((item[key]??'') as String);
        if(p.isNotEmpty)yield MapEntry(p,key=='prescription'?'documents':'treatments');
      }
    }
    for(final raw in ((rabbit['competitions'] as List?)??[])){
      final item=raw as Map<String,dynamic>;
      for(final key in ['photo','judgingSheet']){
        final p=((item[key]??'') as String);
        if(p.isNotEmpty)yield MapEntry(p,'competitions');
      }
    }
  }

  static Future<File> createBackup() async {
    final rabbits=await Store.load();
    final reproduction=await ReproductionStore.load();
    final mode=await AppModeStore.load();
    final files=<String,dynamic>{};

    for(final rabbit in rabbits){
      for(final entry in _rabbitFiles(rabbit)){
        if(files.containsKey(entry.key))continue;
        final f=File(entry.key);
        if(!await f.exists())continue;
        try{
          final bytes=await f.readAsBytes();
          files[entry.key]={
            'category':entry.value,
            'extension':PrivateFiles.extensionOf(entry.key),
            'data':base64Encode(bytes),
          };
        }catch(_){}
      }
    }

    final payload={
      'format':format,
      'createdAt':DateTime.now().toIso8601String(),
      'appMode':mode,
      'rabbits':rabbits,
      'reproduction':reproduction,
      'files':files,
    };

    final dir=await getTemporaryDirectory();
    final stamp=DateTime.now().toIso8601String().replaceAll(':','-').split('.').first;
    final file=File('${dir.path}/Sauvegarde-Lapibreizh-$stamp.json');
    await file.writeAsString(jsonEncode(payload),flush:true);
    return file;
  }

  static Future<void> restoreFromFile(String path) async {
    final source=File(path);
    if(!await source.exists())throw const FormatException('Fichier introuvable.');
    final decoded=jsonDecode(await source.readAsString());
    if(decoded is! Map||decoded['format']!=format)throw const FormatException('Sauvegarde Lapibreizh non reconnue.');

    final rabbits=((decoded['rabbits'] as List?)??[])
        .map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    final reproduction=((decoded['reproduction'] as List?)??[])
        .map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    final rawFiles=Map<String,dynamic>.from((decoded['files'] as Map?)??{});
    final restoredPaths=<String,String>{};

    Future<String> restorePath(String oldPath,String category) async {
      if(oldPath.isEmpty)return '';
      if(restoredPaths.containsKey(oldPath))return restoredPaths[oldPath]!;
      final raw=rawFiles[oldPath];
      if(raw is! Map)return '';
      final item=Map<String,dynamic>.from(raw);
      final data=(item['data']??'') as String;
      if(data.isEmpty)return '';
      final extension=((item['extension']??'') as String).isEmpty
          ? PrivateFiles.extensionOf(oldPath)
          : item['extension'] as String;
      final bytes=base64Decode(data);
      final saved=await PrivateFiles.saveBytes(
        Uint8List.fromList(bytes),
        category,
        extension:extension.isEmpty?'.bin':extension,
      );
      restoredPaths[oldPath]=saved;
      return saved;
    }

    for(final rabbit in rabbits){
      rabbit['photo']=await restorePath(((rabbit['photo']??'') as String),'rabbit_photos');
      for(final key in ['healthBook','passport']){
        rabbit[key]=await restorePath(((rabbit[key]??'') as String),'documents');
      }
      for(final key in ['engagementMentionImage','engagementSignatureImage','engagementCertificatePdf']){
        rabbit[key]=await restorePath(((rabbit[key]??'') as String),'documents');
      }
      for(final key in ['vaccines','dewormings']){
        for(final raw in ((rabbit[key] as List?)??[])){
          final item=raw as Map<String,dynamic>;
          item['photo']=await restorePath(((item['photo']??'') as String),'treatments');
        }
      }
      for(final raw in ((rabbit['medications'] as List?)??[])){
        final item=raw as Map<String,dynamic>;
        item['photo']=await restorePath(((item['photo']??'') as String),'treatments');
        item['prescription']=await restorePath(((item['prescription']??'') as String),'documents');
      }
      for(final raw in ((rabbit['competitions'] as List?)??[])){
        final item=raw as Map<String,dynamic>;
        item['photo']=await restorePath(((item['photo']??'') as String),'competitions');
        item['judgingSheet']=await restorePath(((item['judgingSheet']??'') as String),'competitions');
      }
    }

    await Store.save(rabbits);
    await ReproductionStore.save(reproduction);
    await AppModeStore.save((decoded['appMode']??'Éleveur') as String);
    await Notifications.refreshAll(rabbits);
  }
}

class Scenic extends StatelessWidget {
  final Widget child;
  final bool compact;
  final bool home;
  const Scenic({super.key,required this.child,this.compact=false,this.home=false});

  @override Widget build(BuildContext context)=>Stack(
    fit:StackFit.expand,
    children:[
      Positioned.fill(
        child:Image.asset(
          'assets/images/lapigestion_background_master.jpg',
          fit:BoxFit.cover,
          alignment:Alignment.topCenter,
          filterQuality:FilterQuality.high,
        ),
      ),
      Positioned.fill(
        child:IgnorePointer(
          child:Container(color:const Color(0x0DFFF8E8)),
        ),
      ),
      child,
    ],
  );
}

BoxDecoration premiumMarbleDecoration({
  double radius=14,
  bool selected=false,
  bool strong=false,
})=>BoxDecoration(
  color:strong?const Color(0xFF063B28):const Color(0xFF0B5138),
  image:DecorationImage(
    image:const AssetImage('assets/images/lapigestion_green_marble.jpg'),
    fit:BoxFit.cover,
    opacity:strong ? 1.0 : .96,
    colorFilter:ColorFilter.mode(
      strong?const Color(0x10000000):const Color(0x06FFFFFF),
      BlendMode.srcOver,
    ),
  ),
  borderRadius:BorderRadius.circular(radius),
  border:Border.all(color:selected?const Color(0xFFFFE39A):const Color(0xFFF2C85F),width:selected?1.45:.95),
  boxShadow:[
    BoxShadow(
      color:Colors.black.withValues(alpha:selected ? .13 : .07),
      blurRadius:selected?10:7,
      offset:const Offset(0,4),
    ),
    if(selected)BoxShadow(color:gold.withValues(alpha:.13),blurRadius:12),
  ],
);

class PremiumGoldLeaves extends StatelessWidget{
  final double size;
  final double opacity;
  const PremiumGoldLeaves({super.key,this.size=54,this.opacity=.66});
  @override Widget build(BuildContext context)=>IgnorePointer(
    child:Opacity(
      opacity:opacity,
      child:Image.asset(
        'assets/images/lapigestion_gold_leaves.png',
        width:size,
        fit:BoxFit.contain,
        filterQuality:FilterQuality.high,
      ),
    ),
  );
}

class PremiumMarbleButton extends StatelessWidget{
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool selected;
  final EdgeInsetsGeometry padding;
  const PremiumMarbleButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.selected=false,
    this.padding=const EdgeInsets.symmetric(horizontal:16,vertical:13),
  });
  @override Widget build(BuildContext context)=>Opacity(
    opacity:onPressed==null ? .48 : 1,
    child:Material(
      color:Colors.transparent,
      child:InkWell(
        onTap:onPressed,
        borderRadius:BorderRadius.circular(14),
        child:Ink(
          padding:padding,
          decoration:premiumMarbleDecoration(radius:14,selected:selected,strong:true),
          child:Row(
            mainAxisAlignment:MainAxisAlignment.center,
            mainAxisSize:MainAxisSize.min,
            children:[
              Icon(icon,color:selected?warmGoldText:Colors.white,size:21),
              const SizedBox(width:9),
              Flexible(child:Text(
                label,
                textAlign:TextAlign.center,
                style:TextStyle(
                  color:selected?warmGoldText:Colors.white,
                  fontSize:14,
                  fontWeight:FontWeight.w800,
                ),
              )),
            ],
          ),
        ),
      ),
    ),
  );
}


/// Cadre ivoire premium commun à toutes les grandes cartes de l'application.
/// Les ornements sont de vraies images dorées avec reflets, jamais une teinte jaune plate.
class PremiumCard extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final bool semanticContainer;

  const PremiumCard({
    super.key,
    this.child,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground=true,
    this.margin,
    this.clipBehavior=Clip.none,
    this.semanticContainer=true,
  });

  @override
  Widget build(BuildContext context) => m.Card(
    color:color,
    shadowColor:shadowColor,
    surfaceTintColor:surfaceTintColor,
    elevation:elevation,
    shape:shape,
    borderOnForeground:borderOnForeground,
    margin:margin,
    clipBehavior:clipBehavior,
    semanticContainer:semanticContainer,
    child:Stack(
      clipBehavior:Clip.none,
      children:[
        if(child!=null) child!,
        Positioned.fill(
          child:IgnorePointer(
            child:Opacity(
              opacity:.13,
              child:Image.asset(
                'assets/images/lapigestion_gold_corners.png',
                fit:BoxFit.fill,
                filterQuality:FilterQuality.high,
              ),
            ),
          ),
        ),
        Positioned(
          right:-7,
          bottom:-8,
          child:IgnorePointer(
            child:Opacity(
              opacity:.30,
              child:Image.asset(
                'assets/images/lapigestion_gold_corner_volute.png',
                width:58,
                fit:BoxFit.contain,
                filterQuality:FilterQuality.high,
              ),
            ),
          ),
        ),
        Positioned(
          left:-8,
          top:-8,
          child:IgnorePointer(
            child:Opacity(
              opacity:.18,
              child:Image.asset(
                'assets/images/lapigestion_gold_leaves.png',
                width:48,
                fit:BoxFit.contain,
                filterQuality:FilterQuality.high,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child:IgnorePointer(
            child:LayoutBuilder(builder:(context,c){
              if(c.maxHeight<250)return const SizedBox.shrink();
              return Align(
                alignment:Alignment.centerRight,
                child:Opacity(
                  opacity:.075,
                  child:Image.asset(
                    'assets/images/lapigestion_gold_ornament_vertical.png',
                    width:54,
                    height:c.maxHeight*.72,
                    fit:BoxFit.contain,
                    filterQuality:FilterQuality.high,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

/// Bouton primaire premium : vrai marbre vert profond + veines or + reflet doré.
class PremiumFilledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final ButtonStyle? style;

  const PremiumFilledButton({
    super.key,
    required this.onPressed,
    required Widget this.child,
    this.style,
  }):icon=null,label=null;

  const PremiumFilledButton.icon({
    super.key,
    required this.onPressed,
    required Widget this.icon,
    required Widget this.label,
    this.style,
  }):child=null;

  @override
  Widget build(BuildContext context){
    final transparentStyle=ButtonStyle(
      backgroundColor:const WidgetStatePropertyAll(Colors.transparent),
      shadowColor:const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor:const WidgetStatePropertyAll(Colors.transparent),
      side:const WidgetStatePropertyAll(BorderSide(color:Colors.transparent)),
    ).merge(style);
    final native=icon!=null
      ?m.FilledButton.icon(onPressed:onPressed,icon:icon!,label:label!,style:transparentStyle)
      :m.FilledButton(onPressed:onPressed,style:transparentStyle,child:child!);
    return Opacity(
      opacity:onPressed==null ? .48 : 1,
      child:ClipRRect(
        borderRadius:BorderRadius.circular(14),
        child:Stack(
          children:[
            Positioned.fill(child:DecoratedBox(decoration:premiumMarbleDecoration(radius:14,strong:true))),
            Positioned.fill(
              child:IgnorePointer(
                child:Opacity(
                  opacity:.18,
                  child:Image.asset(
                    'assets/images/lapigestion_gold_volute_horizontal.png',
                    fit:BoxFit.cover,
                    alignment:Alignment.center,
                    filterQuality:FilterQuality.high,
                  ),
                ),
              ),
            ),
            native,
          ],
        ),
      ),
    );
  }
}

/// SegmentedButton posé sur le même marbre vert/or afin d'éviter les aplats verts ternes.
class PremiumSegmentedButton<T> extends StatelessWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final void Function(Set<T>)? onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final Widget? selectedIcon;
  final ButtonStyle? style;

  const PremiumSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled=false,
    this.emptySelectionAllowed=false,
    this.showSelectedIcon=true,
    this.selectedIcon,
    this.style,
  });

  @override
  Widget build(BuildContext context)=>ClipRRect(
    borderRadius:BorderRadius.circular(14),
    child:DecoratedBox(
      decoration:premiumMarbleDecoration(radius:14,strong:true),
      child:SegmentedButton<T>(
        segments:segments,
        selected:selected,
        onSelectionChanged:onSelectionChanged,
        multiSelectionEnabled:multiSelectionEnabled,
        emptySelectionAllowed:emptySelectionAllowed,
        showSelectedIcon:showSelectedIcon,
        selectedIcon:selectedIcon,
        style:const ButtonStyle(
          backgroundColor:WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor:WidgetStatePropertyAll(Colors.transparent),
        ).merge(style),
      ),
    ),
  );
}



class VeterinaryService {
  static Future<Position> currentPosition() async {
    final enabled=await Geolocator.isLocationServiceEnabled();
    if(!enabled){
      throw Exception('La localisation est désactivée sur ce téléphone.');
    }

    var permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission=await Geolocator.requestPermission();
    }
    if(permission==LocationPermission.denied){
      throw Exception('Autorisation de localisation refusée.');
    }
    if(permission==LocationPermission.deniedForever){
      throw Exception('La localisation est bloquée pour cette application. Activez-la dans les paramètres du téléphone.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings:const LocationSettings(
        accuracy:LocationAccuracy.high,
        timeLimit:Duration(seconds:15),
      ),
    );
  }

  static bool _nacMention(Map<String,dynamic> tags){
    final text=tags.values.map((e)=>e.toString().toLowerCase()).join(' ');
    const words=[
      'nac',
      'nouveaux animaux de compagnie',
      'exotic',
      'exotique',
      'rabbit',
      'lapin',
      'rongeur',
      'rodent',
      'reptile',
      'avian',
      'oiseau',
    ];
    return words.any(text.contains);
  }

  static String _address(Map<String,dynamic> tags){
    final line=[
      tags['addr:housenumber'],
      tags['addr:street'],
    ].where((e)=>e!=null&&e.toString().trim().isNotEmpty)
      .map((e)=>e.toString().trim()).join(' ');

    final city=[
      tags['addr:postcode'],
      tags['addr:city']??tags['addr:town']??tags['addr:village'],
    ].where((e)=>e!=null&&e.toString().trim().isNotEmpty)
      .map((e)=>e.toString().trim()).join(' ');

    return [line,city].where((e)=>e.isNotEmpty).join(', ');
  }

  static Future<List<Map<String,dynamic>>> searchNearby({
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) async {
    final radius=radiusKm*1000;
    final query='[out:json][timeout:30];('
      'node["amenity"="veterinary"](around:$radius,$latitude,$longitude);'
      'way["amenity"="veterinary"](around:$radius,$latitude,$longitude);'
      'relation["amenity"="veterinary"](around:$radius,$latitude,$longitude);'
      ');out center tags;';

    final response=await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      headers:{'User-Agent':'LapiGestion-LesLapibreizh/1.0'},
      body:{'data':query},
    ).timeout(const Duration(seconds:40));

    if(response.statusCode!=200){
      throw Exception('Le service de recherche vétérinaire est momentanément indisponible.');
    }

    final decoded=jsonDecode(response.body) as Map<String,dynamic>;
    final elements=(decoded['elements'] as List?)??[];
    final result=<Map<String,dynamic>>[];
    final seen=<String>{};

    for(final raw in elements){
      final element=Map<String,dynamic>.from(raw as Map);
      final tags=Map<String,dynamic>.from((element['tags'] as Map?)??{});
      final center=element['center'] is Map
          ?Map<String,dynamic>.from(element['center'] as Map)
          :<String,dynamic>{};

      final latValue=element['lat']??center['lat'];
      final lonValue=element['lon']??center['lon'];
      if(latValue is! num||lonValue is! num)continue;

      final lat=latValue.toDouble();
      final lon=lonValue.toDouble();
      final rawName=(tags['name']??tags['operator']??'Cabinet vétérinaire').toString().trim();
      final name=rawName.isEmpty?'Cabinet vétérinaire':rawName;
      final key='${name.toLowerCase()}|${lat.toStringAsFixed(4)}|${lon.toStringAsFixed(4)}';
      if(!seen.add(key))continue;

      final distance=Geolocator.distanceBetween(latitude,longitude,lat,lon)/1000.0;
      result.add({
        'name':name,
        'lat':lat,
        'lon':lon,
        'distance':distance,
        'address':_address(tags),
        'phone':(tags['contact:phone']??tags['phone']??'').toString(),
        'website':(tags['contact:website']??tags['website']??'').toString(),
        'openingHours':(tags['opening_hours']??'').toString(),
        'emergency':tags['emergency']=='yes',
        'nac':_nacMention(tags),
      });
    }

    result.sort((a,b)=>(a['distance'] as double).compareTo(b['distance'] as double));
    return result;
  }

  static Future<void> call(String phone) async {
    final cleaned=phone.replaceAll(RegExp(r'[^0-9+]'),'');
    if(cleaned.isEmpty)return;
    final uri=Uri.parse('tel:$cleaned');
    if(await canLaunchUrl(uri))await launchUrl(uri);
  }

  static Future<void> openMap(Map<String,dynamic> vet) async {
    final lat=(vet['lat'] as double).toString();
    final lon=(vet['lon'] as double).toString();
    final geo=Uri.parse('geo:$lat,$lon?q=$lat,$lon');
    if(await canLaunchUrl(geo)){
      await launchUrl(geo,mode:LaunchMode.externalApplication);
      return;
    }
    await launchUrl(
      Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lon#map=16/$lat/$lon'),
      mode:LaunchMode.externalApplication,
    );
  }

  static Future<void> openWebsite(String website) async {
    var value=website.trim();
    if(value.isEmpty)return;
    if(!value.startsWith('http://')&&!value.startsWith('https://')){
      value='https://$value';
    }
    final uri=Uri.parse(value);
    if(await canLaunchUrl(uri))await launchUrl(uri,mode:LaunchMode.externalApplication);
  }
}

class VeterinaryResultsPage extends StatelessWidget {
  final List<Map<String,dynamic>> vets;
  final String filter;
  final int radiusKm;

  const VeterinaryResultsPage({
    super.key,
    required this.vets,
    required this.filter,
    required this.radiusKm,
  });

  @override Widget build(BuildContext context){
    final visible=filter=='NAC'
        ?vets.where((v)=>v['nac']==true).toList()
        :vets;

    return Scaffold(
      appBar:AppBar(
        title:Text(filter=='NAC'?'Vétérinaires NAC identifiés':'Vétérinaires autour de moi'),
      ),
      body:visible.isEmpty
        ?Center(child:Padding(
            padding:const EdgeInsets.all(24),
            child:Text(
              filter=='NAC'
                ?'Aucun vétérinaire mentionnant explicitement les NAC n’a été identifié dans un rayon de $radiusKm km. Essayez le filtre Tous et appelez le cabinet pour confirmer la prise en charge des lapins.'
                :'Aucun vétérinaire n’a été trouvé dans ce rayon.',
              textAlign:TextAlign.center,
            ),
          ))
        :ListView.builder(
            padding:const EdgeInsets.all(14),
            itemCount:visible.length,
            itemBuilder:(context,index){
              final vet=visible[index];
              final phone=(vet['phone']??'').toString();
              final website=(vet['website']??'').toString();
              final address=(vet['address']??'').toString();
              final hours=(vet['openingHours']??'').toString();

              return PremiumCard(
                child:Padding(
                  padding:const EdgeInsets.all(14),
                  child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Container(
                        width:42,height:42,
                        decoration:BoxDecoration(color:gold.withValues(alpha:.16),shape:BoxShape.circle),
                        child:const Icon(Icons.local_hospital,color:brown),
                      ),
                      const SizedBox(width:10),
                      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text(
                          (vet['name']??'Cabinet vétérinaire').toString(),
                          style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:ink),
                        ),
                        Text(
                          '${(vet['distance'] as double).toStringAsFixed(1).replaceAll('.',',')} km',
                          style:const TextStyle(fontWeight:FontWeight.w800,color:brown),
                        ),
                      ])),
                      if(vet['nac']==true)
                        Container(
                          padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
                          decoration:BoxDecoration(
                            color:const Color(0xFF2E7A55).withValues(alpha:.12),
                            borderRadius:BorderRadius.circular(10),
                          ),
                          child:const Text(
                            'NAC mentionné',
                            style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:Color(0xFF2E7D32)),
                          ),
                        ),
                    ]),
                    if(address.isNotEmpty)...[
                      const SizedBox(height:8),
                      Text(address),
                    ],
                    if(hours.isNotEmpty)...[
                      const SizedBox(height:5),
                      Text('Horaires : $hours',style:const TextStyle(fontSize:12,color:Colors.black54)),
                    ],
                    if(vet['emergency']==true)...[
                      const SizedBox(height:6),
                      const Text(
                        'Urgences indiquées par le cabinet',
                        style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:Color(0xFFC62828)),
                      ),
                    ],
                    const SizedBox(height:10),
                    Wrap(spacing:7,runSpacing:7,children:[
                      OutlinedButton.icon(
                        onPressed:()=>VeterinaryService.openMap(vet),
                        icon:const Icon(Icons.directions),
                        label:const Text('Itinéraire'),
                      ),
                      if(phone.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed:()=>VeterinaryService.call(phone),
                          icon:const Icon(Icons.call),
                          label:const Text('Appeler'),
                        ),
                      if(website.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed:()=>VeterinaryService.openWebsite(website),
                          icon:const Icon(Icons.language),
                          label:const Text('Site'),
                        ),
                    ]),
                  ]),
                ),
              );
            },
          ),
    );
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage>{
  List<Map<String,dynamic>> rabbits=[]; List<Map<String,dynamic>> breedings=[]; bool loading=true; String appMode='Éleveur';
  String searchQuery=''; String sexFilter='Tous'; String adoptionFilter='Tous';
  String desiredBreed='Géant Papillon Français'; String desiredColor='Noir'; int reproMaxLitters=4; int reproRestDays=90;
  bool homeOrganizing=false; bool homeLayoutLoaded=false;
  bool vetLoading=false; String vetError=''; int vetRadiusKm=20; String vetFilter='Tous';
  List<Map<String,dynamic>> nearbyVets=[];
  List<String> homeOrder=['dashboard','colors','vets','backup','filters','rabbits'];
  static const homeDefaults=['dashboard','colors','vets','backup','filters','rabbits'];

  final GlobalKey _homeTopKey=GlobalKey();
  final GlobalKey _dashboardKey=GlobalKey();
  final GlobalKey _colorsKey=GlobalKey();
  final GlobalKey _vetsKey=GlobalKey();
  final GlobalKey _backupKey=GlobalKey();
  final GlobalKey _rabbitsKey=GlobalKey();

  GlobalKey? _homeKeyFor(String id){
    switch(id){
      case 'dashboard': return _dashboardKey;
      case 'colors': return _colorsKey;
      case 'vets': return _vetsKey;
      case 'backup': return _backupKey;
      case 'rabbits': return _rabbitsKey;
      default: return null;
    }
  }

  Future<void> _jumpToHome(String id) async {
    if(homeOrganizing)return;
    final key=id=='top'?_homeTopKey:_homeKeyFor(id);
    final context=key?.currentContext;
    if(context==null)return;
    await Scrollable.ensureVisible(
      context,
      duration:const Duration(milliseconds:420),
      curve:Curves.easeOutCubic,
      alignment:.02,
    );
  }

  void _showMoreMenu(){
    if(homeOrganizing)return;
    showModalBottomSheet(
      context:context,
      showDragHandle:true,
      builder:(sheetContext)=>SafeArea(
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          const ListTile(
            title:Text('Plus',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
            subtitle:Text('Accès rapide aux fonctions moins utilisées au quotidien.'),
          ),
          ListTile(
            leading:const Icon(Icons.location_on_outlined,color:lapiGreen),
            title:const Text('Vétérinaires & urgence'),
            onTap:(){Navigator.pop(sheetContext);Future.delayed(const Duration(milliseconds:120),()=>_jumpToHome('vets'));},
          ),
          ListTile(
            leading:const Icon(Icons.shield_outlined,color:lapiGreen),
            title:const Text('Sauvegarde & restauration'),
            onTap:(){Navigator.pop(sheetContext);Future.delayed(const Duration(milliseconds:120),()=>_jumpToHome('backup'));},
          ),
          ListTile(
            leading:const Icon(Icons.tune,color:lapiGreen),
            title:const Text('Organiser l’accueil'),
            onTap:(){Navigator.pop(sheetContext);setState(()=>homeOrganizing=true);},
          ),
          const SizedBox(height:8),
        ]),
      ),
    );
  }

  Widget _bottomShortcut({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected=false,
  })=>Expanded(
    child:InkWell(
      onTap:homeOrganizing?null:onTap,
      child:Padding(
        padding:const EdgeInsets.symmetric(vertical:7),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          Icon(
            icon,
            size:23,
            color:homeOrganizing?Colors.white38:(selected?gold:Colors.white),
          ),
          const SizedBox(height:2),
          Text(
            label,
            style:TextStyle(
              fontSize:11,
              fontWeight:selected?FontWeight.w800:FontWeight.w600,
              color:homeOrganizing?Colors.white38:(selected?gold:Colors.white),
              fontFamily:selected?'serif':null,
            ),
          ),
          if(selected)...[
            const SizedBox(height:3),
            Container(width:26,height:2,decoration:BoxDecoration(color:gold,borderRadius:BorderRadius.circular(99))),
          ],
        ]),
      ),
    ),
  );

  Widget _bottomNavigation()=>Material(
    color:heroGreen,
    elevation:16,
    shadowColor:Colors.black.withValues(alpha:.18),
    child:SafeArea(
      top:false,
      child:Container(
        decoration:BoxDecoration(
          color:heroGreen,
          image:const DecorationImage(
            image:AssetImage('assets/images/lapigestion_green_marble.jpg'),
            fit:BoxFit.cover,
            opacity:.96,
          ),
          border:const Border(top:BorderSide(color:gold,width:1.1)),
          boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.18),blurRadius:14,offset:const Offset(0,-4))],
        ),
        child:Stack(children:[
          Positioned.fill(child:IgnorePointer(child:Opacity(opacity:.14,child:Image.asset('assets/images/lapigestion_gold_corners.png',fit:BoxFit.fill,filterQuality:FilterQuality.high)))),
          const Positioned(left:-5,bottom:-9,child:PremiumGoldLeaves(size:52,opacity:.72)),
          Positioned(right:-5,bottom:-9,child:Transform.flip(flipX:true,child:const PremiumGoldLeaves(size:52,opacity:.72))),
          Row(children:[
          _bottomShortcut(icon:Icons.home_outlined,label:'Accueil',selected:true,onTap:()=>_jumpToHome('top')),
          _bottomShortcut(icon:Icons.pets_outlined,label:'Mes lapins',onTap:()=>_jumpToHome('rabbits')),
          _bottomShortcut(icon:Icons.notifications_none,label:'Rappels',onTap:()=>_jumpToHome('dashboard')),
          _bottomShortcut(icon:Icons.more_horiz,label:'Plus',onTap:_showMoreMenu),
        ]),
        ]),
      ),
    ),
  );
  @override void initState(){super.initState();refresh();}
  Future<void> refresh() async {
    rabbits=await Store.load();
    breedings=await ReproductionStore.load();
    appMode=await AppModeStore.load();
    final reproSettings=await ReproductionSettingsStore.load();
    reproMaxLitters=reproSettings['maxLitters']??4;
    reproRestDays=reproSettings['restDays']??90;
    final knownBreeds=RabbitBreedCatalog.racesFor();
    if(!knownBreeds.contains(desiredBreed)){
      desiredBreed=knownBreeds.contains('Géant Papillon Français')?'Géant Papillon Français':(knownBreeds.isNotEmpty?knownBreeds.first:'');
    }
    final desiredColors=RabbitBreedCatalog.colorsFor(desiredBreed)
        .map((e)=>(e['name']??'').toString())
        .where((c)=>c.isNotEmpty&&c!='Non déterminé'&&c!='Autre / non standard')
        .toList();
    if(!desiredColors.contains(desiredColor))desiredColor=desiredColors.isNotEmpty?desiredColors.first:'';
    if(!homeLayoutLoaded){
      homeOrder=await LayoutStore.load('home',homeDefaults);
      homeLayoutLoaded=true;
    }
    await Notifications.refreshAll(rabbits);
    if(mounted)setState(()=>loading=false);
  }
  Future<void> setAppMode(String mode) async {await AppModeStore.save(mode);if(mounted)setState(()=>appMode=mode);}
  Future<void> addRabbit() async { final r=emptyRabbit(); rabbits.add(r); await Store.save(rabbits); if(!mounted)return; await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:rabbits.length-1))); await refresh(); }

  DateTime? _nextTreatmentDue(Map<String,dynamic> item){
    final months=(item['reminderMonths']??0) as int;
    final date=Notifications.parseDate(item['date'] as String?);
    if(months<=0||date==null)return null;
    var due=Notifications.addMonths(date,months);
    while(due.isBefore(DateTime.now()))due=Notifications.addMonths(due,months);
    return due;
  }

  int _healthRemindersSoon(){
    final now=DateTime.now();
    final limit=now.add(const Duration(days:30));
    var count=0;
    for(final rabbit in rabbits){
      for(final key in ['vaccines','dewormings']){
        for(final raw in ((rabbit[key] as List?)??[])){
          final due=_nextTreatmentDue(Map<String,dynamic>.from(raw as Map));
          if(due!=null&&!due.isAfter(limit))count++;
        }
      }
    }
    return count;
  }

  int _upcomingAppointments(){
    final now=DateTime.now();
    var count=0;
    for(final rabbit in rabbits){
      for(final raw in ((rabbit['appointments'] as List?)??[])){
        final a=Map<String,dynamic>.from(raw as Map);
        final d=Notifications.parseDate(a['date'] as String?);
        if(d==null)continue;
        final parts=((a['time']??'09:00') as String).split(':');
        final dt=DateTime(d.year,d.month,d.day,int.tryParse(parts[0])??9,parts.length>1?int.tryParse(parts[1])??0:0);
        if(dt.isAfter(now))count++;
      }
    }
    return count;
  }

  Map<String,dynamic>? _nextAppointment(){
    final now=DateTime.now();
    Map<String,dynamic>? best;
    DateTime? bestDate;
    for(var i=0;i<rabbits.length;i++){
      final rabbit=rabbits[i];
      for(final raw in ((rabbit['appointments'] as List?)??[])){
        final a=Map<String,dynamic>.from(raw as Map);
        final d=Notifications.parseDate(a['date'] as String?);
        if(d==null)continue;
        final parts=((a['time']??'09:00') as String).split(':');
        final dt=DateTime(d.year,d.month,d.day,int.tryParse(parts[0])??9,parts.length>1?int.tryParse(parts[1])??0:0);
        if(!dt.isAfter(now))continue;
        if(bestDate==null||dt.isBefore(bestDate)){
          bestDate=dt;
          best={'rabbitIndex':i,'rabbitName':((rabbit['name']??'') as String).trim().isEmpty?'Lapin sans nom':rabbit['name'],'appointment':a,'date':dt};
        }
      }
    }
    return best;
  }

  int _reservedCount()=>rabbits.where((r)=>r['adoptionStatus']=='Réservé').length;

  int _incompleteCount(){
    var count=0;
    for(final r in rabbits){
      final missing=[
        r['name'],r['sex'],r['breed'],r['color'],r['birth'],
      ].where((v)=>(v??'').toString().trim().isEmpty).length;
      if(missing>0)count++;
    }
    return count;
  }

  List<MapEntry<int,Map<String,dynamic>>> _filteredRabbits(){
    final q=searchQuery.trim().toLowerCase();
    return rabbits.asMap().entries.where((entry){
      final r=entry.value;
      final haystack=[
        r['name'],r['breed'],r['color'],r['identification'],r['tattoo'],r['fatherName'],r['motherName']
      ].map((e)=>(e??'').toString().toLowerCase()).join(' ');
      if(q.isNotEmpty&&!haystack.contains(q))return false;
      if(sexFilter!='Tous'&&r['sex']!=sexFilter)return false;
      if(appMode=='Éleveur'&&adoptionFilter!='Tous'&&r['adoptionStatus']!=adoptionFilter)return false;
      return true;
    }).toList();
  }

  Widget _dashStat(String label,String value,IconData icon,Color color){
    return Container(
      width:148,
      padding:const EdgeInsets.symmetric(horizontal:14,vertical:14),
      decoration:BoxDecoration(
        color:color.withValues(alpha:.075),
        borderRadius:BorderRadius.circular(16),
        border:Border(left:BorderSide(color:color,width:4),top:const BorderSide(color:lineSoft),right:const BorderSide(color:lineSoft),bottom:const BorderSide(color:lineSoft)),
        boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.03), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Icon(icon,color:color,size:19),
          const Spacer(),
          Text(value,style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:color,height:1)),
        ]),
        const SizedBox(height:8),
        Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:ink)),
      ]),
    );
  }


  Map<String,dynamic>? _rabbitById(String id){
    final m=rabbits.where((r)=>r['id']==id);
    return m.isEmpty ? null : m.first;
  }

  String _homeRabbitName(String id){
    final r=_rabbitById(id);
    final n=(r?['name']??'').toString().trim();
    return n.isEmpty?'Lapin sans nom':n;
  }

  Widget _homeRabbitMini(String id){
    final rabbit=_rabbitById(id);
    final provider=fileImage(rabbit?['photo']);
    return Column(mainAxisSize:MainAxisSize.min,children:[
      Container(
        width:44,height:44,
        decoration:BoxDecoration(
          shape:BoxShape.circle,
          color:gold.withValues(alpha:.12),
          border:Border.all(color:gold.withValues(alpha:.72)),
          image:provider==null ? null : DecorationImage(image:provider,fit:BoxFit.cover),
        ),
        child:provider==null ? const Icon(Icons.pets,color:lapiGreenDark,size:20):null,
      ),
      const SizedBox(height:3),
      SizedBox(width:92,child:Text(_homeRabbitName(id),maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800))),
    ]);
  }

  bool _femaleHasActiveTreatment(Map<String,dynamic> female){
    final today=DateTime.now();
    for(final raw in ((female['medications'] as List?)??[])){
      final med=Map<String,dynamic>.from(raw as Map);
      final start=Notifications.parseDate(med['startDate'] as String?);
      final end=Notifications.parseDate(med['endDate'] as String?);
      if(start==null)continue;
      final startDay=DateTime(start.year,start.month,start.day);
      final endDay=end==null?null:DateTime(end.year,end.month,end.day,23,59);
      if(!startDay.isAfter(today)&&(endDay==null||!endDay.isBefore(today)))return true;
    }
    return false;
  }

  bool _femaleAvailableForReproduction(String femaleId){
    final female=_rabbitById(femaleId);
    if(female==null)return false;
    if(_femaleHasActiveTreatment(female))return false;
    final now=DateTime.now();
    final cutoff=now.subtract(const Duration(days:365));
    final femaleRecords=breedings.where((b)=>b['femaleId']==femaleId).toList();
    final births=femaleRecords.map((b)=>Notifications.parseDate(b['birthDate'] as String?)).whereType<DateTime>().toList();
    final count12m=births.where((d)=>!d.isBefore(cutoff)).length;
    if(count12m>=reproMaxLitters)return false;
    if(reproRestDays>0&&births.isNotEmpty){
      births.sort();
      final last=births.last;
      if(now.difference(last).inDays<reproRestDays)return false;
    }
    return true;
  }

  String _homePairBreed(String maleId,String femaleId){
    final male=_rabbitById(maleId);
    final female=_rabbitById(femaleId);
    final a=(male?['breed']??'').toString().trim();
    final b=(female?['breed']??'').toString().trim();
    if(a.isNotEmpty&&b.isNotEmpty&&a==b)return a;
    if(a.isNotEmpty&&b.isNotEmpty&&a!=b)return 'Croisé';
    if(a.isNotEmpty)return a;
    if(b.isNotEmpty)return b;
    return '';
  }

  List<Map<String,dynamic>> _colorRecommendations(){
    final groups=<String,List<Map<String,dynamic>>>{};
    for(final b in breedings){
      final maleId=(b['maleId']??'').toString();
      final femaleId=(b['femaleId']??'').toString();
      if(maleId.isEmpty||femaleId.isEmpty)continue;
      groups.putIfAbsent('$maleId|$femaleId',()=>[]).add(b);
    }
    final out=<Map<String,dynamic>>[];
    for(final entry in groups.entries){
      final ids=entry.key.split('|');
      final maleId=ids[0],femaleId=ids[1];
      if(!_femaleAvailableForReproduction(femaleId))continue;
      final pairBreed=_homePairBreed(maleId,femaleId);
      if(desiredBreed.isNotEmpty&&pairBreed!=desiredBreed)continue;
      final colors=ReproductionStore.aggregateColors(entry.value);
      final selected=colors.where((c)=>c['color']==desiredColor);
      if(selected.isEmpty)continue;
      final hit=selected.first;
      final colorCount=ReproductionStore.n(hit['male'])+ReproductionStore.n(hit['female']);
      if(colorCount<=0)continue;
      final total=entry.value.fold<int>(0,(sum,b)=>sum+ReproductionStore.n(ReproductionStore.totals(b)['born']));
      if(total<=0)continue;
      out.add({
        'maleId':maleId,
        'femaleId':femaleId,
        'count':colorCount,
        'male':ReproductionStore.n(hit['male']),
        'female':ReproductionStore.n(hit['female']),
        'total':total,
        'litters':entry.value.length,
        'rate':colorCount/total,
      });
    }
    out.sort((a,b){
      final rate=(b['rate'] as double).compareTo(a['rate'] as double);
      if(rate!=0)return rate;
      return ReproductionStore.n(b['count']).compareTo(ReproductionStore.n(a['count']));
    });
    return out;
  }

  Future<void> _saveReproSettings({int? maxLitters,int? restDays}) async {
    final newMax=maxLitters??reproMaxLitters;
    final newRest=restDays??reproRestDays;
    await ReproductionSettingsStore.save(maxLitters:newMax,restDays:newRest);
    if(!mounted)return;
    setState((){reproMaxLitters=newMax;reproRestDays=newRest;});
  }

  Future<void> _chooseDesiredBreed() async {
    final selected=await showDialog<String>(
      context:context,
      builder:(_)=>RacePickerDialog(initial:desiredBreed,title:'Race recherchée'),
    );
    if(selected==null)return;
    final colors=RabbitBreedCatalog.colorsFor(selected)
        .map((e)=>(e['name']??'').toString())
        .where((c)=>c.isNotEmpty&&c!='Non déterminé'&&c!='Autre / non standard')
        .toList();
    if(!mounted)return;
    setState((){
      desiredBreed=selected;
      desiredColor=colors.isNotEmpty?colors.first:'';
    });
  }

  Future<void> _chooseDesiredColor() async {
    if(desiredBreed.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez d’abord la race.')));
      return;
    }
    final selected=await showDialog<String>(
      context:context,
      builder:(_)=>BreedColorPickerDialog(breed:desiredBreed,initial:desiredColor),
    );
    if(selected==null||selected=='Non déterminé'||selected=='Autre / non standard')return;
    if(mounted)setState(()=>desiredColor=selected);
  }

  Widget colorPlannerSection(){
    final results=_colorRecommendations();
    return Padding(
      padding:const EdgeInsets.fromLTRB(14,0,14,10),
      child:PremiumCard(child:Padding(
        padding:const EdgeInsets.all(12),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            const Icon(Icons.palette_outlined,color:lapiGreenDark),
            const SizedBox(width:8),
            const Expanded(child:Text('Je recherche une couleur',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:ink,fontFamily:'serif'))),
          ]),
          const SizedBox(height:4),
          const Text('LapiGestion compare uniquement vos résultats réellement enregistrés. Il ne garantit pas la couleur d’une future portée.',style:TextStyle(fontSize:10.5,color:Colors.black54)),
          const SizedBox(height:10),
          InkWell(
            borderRadius:BorderRadius.circular(12),
            onTap:_chooseDesiredBreed,
            child:InputDecorator(
              decoration:const InputDecoration(labelText:'Race recherchée',suffixIcon:Icon(Icons.arrow_drop_down)),
              child:Text(
                desiredBreed.isEmpty?'Sélectionner une race':desiredBreed,
                style:TextStyle(color:desiredBreed.isEmpty?Colors.black54:ink,fontWeight:FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height:10),
          InkWell(
            borderRadius:BorderRadius.circular(12),
            onTap:_chooseDesiredColor,
            child:InputDecorator(
              decoration:const InputDecoration(labelText:'Couleur / variété recherchée',suffixIcon:Icon(Icons.arrow_drop_down)),
              child:Row(children:[
                if(RabbitBreedCatalog.isStandard(desiredBreed,desiredColor))...[const Text('🏅'),const SizedBox(width:6)],
                Expanded(child:Text(
                  desiredColor.isEmpty?'Sélectionner une couleur / variété':desiredColor,
                  style:TextStyle(color:desiredColor.isEmpty?Colors.black54:ink,fontWeight:FontWeight.w700),
                )),
              ]),
            ),
          ),
          const SizedBox(height:4),
          const Text('🏅 = variété reconnue au standard de la race',style:TextStyle(fontSize:10,color:Colors.black54)),
          const SizedBox(height:10),
          Row(children:[
            Expanded(child:DropdownButtonFormField<int>(
              value:reproMaxLitters,
              decoration:const InputDecoration(labelText:'Portées max / 12 mois'),
              items:List.generate(6,(i)=>DropdownMenuItem(value:i+1,child:Text('${i+1}'))),
              onChanged:(v){if(v!=null)_saveReproSettings(maxLitters:v);},
            )),
            const SizedBox(width:8),
            Expanded(child:DropdownButtonFormField<int>(
              value:[30,45,60,90,120,180].contains(reproRestDays)?reproRestDays:90,
              decoration:const InputDecoration(labelText:'Repos minimum'),
              items:const [
                DropdownMenuItem(value:30,child:Text('30 j')),
                DropdownMenuItem(value:45,child:Text('45 j')),
                DropdownMenuItem(value:60,child:Text('60 j')),
                DropdownMenuItem(value:90,child:Text('90 j')),
                DropdownMenuItem(value:120,child:Text('120 j')),
                DropdownMenuItem(value:180,child:Text('180 j')),
              ],
              onChanged:(v){if(v!=null)_saveReproSettings(restDays:v);},
            )),
          ]),
          const SizedBox(height:9),
          const Text('Les femelles sous traitement actif, au repos ou ayant atteint le quota annuel sont automatiquement écartées.',style:TextStyle(fontSize:10.5,color:Colors.black54,fontWeight:FontWeight.w700)),
          const SizedBox(height:12),
          if(results.isEmpty)
            Container(
              padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:gold.withValues(alpha:.07),borderRadius:BorderRadius.circular(13)),
              child:Text('Aucun croisement « $desiredBreed » actuellement disponible n’a encore produit « $desiredColor » dans les données enregistrées.',textAlign:TextAlign.center,style:const TextStyle(color:Colors.black54)),
            )
          else...results.take(5).map((item){
            final rate=((item['rate'] as double)*100).round();
            return Container(
              margin:const EdgeInsets.only(bottom:9),
              padding:const EdgeInsets.all(9),
              decoration:BoxDecoration(color:gold.withValues(alpha:.07),borderRadius:BorderRadius.circular(14),border:Border.all(color:gold.withValues(alpha:.45))),
              child:Column(children:[
                Row(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
                  _homeRabbitMini(item['maleId'] as String),
                  const Padding(padding:EdgeInsets.fromLTRB(7,14,7,0),child:Text('×',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:gold))),
                  _homeRabbitMini(item['femaleId'] as String),
                ]),
                const SizedBox(height:5),
                Text('${item['count']} $desiredColor sur ${item['total']} lapereaux • $rate % observés',textAlign:TextAlign.center,style:const TextStyle(fontSize:11.5,fontWeight:FontWeight.w900,color:brown)),
                Text(desiredBreed,style:const TextStyle(fontSize:10,color:Colors.black54,fontWeight:FontWeight.w700)),
                Text('♂ ${item['male']} • ♀ ${item['female']} • ${item['litters']} portée${item['litters']==1 ? '' : 's'}',style:const TextStyle(fontSize:10.5,color:Colors.black54)),
              ]),
            );
          }),
        ]),
      )),
    );
  }

  List<String> get visibleHomeOrder=>homeOrder.where((id){
    if(id=='colors'&&appMode!='Éleveur')return false;
    if(id=='dashboard'||id=='filters')return rabbits.isNotEmpty;
    return true;
  }).toList();

  Future<void> toggleHomeOrganizing(bool value) async {
    if(value){
      setState(()=>homeOrganizing=true);
      return;
    }
    await LayoutStore.save('home',homeOrder,homeDefaults);
    if(!mounted)return;
    setState(()=>homeOrganizing=false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nouvel ordre enregistré.')));
  }

  void reorderHome(int oldIndex,int newIndex){
    final visible=visibleHomeOrder;
    if(newIndex>oldIndex)newIndex--;
    final moved=visible.removeAt(oldIndex);
    visible.insert(newIndex,moved);
    final visibleSet=visibleHomeOrder.toSet();
    final queue=List<String>.from(visible);
    final updated=<String>[];
    for(final id in homeOrder){
      if(visibleSet.contains(id)){
        updated.add(queue.removeAt(0));
      }else{
        updated.add(id);
      }
    }
    setState(()=>homeOrder=updated);
  }

  Widget homeOrganizeControl()=>Padding(
    padding:const EdgeInsets.fromLTRB(14,0,14,8),
    child:Stack(children:[
      Container(
      padding:const EdgeInsets.fromLTRB(12,7,10,7),
      decoration:BoxDecoration(
        color:homeOrganizing?const Color(0xF4EEF6ED):premiumCard,
        borderRadius:BorderRadius.circular(14),
        border:Border.all(color:homeOrganizing?gold:softGoldLine,width:homeOrganizing?1.15:.9),
        boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.055),blurRadius:12,offset:const Offset(0,5))],
      ),
      child:Row(children:[
        Container(
          width:34,height:34,
          decoration:BoxDecoration(color:const Color(0xFFE8F3EC),borderRadius:BorderRadius.circular(5)),
          child:Icon(homeOrganizing?Icons.drag_indicator:Icons.tune,color:lapiGreenDark,size:20),
        ),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Organiser',style:TextStyle(fontWeight:FontWeight.w900,color:ink)),
          Text(
            homeOrganizing
              ?'Maintenez un cadre appuyé pour le déplacer.'
              :'Personnalisez l’ordre de vos cadres.',
            style:const TextStyle(fontSize:10,color:Colors.black54),
          ),
        ])),
        Switch(value:homeOrganizing,onChanged:toggleHomeOrganizing),
      ]),
      ),
      const Positioned(right:4,bottom:0,child:PremiumGoldLeaves(size:38,opacity:.48)),
    ]),
  );

  Widget homeSection(String id){
    Widget section;
    switch(id){
      case 'dashboard': section=dashboard(); break;
      case 'colors': section=colorPlannerSection(); break;
      case 'vets': section=veterinarySearchSection(); break;
      case 'backup': section=backupSection(); break;
      case 'filters': section=searchAndFilters(); break;
      case 'rabbits': section=rabbitListSection(); break;
      default: section=const SizedBox.shrink();
    }
    final anchor=_homeKeyFor(id);
    return anchor==null?section:KeyedSubtree(key:anchor,child:section);
  }

  Widget homeFrame(String id,int index,Widget child){
    final content=AbsorbPointer(
      absorbing:homeOrganizing,
      child:child,
    );
    return homeOrganizing
        ?ReorderableDelayedDragStartListener(
            key:ValueKey('home_$id'),
            index:index,
            child:content,
          )
        :KeyedSubtree(key:ValueKey('home_$id'),child:content);
  }


  Future<void> _chooseCustomVetRadius() async {
    final controller=TextEditingController(text:vetRadiusKm.toString());
    final value=await showDialog<int>(
      context:context,
      builder:(c)=>AlertDialog(
        title:const Text('Rayon de recherche'),
        content:TextField(
          controller:controller,
          keyboardType:TextInputType.number,
          autofocus:true,
          decoration:const InputDecoration(
            labelText:'Distance en kilomètres',
            hintText:'Ex. 35',
          ),
        ),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Annuler')),
          PremiumFilledButton(
            onPressed:(){
              final n=int.tryParse(controller.text.trim());
              if(n==null||n<1||n>200){
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(content:Text('Choisissez une distance entre 1 et 200 km.')),
                );
                return;
              }
              Navigator.pop(c,n);
            },
            child:const Text('Valider'),
          ),
        ],
      ),
    );
    controller.dispose();
    if(value!=null&&mounted)setState(()=>vetRadiusKm=value);
  }

  Future<void> _searchVeterinarians() async {
    if(vetLoading)return;
    setState((){
      vetLoading=true;
      vetError='';
    });

    try{
      final position=await VeterinaryService.currentPosition();
      final found=await VeterinaryService.searchNearby(
        latitude:position.latitude,
        longitude:position.longitude,
        radiusKm:vetRadiusKm,
      );
      if(!mounted)return;
      setState((){
        nearbyVets=found;
        vetLoading=false;
        vetError=found.isEmpty?'Aucun vétérinaire trouvé dans ce rayon.':'';
      });
    }catch(e){
      if(!mounted)return;
      setState((){
        vetLoading=false;
        vetError='La recherche n’a pas pu aboutir. Vérifiez votre connexion puis réessayez.';
      });
    }
  }

  List<Map<String,dynamic>> get _visibleNearbyVets=>
      vetFilter=='NAC'?nearbyVets.where((v)=>v['nac']==true).toList():nearbyVets;

  Widget veterinarySearchSection(){
    final visible=_visibleNearbyVets;

    return PremiumCard(
      margin:const EdgeInsets.fromLTRB(14,0,14,10),
      child:Stack(children:[
        const Positioned(right:0,top:0,child:PremiumGoldLeaves(size:46,opacity:.48)),
        Padding(
        padding:const EdgeInsets.all(12),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            Container(
              width:36,height:36,
              decoration:BoxDecoration(color:const Color(0xFFE8F3EC),borderRadius:BorderRadius.circular(6)),
              child:const Icon(Icons.location_on_outlined,color:lapiGreenDark),
            ),
            const SizedBox(width:10),
            const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Trouver un vétérinaire',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif')),
              Text('Recherche autour de votre position',style:TextStyle(fontSize:11,color:Colors.black54)),
            ])),
          ]),
          const SizedBox(height:9),

          const Text('Type de vétérinaire',style:TextStyle(fontWeight:FontWeight.w800,color:ink)),
          const SizedBox(height:5),
          PremiumSegmentedButton<String>(
            segments:const [
              ButtonSegment(value:'Tous',label:Text('Tous'),icon:Icon(Icons.local_hospital)),
              ButtonSegment(value:'NAC',label:Text('NAC'),icon:Icon(Icons.pets)),
            ],
            selected:{vetFilter},
            onSelectionChanged:(value)=>setState(()=>vetFilter=value.first),
          ),

          const SizedBox(height:9),
          Row(children:[
            const Expanded(child:Text('Rayon de recherche',style:TextStyle(fontWeight:FontWeight.w800,color:ink))),
            Text('$vetRadiusKm km',style:const TextStyle(fontWeight:FontWeight.w900,color:brown)),
          ]),
          const SizedBox(height:5),
          Wrap(
            spacing:6,
            runSpacing:6,
            children:[
              for(final km in const [10,20,30,50,100])
                ChoiceChip(
                  label:Text(
                    '$km km',
                    style:TextStyle(
                      color:vetRadiusKm==km?warmGoldText:Colors.white,
                      fontWeight:FontWeight.w800,
                    ),
                  ),
                  selected:vetRadiusKm==km,
                  backgroundColor:heroGreen2,
                  selectedColor:heroGreen,
                  checkmarkColor:warmGoldText,
                  side:BorderSide(color:vetRadiusKm==km?gold:Colors.white24),
                  onSelected:(_)=>setState(()=>vetRadiusKm=km),
                ),
              ActionChip(
                avatar:const Icon(Icons.edit,size:17,color:Colors.white),
                label:const Text('Autre',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),
                backgroundColor:heroGreen2,
                side:const BorderSide(color:Colors.white24),
                onPressed:_chooseCustomVetRadius,
              ),
            ],
          ),

          const SizedBox(height:9),
          PremiumFilledButton.icon(
            onPressed:vetLoading?null:_searchVeterinarians,
            icon:vetLoading
              ?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2))
              :const Icon(Icons.my_location),
            label:Text(vetLoading?'Recherche en cours...':'Rechercher autour de moi'),
          ),

          if(vetError.isNotEmpty)...[
            const SizedBox(height:10),
            Container(
              padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(
                color:gold.withValues(alpha:.07),
                borderRadius:BorderRadius.circular(6),
                border:Border.all(color:softGoldLine),
              ),
              child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                const Icon(Icons.wifi_off_outlined,color:lapiGreenDark,size:20),
                const SizedBox(width:9),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  const Text('Recherche momentanément indisponible',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:lapiGreenDark)),
                  const SizedBox(height:3),
                  Text(vetError,style:const TextStyle(fontSize:11,color:brown)),
                  const SizedBox(height:5),
                  TextButton.icon(
                    onPressed:vetLoading?null:_searchVeterinarians,
                    icon:const Icon(Icons.refresh,size:17),
                    label:const Text('Réessayer'),
                  ),
                ])),
              ]),
            ),
          ],

          if(nearbyVets.isNotEmpty)...[
            const SizedBox(height:12),
            Container(
              padding:const EdgeInsets.all(11),
              decoration:BoxDecoration(color:gold.withValues(alpha:.09),borderRadius:BorderRadius.circular(13)),
              child:Row(children:[
                const Icon(Icons.search,color:brown),
                const SizedBox(width:8),
                Expanded(child:Text(
                  vetFilter=='NAC'
                    ?'${visible.length} vétérinaire(s) avec mention NAC identifié(s) sur ${nearbyVets.length} résultat(s)'
                    :'${nearbyVets.length} vétérinaire(s) trouvé(s) dans un rayon de $vetRadiusKm km',
                  style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800),
                )),
              ]),
            ),
            const SizedBox(height:9),

            if(visible.isNotEmpty)
              ...visible.take(3).map((vet)=>ListTile(
                dense:true,
                contentPadding:EdgeInsets.zero,
                leading:const CircleAvatar(
                  backgroundColor:Color(0x1AD4AF67),
                  child:Icon(Icons.local_hospital,color:brown,size:19),
                ),
                title:Text(
                  (vet['name']??'Cabinet vétérinaire').toString(),
                  maxLines:1,
                  overflow:TextOverflow.ellipsis,
                  style:const TextStyle(fontWeight:FontWeight.w800),
                ),
                subtitle:Text(
                  '${(vet['distance'] as double).toStringAsFixed(1).replaceAll('.',',')} km'
                  '${vet['nac']==true?' • NAC mentionné':''}',
                ),
                trailing:const Icon(Icons.chevron_right),
                onTap:()=>VeterinaryService.openMap(vet),
              )),

            if(visible.isEmpty&&vetFilter=='NAC')
              const Padding(
                padding:EdgeInsets.symmetric(vertical:8),
                child:Text(
                  'Aucune mention NAC explicite n’a été trouvée. Passez sur Tous : certains cabinets prennent les lapins sans l’indiquer dans leurs informations publiques.',
                  style:TextStyle(fontSize:12,color:Colors.black54),
                ),
              ),

            if(visible.isNotEmpty)
              OutlinedButton.icon(
                onPressed:()=>Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:(_)=>VeterinaryResultsPage(
                      vets:nearbyVets,
                      filter:vetFilter,
                      radiusKm:vetRadiusKm,
                    ),
                  ),
                ),
                icon:const Icon(Icons.list),
                label:Text('Voir les ${visible.length} résultat(s)'),
              ),

            const SizedBox(height:5),
            const Text(
              'Données publiques OpenStreetMap. La mention NAC dépend des informations publiées : confirmez toujours par téléphone la prise en charge des lapins.',
              style:TextStyle(fontSize:9.5,color:Colors.black45),
              textAlign:TextAlign.center,
            ),
          ],

          const SizedBox(height:15),
          Container(
            padding:const EdgeInsets.all(13),
            decoration:BoxDecoration(
              gradient:const LinearGradient(colors:[heroGreen,heroGreen2]),
              borderRadius:BorderRadius.circular(12),
              border:Border.all(color:gold,width:1),
              boxShadow:[BoxShadow(color:heroGreen.withValues(alpha:.12),blurRadius:10,offset:const Offset(0,4))],
            ),
            child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const Row(children:[
                Icon(Icons.emergency,color:gold),
                SizedBox(width:7),
                Text('URGENCE VÉTÉRINAIRE',style:TextStyle(fontWeight:FontWeight.w900,color:warmGoldText)),
              ]),
              const SizedBox(height:5),
              const Text(
                'En cas d’urgence, si vous ne trouvez pas de vétérinaire disponible, composez le 3115.',
                style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:Colors.white),
              ),
              const SizedBox(height:4),
              const Text(
                'Demandez un vétérinaire spécialisé dans les NAC.',
                style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:warmGoldText),
              ),
              const SizedBox(height:5),
              const Text(
                'Le 3115 vous oriente selon votre secteur ; lorsque celui-ci n’est pas couvert, le service indique la procédure pour trouver un vétérinaire de garde.',
                style:TextStyle(fontSize:10,color:Color(0xFFE7EEE9)),
              ),
              const SizedBox(height:9),
              OutlinedButton.icon(
                style:OutlinedButton.styleFrom(
                  backgroundColor:premiumCard,
                  foregroundColor:lapiGreenDark,
                  side:const BorderSide(color:gold),
                ),
                onPressed:()=>VeterinaryService.call('3115'),
                icon:const Icon(Icons.call),
                label:const Text('Appeler le 3115'),
              ),
            ]),
          ),
        ]),
      ),
      ]),
    );
  }

  Widget rabbitListSection(){
    final filtered=_filteredRabbits();
    if(rabbits.isEmpty){
      return Padding(
        padding:const EdgeInsets.fromLTRB(14,0,14,14),
        child:PremiumCard(child:Padding(
          padding:const EdgeInsets.all(22),
          child:Column(children:[
            const Icon(Icons.pets,size:46,color:lapiGreenDark),
            const SizedBox(height:12),
            const Text('Votre carnet commence ici',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),
            const SizedBox(height:8),
            const Text('Créez une fiche pour chaque lapin et gardez son suivi de santé au même endroit.',textAlign:TextAlign.center),
            const SizedBox(height:16),
            PremiumFilledButton.icon(onPressed:addRabbit,icon:const Icon(Icons.add),label:const Text('Créer mon premier lapin')),
          ]),
        )),
      );
    }
    return Padding(
      padding:const EdgeInsets.fromLTRB(14,0,14,14),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        PremiumMarbleButton(
          onPressed:homeOrganizing?null:addRabbit,
          icon:Icons.add_circle,
          label:'Ajouter un lapin',
          selected:true,
          padding:const EdgeInsets.symmetric(vertical:13,horizontal:18),
        ),
        const SizedBox(height:10),
        if(filtered.isEmpty)
          PremiumCard(child:Padding(
            padding:const EdgeInsets.all(18),
            child:Column(children:[
              const Icon(Icons.search_off,color:brown,size:34),
              const SizedBox(height:8),
              const Text('Aucun lapin ne correspond aux filtres.',textAlign:TextAlign.center),
            ]),
          )),
        ...filtered.map((entry){
          final originalIndex=entry.key;
          final rabbit=entry.value;
          final status=((rabbit['adoptionStatus']??'') as String);
          return Padding(
            padding:const EdgeInsets.only(bottom:12),
            child:PremiumCard(child:Stack(children:[
              const Positioned(right:0,bottom:-2,child:PremiumGoldLeaves(size:45,opacity:.62)),
              ListTile(
                contentPadding:const EdgeInsets.all(12),
                leading:Hero(
                  tag:'rabbit$originalIndex',
                  child:Container(
                    width:64,height:64,
                    decoration:BoxDecoration(
                      color:gold.withValues(alpha:.14),
                      borderRadius:BorderRadius.circular(12),
                      border:Border.all(color:gold.withValues(alpha:.45)),
                    ),
                    clipBehavior:Clip.antiAlias,
                    child:(rabbit['photo']??'').isEmpty?const Icon(Icons.pets,color:ink,size:32):Image.file(File(rabbit['photo']),fit:BoxFit.cover),
                  ),
                ),
                title:Text(
                  (rabbit['name']??'').isEmpty?'Lapin sans nom':rabbit['name'],
                  style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800,fontFamily:'serif'),
                ),
                subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text('${rabbit['breed']?.isEmpty==false?rabbit['breed']:'Race à renseigner'}${rabbit['birth']?.isEmpty==false?'  •  ${rabbit['birth']}':''}'),
                  if(appMode=='Éleveur'&&status.isNotEmpty)
                    Container(
                      margin:const EdgeInsets.only(top:5),
                      padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
                      decoration:BoxDecoration(
                        color:const Color(0xFFE9F5EA),
                        borderRadius:BorderRadius.circular(999),
                      ),
                      child:Text(status,style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:status=='Réservé'?const Color(0xFF9A762A):lapiGreenDark)),
                    ),
                ]),
                trailing:const Icon(Icons.chevron_right,color:brown),
                onTap:homeOrganizing?null:()async{
                  await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:originalIndex)));
                  await refresh();
                },
              ),
            ])),
          );
        }),
      ]),
    );
  }

  Widget _premiumDashTile(String label,String value,IconData icon,Color color){
    return Expanded(child:Container(
      constraints:const BoxConstraints(minHeight:82),
      padding:const EdgeInsets.fromLTRB(9,9,8,8),
      decoration:BoxDecoration(
        color:premiumCard,
        borderRadius:BorderRadius.circular(12),
        border:Border.all(color:softGoldLine,width:.8),
        boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.025),blurRadius:6,offset:const Offset(0,3))],
      ),
      child:Stack(children:[
        Positioned(right:-4,bottom:-5,child:Icon(icon,size:35,color:gold.withValues(alpha:.12))),
        Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Icon(icon,color:color,size:18),
            const Spacer(),
            Text(value,style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:color,height:1)),
          ]),
          const Spacer(),
          Text(label,maxLines:2,style:const TextStyle(fontSize:9.5,fontWeight:FontWeight.w800,color:ink,height:1.05)),
        ]),
      ]),
    ));
  }

  Widget dashboard(){
    final next=_nextAppointment();
    return PremiumCard(
      margin:const EdgeInsets.fromLTRB(14,0,14,10),
      child:Stack(children:[
        const Positioned(right:1,bottom:-2,child:PremiumGoldLeaves(size:48,opacity:.45)),
        Padding(
          padding:const EdgeInsets.all(12),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(children:[
              const Icon(Icons.dashboard_rounded,color:lapiGreenDark,size:22),
              const SizedBox(width:7),
              const Expanded(child:Text('Tableau de bord',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif'))),
              Container(
                padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
                decoration:BoxDecoration(color:const Color(0xFFEAF4EC),borderRadius:BorderRadius.circular(99),border:Border.all(color:gold.withValues(alpha:.30))),
                child:Text(appMode=='Éleveur'?'ÉLEVAGE':'ADOPTANT',style:const TextStyle(color:lapiGreenDark,fontSize:9,fontWeight:FontWeight.w900,letterSpacing:.4)),
              ),
            ]),
            const SizedBox(height:9),
            Row(children:[
              _premiumDashTile('Lapins','${rabbits.length}',Icons.pets,const Color(0xFF315B49)),
              const SizedBox(width:6),
              _premiumDashTile('RDV à venir','${_upcomingAppointments()}',Icons.event_available,const Color(0xFF1F6548)),
              const SizedBox(width:6),
              _premiumDashTile('Rappels ≤ 30 j','${_healthRemindersSoon()}',Icons.notifications_active,const Color(0xFF2D7654)),
              const SizedBox(width:6),
              _premiumDashTile(appMode=='Éleveur'?'Réservés':'À compléter',appMode=='Éleveur'?'${_reservedCount()}':'${_incompleteCount()}',appMode=='Éleveur'?Icons.favorite:Icons.fact_check,const Color(0xFF426D57)),
            ]),
            if(next!=null)...[
              const SizedBox(height:9),
              InkWell(
                borderRadius:BorderRadius.circular(11),
                onTap:()async{
                  await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:next['rabbitIndex'] as int)));
                  await refresh();
                },
                child:Container(
                  padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),
                  decoration:BoxDecoration(
                    color:gold.withValues(alpha:.08),
                    borderRadius:BorderRadius.circular(11),
                    border:Border.all(color:gold.withValues(alpha:.50)),
                  ),
                  child:Row(children:[
                    const Icon(Icons.local_hospital,color:lapiGreenDark,size:19),
                    const SizedBox(width:7),
                    Expanded(child:Text(
                      '${next['rabbitName']} • ${(next['appointment'] as Map)['date']} à ${(next['appointment'] as Map)['time']}',
                      style:const TextStyle(fontSize:11.5,fontWeight:FontWeight.w800,color:ink),
                    )),
                    const Icon(Icons.chevron_right,color:brown,size:18),
                  ]),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Future<void> createBackup() async {
    try{
      final file=await BackupService.createBackup();
      if(!mounted)return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject:'Sauvegarde complète LapiGestion',
        text:'Sauvegarde complète de LapiGestion. Conservez ce fichier précieusement.',
      );
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Sauvegarde impossible : $e')));
    }
  }

  Future<void> restoreBackup() async {
    final pick=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['json']);
    final path=pick?.files.single.path;
    if(path==null)return;
    if(!mounted)return;

    final ok=await showDialog<bool>(
      context:context,
      builder:(c)=>AlertDialog(
        title:const Text('Restaurer la sauvegarde ?'),
        content:const Text(
          'La sauvegarde remplacera les fiches actuellement enregistrées dans l’application. '
          'Les données et documents contenus dans le fichier seront restaurés.',
        ),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),
          PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Restaurer')),
        ],
      ),
    )??false;
    if(!ok)return;

    try{
      setState(()=>loading=true);
      await BackupService.restoreFromFile(path);
      await refresh();
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Sauvegarde restaurée avec succès.')));
    }catch(e){
      if(mounted){
        setState(()=>loading=false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Restauration impossible : $e')));
      }
    }
  }

  Widget backupSection(){
    return PremiumCard(
      margin:const EdgeInsets.fromLTRB(14,0,14,10),
      child:Stack(children:[
        const Positioned(right:0,bottom:-2,child:PremiumGoldLeaves(size:46,opacity:.48)),
        Padding(
        padding:const EdgeInsets.all(12),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          Row(children:[
            const Icon(Icons.shield_outlined,color:brown),
            const SizedBox(width:8),
            const Expanded(child:Text('Sécurité des données',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif'))),
            Container(
              padding:const EdgeInsets.symmetric(horizontal:9,vertical:4),
              decoration:BoxDecoration(color:gold.withValues(alpha:.15),borderRadius:BorderRadius.circular(12)),
              child:const Text('V2',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:brown)),
            ),
          ]),
          const SizedBox(height:5),
          const Text(
            'Sauvegardez toutes les fiches, la reproduction, les documents et les photos dans un seul fichier.',
            style:TextStyle(fontSize:12,color:Colors.black54),
          ),
          const SizedBox(height:12),
          PremiumMarbleButton(
            onPressed:rabbits.isEmpty?null:createBackup,
            icon:Icons.cloud_upload_outlined,
            label:rabbits.isEmpty?'Aucune donnée à sauvegarder':'Créer une sauvegarde complète',
          ),
          const SizedBox(height:8),
          OutlinedButton.icon(
            onPressed:restoreBackup,
            icon:const Icon(Icons.restore),
            label:const Text('Restaurer une sauvegarde'),
          ),
          const SizedBox(height:5),
          const Text(
            'Conseil : conservez une copie sur votre téléphone et une autre dans un espace sécurisé.',
            textAlign:TextAlign.center,
            style:TextStyle(fontSize:10,color:Colors.black45),
          ),
        ]),
      ),
      ]),
    );
  }

  Widget _premiumFilterChoice({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  })=>InkWell(
    onTap:onTap,
    borderRadius:BorderRadius.circular(10),
    child:AnimatedContainer(
      duration:const Duration(milliseconds:160),
      padding:const EdgeInsets.symmetric(horizontal:9,vertical:9),
      decoration:premiumMarbleDecoration(radius:10,selected:selected,strong:selected),
      child:Row(mainAxisSize:MainAxisSize.min,children:[
        Icon(icon,size:16,color:selected?warmGoldText:Colors.white),
        const SizedBox(width:5),
        Flexible(child:Text(
          label,
          maxLines:1,
          overflow:TextOverflow.ellipsis,
          style:TextStyle(fontSize:11.5,fontWeight:FontWeight.w800,color:selected?warmGoldText:Colors.white),
        )),
      ]),
    ),
  );

  Widget searchAndFilters(){
    final results=_filteredRabbits();

    Widget sexBlock()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Sexe',style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif')),
      const SizedBox(height:7),
      Wrap(spacing:6,runSpacing:6,children:[
        _premiumFilterChoice(label:'Tous',icon:Icons.check,selected:sexFilter=='Tous',onTap:()=>setState(()=>sexFilter='Tous')),
        _premiumFilterChoice(label:'Mâle',icon:Icons.male,selected:sexFilter=='Mâle',onTap:()=>setState(()=>sexFilter='Mâle')),
        _premiumFilterChoice(label:'Femelle',icon:Icons.female,selected:sexFilter=='Femelle',onTap:()=>setState(()=>sexFilter='Femelle')),
      ]),
    ]);

    Widget adoptionBlock()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Statut adoption',style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif')),
      const SizedBox(height:7),
      Wrap(spacing:6,runSpacing:6,children:[
        _premiumFilterChoice(label:'Tous',icon:Icons.check,selected:adoptionFilter=='Tous',onTap:()=>setState(()=>adoptionFilter='Tous')),
        _premiumFilterChoice(label:'À l’élevage',icon:Icons.home_outlined,selected:adoptionFilter=='À l’élevage',onTap:()=>setState(()=>adoptionFilter='À l’élevage')),
        _premiumFilterChoice(label:'Réservé',icon:Icons.favorite_border,selected:adoptionFilter=='Réservé',onTap:()=>setState(()=>adoptionFilter='Réservé')),
        _premiumFilterChoice(label:'Adopté / parti',icon:Icons.pets_outlined,selected:adoptionFilter=='Adopté / parti',onTap:()=>setState(()=>adoptionFilter='Adopté / parti')),
      ]),
    ]);

    return PremiumCard(
      margin:const EdgeInsets.fromLTRB(14,0,14,10),
      child:Stack(children:[
        const Positioned(right:1,top:1,child:PremiumGoldLeaves(size:46,opacity:.56)),
        const Positioned(right:0,bottom:-2,child:PremiumGoldLeaves(size:42,opacity:.48)),
        Padding(
          padding:const EdgeInsets.all(12),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            SizedBox(
              height:48,
              child:TextField(
                decoration:InputDecoration(
                  hintText:'Rechercher un lapin…',
                  prefixIcon:const Icon(Icons.search,color:lapiGreenDark,size:23),
                  suffixIcon:searchQuery.isEmpty?null:IconButton(icon:const Icon(Icons.close,size:18),onPressed:()=>setState(()=>searchQuery='')),
                  contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
                ),
                onChanged:(v)=>setState(()=>searchQuery=v),
              ),
            ),
            const SizedBox(height:10),
            LayoutBuilder(builder:(context,c){
              final twoColumns=appMode=='Éleveur'&&c.maxWidth>=320;
              if(!twoColumns)return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
                sexBlock(),
                if(appMode=='Éleveur')...[
                  const SizedBox(height:10),
                  adoptionBlock(),
                ],
              ]);
              return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Expanded(child:sexBlock()),
                const SizedBox(width:9),
                Container(width:1,height:106,color:softGoldLine.withValues(alpha:.65)),
                const SizedBox(width:9),
                Expanded(child:adoptionBlock()),
              ]);
            }),
            const SizedBox(height:9),
            Row(children:[
              const Icon(Icons.filter_alt_outlined,size:16,color:brown),
              const SizedBox(width:5),
              Text('${results.length} résultat${results.length>1?'s':''}',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:brown)),
              const Spacer(),
              if(searchQuery.isNotEmpty||sexFilter!='Tous'||adoptionFilter!='Tous')
                InkWell(
                  onTap:()=>setState((){searchQuery='';sexFilter='Tous';adoptionFilter='Tous';}),
                  child:const Padding(
                    padding:EdgeInsets.symmetric(horizontal:6,vertical:4),
                    child:Text('Réinitialiser',style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:lapiGreenDark)),
                  ),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
  @override Widget build(BuildContext context){
    final visible=visibleHomeOrder;
    return Scaffold(
      body:Scenic(home:true,child:SafeArea(child:loading
        ?const Center(child:CircularProgressIndicator())
        :CustomScrollView(slivers:[
          SliverToBoxAdapter(child:Column(
            key:_homeTopKey,
            crossAxisAlignment:CrossAxisAlignment.stretch,
            children:[
              Container(
                height:154,
                margin:const EdgeInsets.fromLTRB(14,14,14,0),
                padding:const EdgeInsets.symmetric(horizontal:18,vertical:13),
                decoration:BoxDecoration(
                  color:heroGreen,
                  image:DecorationImage(
                    image:const AssetImage('assets/images/lapigestion_background_master.jpg'),
                    fit:BoxFit.cover,
                    alignment:Alignment.center,
                    colorFilter:ColorFilter.mode(heroGreen.withValues(alpha:.60),BlendMode.srcOver),
                  ),
                  borderRadius:BorderRadius.circular(22),
                  border:Border.all(color:gold.withValues(alpha:.95),width:1.05),
                  boxShadow:[
                    BoxShadow(color:Colors.black.withValues(alpha:.18),blurRadius:20,offset:const Offset(0,8)),
                    BoxShadow(color:gold.withValues(alpha:.08),blurRadius:16),
                  ],
                ),
                child:Column(
                  mainAxisAlignment:MainAxisAlignment.center,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  children:[
                    Container(
                      width:48,height:48,
                      padding:const EdgeInsets.all(4),
                      decoration:BoxDecoration(
                        color:const Color(0xB80B3F2D),
                        borderRadius:BorderRadius.circular(14),
                        border:Border.all(color:gold,width:1.15),
                        boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.14),blurRadius:8)],
                      ),
                      child:ClipRRect(
                        borderRadius:BorderRadius.circular(10),
                        child:Image.asset('assets/images/lapigestion_app_icon.png',fit:BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height:7),
                    const Text(
                      'LapiGestion',
                      textAlign:TextAlign.center,
                      style:TextStyle(
                        fontSize:29,
                        fontWeight:FontWeight.w800,
                        color:warmGoldText,
                        fontFamily:'serif',
                        height:1,
                        shadows:[Shadow(color:Color(0x77000000),blurRadius:8,offset:Offset(0,2))],
                      ),
                    ),
                    const SizedBox(height:4),
                    const Text(
                      'Développé par Les Lapibreizh',
                      textAlign:TextAlign.center,
                      style:TextStyle(fontSize:12.5,fontWeight:FontWeight.w600,color:Colors.white),
                    ),
                    const SizedBox(height:8),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children:[
                        Container(width:65,height:1,color:gold),
                        const SizedBox(width:8),
                        const Icon(Icons.spa_outlined,color:gold,size:18),
                        const SizedBox(width:8),
                        Container(width:65,height:1,color:gold),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding:const EdgeInsets.fromLTRB(14,12,14,10),
                child:Container(
                  padding:const EdgeInsets.fromLTRB(12,9,10,9),
                  decoration:BoxDecoration(
                    color:premiumCard,
                    borderRadius:BorderRadius.circular(20),
                    border:Border.all(color:softGoldLine,width:.85),
                    boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.03), blurRadius: 12, offset: const Offset(0, 5))],
                  ),
                  child:Column(children:[
                    Row(children:[
                      Container(
                        width:36,height:36,
                        decoration:BoxDecoration(color:const Color(0xFFEAF4EC),borderRadius:BorderRadius.circular(12),border:Border.all(color:gold.withValues(alpha:.28))),
                        child:Icon(appMode=='Éleveur'?Icons.home_work_outlined:Icons.favorite_outline,color:lapiGreenDark,size:20),
                      ),
                      const SizedBox(width:10),
                      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text(appMode=='Éleveur'?'Mode élevage':'Mode adoptant',style:const TextStyle(fontSize:16,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif')),
                        const SizedBox(height:2),
                        Text(
                          appMode=='Éleveur'
                            ?'Reproduction, départ et suivi santé.'
                            :'Le suivi quotidien de votre lapin.',
                          style:const TextStyle(fontSize:11,color:Colors.black54),
                        ),
                      ])),
                      const SizedBox(width:8),
                      PremiumSegmentedButton<String>(
                        segments:const [
                          ButtonSegment(value:'Éleveur',label:Text('Élevage')),
                          ButtonSegment(value:'Adoptant',label:Text('Adoptant')),
                        ],
                        selected:{appMode},
                        showSelectedIcon:false,
                        onSelectionChanged:homeOrganizing?null:(v)=>setAppMode(v.first),
                        style:ButtonStyle(
                          visualDensity:VisualDensity.compact,
                          shape:WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius:BorderRadius.circular(5))),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ),
            ],
          )),
          SliverToBoxAdapter(child:homeOrganizeControl()),
          if(homeOrganizing)
            SliverReorderableList(
              itemCount:visible.length,
              onReorder:reorderHome,
              itemBuilder:(context,index){
                final id=visible[index];
                return homeFrame(id,index,homeSection(id));
              },
            )
          else
            SliverList.builder(
              itemCount:visible.length,
              itemBuilder:(context,index){
                final id=visible[index];
                return homeFrame(id,index,homeSection(id));
              },
            ),
          const SliverToBoxAdapter(child:SizedBox(height:105)),
        ]))),
      bottomNavigationBar:_bottomNavigation(),
    );
  }
}

ImageProvider? fileImage(dynamic p){if(p is String&&p.isNotEmpty&&File(p).existsSync())return FileImage(File(p));return null;}
Map<String,dynamic> emptyRabbit()=>{'id':'r_${DateTime.now().microsecondsSinceEpoch}','name':'','sex':'','sterilized':'','breed':'','color':'','birth':'','weaning':'','identification':'','tattoo':'','photo':'','fatherName':'','fatherBreed':'','fatherColor':'','fatherBirth':'','motherName':'','motherBreed':'','motherColor':'','motherBirth':'','vaccines':[],'dewormings':[],'appointments':[],'weights':[],'competitions':[],'medications':[],'healthBook':'','passport':'','adoptionStatus':'À l’élevage','adopterName':'','adopterContact':'','departureDate':'','adoptionNotes':'','healthBookGiven':false,'healthCertificateGiven':false,'adoptionInfoGiven':false,'engagementRecipientName':'','engagementRecipientAddress':'','engagementRecipientEmail':'','engagementDeliveryDate':'','engagementSignedDate':'','engagementPlace':'','engagementIssuerName':'','engagementIssuerQualification':'','engagementIssuerReference':'','engagementMentionImage':'','engagementSignatureImage':'','engagementCertificatePdf':'','engagementAccepted':false};

class RabbitPage extends StatefulWidget{final int index;const RabbitPage({super.key,required this.index});@override State<RabbitPage> createState()=>_RabbitPageState();}
class _RabbitPageState extends State<RabbitPage>{
  List<Map<String,dynamic>> all=[]; List<Map<String,dynamic>> breedings=[]; Map<String,dynamic>? r; final picker=ImagePicker();
  String healthFilter='Tout'; bool healthExpanded=false; String appMode='Éleveur';
  String reproSearch='';
  bool rabbitOrganizing=false;
  List<String> rabbitOrder=[];
  static const rabbitDefaultsEleveur=['identity','filiation','alerts','health','medications','weight','adoption','reproduction','competitions','vaccines','dewormings','appointments','documents'];
  static const rabbitDefaultsAdoptant=['identity','filiation','alerts','health','medications','weight','vaccines','dewormings','appointments','documents'];

  @override void initState(){super.initState();load();}
  Future<void> load()async{
    all=await Store.load();
    r=all[widget.index];
    breedings=await ReproductionStore.load();
    appMode=await AppModeStore.load();
    final defaults=appMode=='Éleveur'?rabbitDefaultsEleveur:rabbitDefaultsAdoptant;
    rabbitOrder=await LayoutStore.load(appMode=='Éleveur'?'rabbit_eleveur':'rabbit_adoptant',defaults);
    if(mounted)setState((){});
  }
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
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
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


  List<Map<String,dynamic>> _sortedWeights(){
    final items=((r!['weights'] as List?)??[])
        .map((e)=>Map<String,dynamic>.from(e as Map))
        .toList();
    items.sort((a,b){
      final ad=Notifications.parseDate(a['date'] as String?)??DateTime(1900);
      final bd=Notifications.parseDate(b['date'] as String?)??DateTime(1900);
      return ad.compareTo(bd);
    });
    return items;
  }

  Future<void> addWeight()async{
    final item=<String,dynamic>{
      'id':'w_${DateTime.now().microsecondsSinceEpoch}',
      'date':Notifications.formatDate(DateTime.now()),
      'grams':0,
      'note':'',
    };
    await showDialog(
      context:context,
      builder:(ctx)=>WeightDialog(
        item:item,
        onSave:(v)async{
          (r!['weights'] as List).add(v);
          await persist();
          if(ctx.mounted)Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> editWeight(Map<String,dynamic> weight)async{
    final list=r!['weights'] as List;
    final id=(weight['id']??'') as String;
    var index=id.isEmpty?-1:list.indexWhere((e)=>(e as Map)['id']==id);
    if(index<0)index=list.indexWhere((e)=>identical(e,weight));
    if(index<0)return;
    final current=Map<String,dynamic>.from(list[index] as Map);
    await showDialog(
      context:context,
      builder:(ctx)=>WeightDialog(
        item:current,
        onSave:(v)async{
          list[index]=v;
          await persist();
          if(ctx.mounted)Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> removeWeight(Map<String,dynamic> weight)async{
    final ok=await showDialog<bool>(
      context:context,
      builder:(c)=>AlertDialog(
        title:const Text('Supprimer cette pesée ?'),
        content:const Text('Cette mesure sera retirée du suivi du poids.'),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),
          PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer')),
        ],
      ),
    )??false;
    if(!ok)return;

    final list=r!['weights'] as List;
    final id=(weight['id']??'') as String;
    if(id.isNotEmpty){
      list.removeWhere((e)=>(e as Map)['id']==id);
    }else{
      final date=(weight['date']??'') as String;
      final grams=weight['grams'];
      list.removeWhere((e)=>(e as Map)['date']==date&&(e as Map)['grams']==grams);
    }
    await persist();
  }

  String _weightDisplay(int grams){
    if(grams<=0)return '—';
    final kg=grams/1000;
    return '$grams g • ${kg.toStringAsFixed(2).replaceAll('.',',')} kg';
  }

  Widget _weightStat(String label,String value,IconData icon){
    return Container(
      width:146,
      padding:const EdgeInsets.symmetric(horizontal:12,vertical:11),
      decoration:BoxDecoration(
        color:const Color(0xFFF4F8F5),
        borderRadius:BorderRadius.circular(6),
        border:Border.all(color:const Color(0xFFD8E4DB)),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(icon,color:lapiGreenDark,size:19),
        const SizedBox(height:7),
        Text(value,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:2),
        Text(label,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700,color:Color(0xFF68736C))),
      ]),
    );
  }

  Widget weightSection(){
    final items=_sortedWeights();
    final valid=items.where((e)=>(e['grams'] is int?e['grams'] as int:int.tryParse('${e['grams']}')??0)>0).toList();

    int gramsOf(Map<String,dynamic> e)=>e['grams'] is int?e['grams'] as int:int.tryParse('${e['grams']}')??0;

    if(valid.isEmpty){
      return PremiumCard(child:Padding(
        padding:const EdgeInsets.all(10),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          header('Poids & évolution',Icons.monitor_weight_outlined),
          const Text('Enregistrez chaque pesée avec sa date pour construire automatiquement la courbe de poids.',style:TextStyle(color:Colors.black54)),
          const SizedBox(height:8),
          OutlinedButton.icon(onPressed:addWeight,icon:const Icon(Icons.add),label:const Text('Ajouter une première pesée')),
        ]),
      ));
    }

    final current=gramsOf(valid.last);
    final first=gramsOf(valid.first);
    final minimum=valid.map(gramsOf).reduce((a,b)=>a<b?a:b);
    final maximum=valid.map(gramsOf).reduce((a,b)=>a>b?a:b);
    final previous=valid.length>1?gramsOf(valid[valid.length-2]):null;
    final deltaPrevious=previous==null?null:current-previous;
    final pctPrevious=previous==null||previous==0?null:(deltaPrevious!*100/previous);
    final deltaFirst=current-first;
    final pctFirst=first==0?null:(deltaFirst*100/first);

    String deltaText(int? delta,double? pct){
      if(delta==null||pct==null)return '—';
      final sign=delta>0?'+':'';
      final pctSign=pct>0?'+':'';
      return '$sign$delta g • $pctSign${pct.toStringAsFixed(1).replaceAll('.',',')} %';
    }

    return PremiumCard(child:Padding(
      padding:const EdgeInsets.all(10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        header('Poids & évolution',Icons.monitor_weight_outlined),
        const Text('La courbe utilise les dates réelles des pesées.',style:TextStyle(color:Colors.black54)),
        const SizedBox(height:8),

        Wrap(spacing:8,runSpacing:8,children:[
          _weightStat('Poids actuel',_weightDisplay(current),Icons.monitor_weight),
          _weightStat('Minimum',_weightDisplay(minimum),Icons.south_east),
          _weightStat('Maximum',_weightDisplay(maximum),Icons.north_east),
          _weightStat('Depuis la dernière',deltaText(deltaPrevious,pctPrevious),Icons.swap_vert),
        ]),

        if(valid.length>1)...[
          const SizedBox(height:7),
          Container(
            padding:const EdgeInsets.all(11),
            decoration:BoxDecoration(
              color:lapiGreenDark,
              borderRadius:BorderRadius.circular(16),
            ),
            child:Row(children:[
              const Icon(Icons.insights,color:gold,size:20),
              const SizedBox(width:8),
              Expanded(child:Text(
                'Depuis la première pesée : ${deltaText(deltaFirst,pctFirst)}',
                style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700),
              )),
            ]),
          ),
        ],

        const SizedBox(height:9),
        Container(
          padding:const EdgeInsets.fromLTRB(10,12,10,8),
          decoration:BoxDecoration(
            color:const Color(0xFFFBFCFB),
            borderRadius:BorderRadius.circular(16),
            border:Border.all(color:lineSoft),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            const Text('Courbe du poids',style:TextStyle(fontWeight:FontWeight.w900,color:ink)),
            const SizedBox(height:3),
            Text(
              valid.length==1
                  ? 'Ajoutez une seconde pesée pour faire apparaître l’évolution.'
                  : '${valid.first['date']}  →  ${valid.last['date']}',
              style:const TextStyle(fontSize:11,color:Colors.black54),
            ),
            const SizedBox(height:7),
            SizedBox(
              height:130,
              child:CustomPaint(
                painter:WeightChartPainter(
                  points:valid.map((e)=>WeightPoint(
                    date:Notifications.parseDate(e['date'] as String?)!,
                    grams:gramsOf(e),
                  )).toList(),
                ),
                child:const SizedBox.expand(),
              ),
            ),
          ]),
        ),

        const SizedBox(height:9),
        Row(children:[
          const Expanded(child:Text('Historique des pesées',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:ink))),
          PremiumFilledButton.icon(onPressed:addWeight,icon:const Icon(Icons.add,size:18),label:const Text('Pesée')),
        ]),
        const SizedBox(height:6),

        ...valid.reversed.map((w){
          final grams=gramsOf(w);
          final note=((w['note']??'') as String).trim();
          return Container(
            margin:const EdgeInsets.only(bottom:7),
            decoration:BoxDecoration(
              color:const Color(0xFFF7FAF8),
              borderRadius:BorderRadius.circular(6),
              border:Border.all(color:const Color(0xFFDCE3DE)),
            ),
            child:ListTile(
              onTap:()=>editWeight(w),
              leading:const CircleAvatar(backgroundColor:ivory,child:Icon(Icons.monitor_weight_outlined,color:brown)),
              title:Text(_weightDisplay(grams),style:const TextStyle(fontWeight:FontWeight.w800)),
              subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(w['date']??''),
                if(note.isNotEmpty)Text(note,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.black54)),
              ]),
              trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()=>removeWeight(w)),
            ),
          );
        }),
      ]),
    ));
  }


  List<Map<String,dynamic>> sortedMedications(){
    final list=((r!['medications'] as List?)??[]).map((e)=>Map<String,dynamic>.from(e as Map)).toList();
    list.sort((a,b){
      final ad=Notifications.parseDate(a['startDate'] as String?)??DateTime(1900);
      final bd=Notifications.parseDate(b['startDate'] as String?)??DateTime(1900);
      return bd.compareTo(ad);
    });
    return list;
  }

  bool medicationIsActive(Map<String,dynamic> item){
    if((item['completed']??false)==true)return false;
    final start=Notifications.parseDate(item['startDate'] as String?);
    final end=Notifications.parseDate(item['endDate'] as String?);
    final now=DateTime.now();
    if(start!=null&&DateTime(now.year,now.month,now.day).isBefore(start))return false;
    if(end!=null&&DateTime(now.year,now.month,now.day).isAfter(end))return false;
    return true;
  }

  Future<void> addMedication()async{
    final item=<String,dynamic>{
      'id':'m_${DateTime.now().microsecondsSinceEpoch}',
      'name':'','reason':'','dose':'','route':'Voie orale',
      'startDate':Notifications.formatDate(DateTime.now()),'endDate':'',
      'times':['09:00'],'vet':'','notes':'',
      'photo':'','prescription':'',
      'completed':false,'notificationsEnabled':true,
      'notificationKey':'m_${DateTime.now().microsecondsSinceEpoch}',
    };
    await showDialog(context:context,builder:(ctx)=>MedicationDialog(item:item,onSave:(v)async{
      (r!['medications'] as List).add(v);
      await persist();
      await Notifications.scheduleMedication(rabbitName:(r!['name']??'Lapin') as String,item:v);
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> editMedication(Map<String,dynamic> item)async{
    final list=r!['medications'] as List;
    final id=(item['id']??'') as String;
    final index=list.indexWhere((e)=>(e as Map)['id']==id);
    if(index<0)return;
    final current=Map<String,dynamic>.from(list[index] as Map);
    await showDialog(context:context,builder:(ctx)=>MedicationDialog(item:current,onSave:(v)async{
      await Notifications.cancelToken((current['notificationKey']??'') as String);
      list[index]=v;
      await persist();
      await Notifications.scheduleMedication(rabbitName:(r!['name']??'Lapin') as String,item:v);
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }

  Future<void> toggleMedicationComplete(Map<String,dynamic> item)async{
    final list=r!['medications'] as List;
    final id=(item['id']??'') as String;
    final index=list.indexWhere((e)=>(e as Map)['id']==id);
    if(index<0)return;
    final current=Map<String,dynamic>.from(list[index] as Map);
    current['completed']=!(current['completed']??false);
    list[index]=current;
    await persist();
    if(current['completed']==true){
      await Notifications.cancelToken((current['notificationKey']??'') as String);
    }else{
      await Notifications.scheduleMedication(rabbitName:(r!['name']??'Lapin') as String,item:current);
    }
  }

  Future<void> deleteMedication(Map<String,dynamic> item)async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer ce traitement ?'),
      content:const Text('Les rappels et les copies internes de la photo / ordonnance seront également supprimés.'),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),
        PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer')),
      ],
    ))??false;
    if(!ok)return;
    (r!['medications'] as List).removeWhere((e)=>(e as Map)['id']==item['id']);
    await persist();
    await Notifications.cancelToken((item['notificationKey']??'') as String);
    await PrivateFiles.deleteFile((item['photo']??'') as String);
    await PrivateFiles.deleteFile((item['prescription']??'') as String);
  }

  Future<void> openMedicationFile(String path,String label)async{
    if(path.isEmpty)return;
    if(PrivateFiles.isImage(path)){
      if(!mounted)return;
      await showDialog(context:context,builder:(c)=>Dialog.fullscreen(child:Scaffold(
        backgroundColor:Colors.black,
        appBar:AppBar(backgroundColor:ink,foregroundColor:gold,title:Text(label)),
        body:Center(child:InteractiveViewer(minScale:.5,maxScale:6,child:Image.file(File(path),fit:BoxFit.contain))),
      )));
    }else{
      await OpenFilex.open(path);
    }
  }

  Widget medicationsSection(){
    final items=sortedMedications();
    final active=items.where(medicationIsActive).toList();
    final finished=items.where((e)=>!medicationIsActive(e)).toList();

    Widget medTile(Map<String,dynamic> item){
      final on=medicationIsActive(item);
      final times=((item['times'] as List?)??[]).map((e)=>e.toString()).join(' • ');
      final dose=((item['dose']??'') as String).trim();
      final reason=((item['reason']??'') as String).trim();
      final photo=((item['photo']??'') as String);
      final prescription=((item['prescription']??'') as String);

      return Container(
        margin:const EdgeInsets.only(bottom:8),
        decoration:BoxDecoration(
          color:(on?const Color(0xFF1E6A49):Colors.black54).withValues(alpha:.07),
          borderRadius:BorderRadius.circular(15),
          border:Border.all(color:(on?const Color(0xFF1E6A49):Colors.black38).withValues(alpha:.35)),
        ),
        child:Column(children:[
          ListTile(
            onTap:()=>editMedication(item),
            leading:CircleAvatar(
              backgroundColor:(on?const Color(0xFF1E6A49):Colors.black45).withValues(alpha:.12),
              child:Icon(on?Icons.medication_liquid_outlined:Icons.task_alt,color:on?const Color(0xFF1E6A49):Colors.black54),
            ),
            title:Text(((item['name']??'') as String).trim().isEmpty?'Médicament':item['name'],style:const TextStyle(fontWeight:FontWeight.w900)),
            subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              if(reason.isNotEmpty)Text(reason),
              Text('${item['startDate']??''}${((item['endDate']??'') as String).isNotEmpty?' → ${item['endDate']}':' • sans date de fin'}'),
              if(dose.isNotEmpty)Text('$dose${((item['route']??'') as String).isNotEmpty?' • ${item['route']}':''}',style:const TextStyle(fontWeight:FontWeight.w700)),
              if(times.isNotEmpty)Text('Prises : $times',style:const TextStyle(fontSize:12,color:Colors.black54)),
            ]),
            trailing:PopupMenuButton<String>(
              onSelected:(v){
                if(v=='edit')editMedication(item);
                if(v=='toggle')toggleMedicationComplete(item);
                if(v=='delete')deleteMedication(item);
              },
              itemBuilder:(_)=>[
                const PopupMenuItem(value:'edit',child:Text('Modifier')),
                PopupMenuItem(value:'toggle',child:Text(on?'Marquer terminé':'Réactiver')),
                const PopupMenuItem(value:'delete',child:Text('Supprimer')),
              ],
            ),
          ),
          if(photo.isNotEmpty||prescription.isNotEmpty)
            Padding(
              padding:const EdgeInsets.fromLTRB(12,0,12,10),
              child:Wrap(spacing:7,runSpacing:7,children:[
                if(photo.isNotEmpty)OutlinedButton.icon(onPressed:()=>openMedicationFile(photo,'Photo du médicament'),icon:const Icon(Icons.photo_outlined),label:const Text('Produit')),
                if(prescription.isNotEmpty)OutlinedButton.icon(onPressed:()=>openMedicationFile(prescription,'Ordonnance'),icon:const Icon(Icons.description_outlined),label:const Text('Ordonnance')),
              ]),
            ),
        ]),
      );
    }

    return PremiumCard(child:Padding(
      padding:const EdgeInsets.all(10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Expanded(child:header('Traitements médicaux',Icons.medication_liquid_outlined)),
          PremiumFilledButton.icon(onPressed:addMedication,icon:const Icon(Icons.add,size:18),label:const Text('Ajouter')),
        ]),
        const Text('Médicaments prescrits, doses, horaires et ordonnances. Les doses restent celles saisies selon les indications vétérinaires.',style:TextStyle(fontSize:11,color:Colors.black54)),
        const SizedBox(height:8),
        if(items.isEmpty)
          Container(
            padding:const EdgeInsets.all(10),
            decoration:BoxDecoration(color:gold.withValues(alpha:.07),borderRadius:BorderRadius.circular(15)),
            child:const Text('Aucun traitement médical enregistré.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54)),
          )
        else...[
          Row(children:[
            Expanded(child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFF1E6A49).withValues(alpha:.08),borderRadius:BorderRadius.circular(14)),child:Column(children:[
              Text('${active.length}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:Color(0xFF1565C0))),
              const Text('En cours',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700)),
            ]))),
            const SizedBox(width:8),
            Expanded(child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.05),borderRadius:BorderRadius.circular(14)),child:Column(children:[
              Text('${finished.length}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:brown)),
              const Text('Terminés',style:TextStyle(fontSize:11,fontWeight:FontWeight.w700)),
            ]))),
          ]),
          if(active.isNotEmpty)...[
            const SizedBox(height:8),
            const Text('En cours',style:TextStyle(fontWeight:FontWeight.w900,color:brown)),
            const SizedBox(height:6),
            ...active.map(medTile),
          ],
          if(finished.isNotEmpty)...[
            const SizedBox(height:8),
            ExpansionTile(
              tilePadding:EdgeInsets.zero,
              title:Text('Historique terminé (${finished.length})',style:const TextStyle(fontWeight:FontWeight.w800)),
              children:finished.map(medTile).toList(),
            ),
          ],
        ],
      ]),
    ));
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
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
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
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
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
      'colors':<Map<String,dynamic>>[],
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
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    await ReproductionStore.remove((record['id']??'') as String);
    await refreshBreedings();
  }

  Future<void> editAdoption()async{
    final data=Map<String,dynamic>.from(r!);
    await showDialog(context:context,builder:(ctx)=>AdoptionDialog(data:data,onSave:(v)async{
      r=v;
      await persist();
      if(ctx.mounted)Navigator.pop(ctx);
    }));
  }


  List<Map<String,dynamic>> sortedCompetitions(){
    final items=((r!['competitions'] as List?)??[])
        .map((e)=>Map<String,dynamic>.from(e as Map))
        .toList();
    final today=DateTime.now();
    DateTime dateOf(Map<String,dynamic> e)=>Notifications.parseDate(e['date'] as String?)??DateTime(1900);
    final upcoming=items.where((e)=>dateOf(e).isAfter(DateTime(today.year,today.month,today.day))).toList()
      ..sort((a,b)=>dateOf(a).compareTo(dateOf(b)));
    final past=items.where((e)=>!dateOf(e).isAfter(DateTime(today.year,today.month,today.day))).toList()
      ..sort((a,b)=>dateOf(b).compareTo(dateOf(a)));
    return [...upcoming,...past];
  }

  String competitionAwardLabel(Map<String,dynamic> item){
    final award=((item['award']??'') as String).trim();
    if(award=='Autre récompense')return ((item['customAward']??'') as String).trim();
    return award;
  }

  double? competitionScore(Map<String,dynamic> item){
    final raw=((item['score']??'') as String).trim().replaceAll(',','.');
    return double.tryParse(raw);
  }

  Future<void> addCompetition()async{
    final item=<String,dynamic>{
      'id':'c_${DateTime.now().microsecondsSinceEpoch}',
      'date':Notifications.formatDate(DateTime.now()),
      'name':'','location':'','category':'','cageNumber':'','judge':'',
      'tattoo':((r!['tattoo']??'') as String),'weightGrams':0,
      'score':'','qualification':'Non renseigné','ranking':'',
      'award':'Aucune','customAward':'','comments':'',
      'photo':'','judgingSheet':'',
    };
    await showDialog(
      context:context,
      builder:(ctx)=>CompetitionDialog(
        item:item,
        onSave:(v)async{
          (r!['competitions'] as List).add(v);
          await persist();
          if(ctx.mounted)Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> editCompetition(Map<String,dynamic> competition)async{
    final list=r!['competitions'] as List;
    final id=(competition['id']??'') as String;
    final index=list.indexWhere((e)=>(e as Map)['id']==id);
    if(index<0)return;
    final current=Map<String,dynamic>.from(list[index] as Map);
    await showDialog(
      context:context,
      builder:(ctx)=>CompetitionDialog(
        item:current,
        onSave:(v)async{
          list[index]=v;
          await persist();
          if(ctx.mounted)Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> deleteCompetition(Map<String,dynamic> competition)async{
    final ok=await showDialog<bool>(
      context:context,
      builder:(c)=>AlertDialog(
        title:const Text('Supprimer ce concours ?'),
        content:const Text('La participation, sa photo et sa carte de jugement enregistrées dans l’application seront supprimées.'),
        actions:[
          TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),
          PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer')),
        ],
      ),
    )??false;
    if(!ok)return;
    final list=r!['competitions'] as List;
    final id=(competition['id']??'') as String;
    final match=list.where((e)=>(e as Map)['id']==id).cast<Map>().toList();
    if(match.isNotEmpty){
      await PrivateFiles.deleteFile((match.first['photo']??'') as String);
      await PrivateFiles.deleteFile((match.first['judgingSheet']??'') as String);
    }
    list.removeWhere((e)=>(e as Map)['id']==id);
    await persist();
  }

  Future<void> openCompetitionFile(String path,String title)async{
    if(path.isEmpty||!File(path).existsSync())return;
    if(PrivateFiles.isImage(path)){
      if(!mounted)return;
      await showDialog(context:context,builder:(c)=>Dialog.fullscreen(child:Scaffold(
        backgroundColor:Colors.black,
        appBar:AppBar(backgroundColor:ink,foregroundColor:gold,title:Text(title)),
        body:Center(child:InteractiveViewer(minScale:.5,maxScale:6,child:Image.file(File(path),fit:BoxFit.contain))),
      )));
    }else{
      await OpenFilex.open(path);
    }
  }

  Widget competitionStat(String label,String value,IconData icon,Color color)=>Container(
    width:142,
    padding:const EdgeInsets.symmetric(horizontal:12,vertical:11),
    decoration:BoxDecoration(
      color:color.withValues(alpha:.09),
      borderRadius:BorderRadius.circular(16),
      border:Border.all(color:color.withValues(alpha:.45)),
    ),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Icon(icon,color:color,size:20),
      const SizedBox(height:5),
      Text(value,style:TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:color)),
      Text(label,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:ink)),
    ]),
  );

  Widget competitionsSection(){
    final items=sortedCompetitions();
    final today=DateTime.now();
    final upcoming=items.where((e){
      final d=Notifications.parseDate(e['date'] as String?);
      return d!=null&&d.isAfter(DateTime(today.year,today.month,today.day));
    }).length;
    final distinctions=items.where((e){
      final a=competitionAwardLabel(e);
      return a.isNotEmpty&&a!='Aucune';
    }).length;
    final scores=items.map(competitionScore).whereType<double>().toList();
    final best=scores.isEmpty?null:scores.reduce((a,b)=>a>b?a:b);

    if(items.isEmpty){
      return PremiumCard(child:Padding(
        padding:const EdgeInsets.all(10),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          header('Concours & Expositions',Icons.emoji_events_outlined),
          const Text('Enregistrez les expositions, cartes de jugement, notes, classements et distinctions de ce lapin.',style:TextStyle(color:Colors.black54)),
          const SizedBox(height:8),
          PremiumFilledButton.icon(onPressed:addCompetition,icon:const Icon(Icons.add),label:const Text('Ajouter un concours')),
        ]),
      ));
    }

    return PremiumCard(child:Padding(
      padding:const EdgeInsets.all(10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          Expanded(child:header('Concours & Expositions',Icons.emoji_events_outlined)),
          IconButton(tooltip:'Ajouter',onPressed:addCompetition,icon:const Icon(Icons.add_circle_outline,color:brown)),
        ]),
        Wrap(spacing:8,runSpacing:8,children:[
          competitionStat('Engagements','${items.length}',Icons.event_note,const Color(0xFF3E6553)),
          competitionStat('À venir','$upcoming',Icons.calendar_month,const Color(0xFF1E6A49)),
          competitionStat('Distinctions','$distinctions',Icons.emoji_events,const Color(0xFF9A762A)),
          competitionStat('Meilleure note',best==null?'—':best.toStringAsFixed(best%1==0?0:1).replaceAll('.',','),Icons.stars,const Color(0xFF2E7A55)),
        ]),
        const SizedBox(height:8),
        PremiumFilledButton.icon(onPressed:exportCompetitionPdf,icon:const Icon(Icons.picture_as_pdf),label:const Text('Exporter le palmarès PDF')),
        const SizedBox(height:8),
        ...items.map((item){
          final date=Notifications.parseDate(item['date'] as String?);
          final isUpcoming=date!=null&&date.isAfter(DateTime(today.year,today.month,today.day));
          final award=competitionAwardLabel(item);
          final score=((item['score']??'') as String).trim();
          final qualification=((item['qualification']??'') as String).trim();
          final ranking=((item['ranking']??'') as String).trim();
          final photo=((item['photo']??'') as String);
          final sheet=((item['judgingSheet']??'') as String);
          return Container(
            margin:const EdgeInsets.only(bottom:10),
            padding:const EdgeInsets.all(12),
            decoration:BoxDecoration(
              color:isUpcoming?const Color(0xFF1E6A49).withValues(alpha:.06):gold.withValues(alpha:.06),
              borderRadius:BorderRadius.circular(16),
              border:Border.all(color:isUpcoming?const Color(0xFF1E6A49).withValues(alpha:.35):gold.withValues(alpha:.45)),
            ),
            child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Container(
                  width:42,height:42,
                  decoration:BoxDecoration(color:(award.isNotEmpty&&award!='Aucune'?const Color(0xFF9A762A):brown).withValues(alpha:.10),shape:BoxShape.circle),
                  child:Icon(award.isNotEmpty&&award!='Aucune'?Icons.emoji_events:Icons.event,color:award.isNotEmpty&&award!='Aucune'?const Color(0xFF9A762A):brown),
                ),
                const SizedBox(width:9),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Expanded(child:Text(((item['name']??'') as String).trim().isEmpty?'Concours / exposition':item['name'],style:const TextStyle(fontWeight:FontWeight.w900,fontSize:16,color:ink))),
                    if(isUpcoming)Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:3),decoration:BoxDecoration(color:const Color(0xFF1E6A49).withValues(alpha:.10),borderRadius:BorderRadius.circular(10)),child:const Text('À VENIR',style:TextStyle(fontSize:9,fontWeight:FontWeight.w900,color:Color(0xFF1565C0)))),
                  ]),
                  Text('${item['date']??''}${((item['location']??'') as String).trim().isEmpty?'':' • ${item['location']}'}',style:const TextStyle(fontSize:12,color:Colors.black54)),
                ])),
                PopupMenuButton<String>(
                  onSelected:(v){if(v=='edit')editCompetition(item);if(v=='delete')deleteCompetition(item);},
                  itemBuilder:(_)=>const [
                    PopupMenuItem(value:'edit',child:Text('Modifier')),
                    PopupMenuItem(value:'delete',child:Text('Supprimer')),
                  ],
                ),
              ]),
              if(((item['category']??'') as String).trim().isNotEmpty)Padding(padding:const EdgeInsets.only(top:6),child:Text('Classe / catégorie : ${item['category']}',style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700))),
              if(score.isNotEmpty||qualification!='Non renseigné'||ranking.isNotEmpty)Padding(
                padding:const EdgeInsets.only(top:7),
                child:Wrap(spacing:7,runSpacing:6,children:[
                  if(score.isNotEmpty)Chip(label:Text('$score pts')),
                  if(qualification.isNotEmpty&&qualification!='Non renseigné')Chip(label:Text(qualification)),
                  if(ranking.isNotEmpty)Chip(label:Text('Classement : $ranking')),
                ]),
              ),
              if(award.isNotEmpty&&award!='Aucune')Padding(
                padding:const EdgeInsets.only(top:7),
                child:Container(
                  padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),
                  decoration:BoxDecoration(color:gold.withValues(alpha:.09),borderRadius:BorderRadius.circular(12)),
                  child:Row(children:[const Icon(Icons.emoji_events,color:Color(0xFFEF6C00),size:19),const SizedBox(width:7),Expanded(child:Text(award,style:const TextStyle(fontWeight:FontWeight.w900,color:ink)))]),
                ),
              ),
              if(((item['judge']??'') as String).trim().isNotEmpty||((item['cageNumber']??'') as String).trim().isNotEmpty||((item['tattoo']??'') as String).trim().isNotEmpty)Padding(
                padding:const EdgeInsets.only(top:7),
                child:Text([
                  if(((item['judge']??'') as String).trim().isNotEmpty)'Juge : ${item['judge']}',
                  if(((item['cageNumber']??'') as String).trim().isNotEmpty)'Cage : ${item['cageNumber']}',
                  if(((item['tattoo']??'') as String).trim().isNotEmpty)'Tatouage : ${item['tattoo']}',
                ].join(' • '),style:const TextStyle(fontSize:11,color:Colors.black54)),
              ),
              if(((item['comments']??'') as String).trim().isNotEmpty)Padding(padding:const EdgeInsets.only(top:7),child:Text(item['comments'],style:const TextStyle(fontSize:12,fontStyle:FontStyle.italic,color:Colors.black54))),
              if(photo.isNotEmpty||sheet.isNotEmpty)Padding(
                padding:const EdgeInsets.only(top:7),
                child:Wrap(spacing:6,runSpacing:6,children:[
                  if(photo.isNotEmpty)OutlinedButton.icon(onPressed:()=>openCompetitionFile(photo,'Photo du concours'),icon:const Icon(Icons.photo_outlined),label:const Text('Photo')),
                  if(sheet.isNotEmpty)OutlinedButton.icon(onPressed:()=>openCompetitionFile(sheet,'Carte de jugement'),icon:const Icon(Icons.description_outlined),label:const Text('Carte de jugement')),
                ]),
              ),
            ]),
          );
        }),
      ]),
    ));
  }

  Future<void> exportCompetitionPdf()async{
    final items=sortedCompetitions();
    if(items.isEmpty)return;
    final rr=r!;
    final pdf=pw.Document(title:'Palmarès concours ${rr['name']}',author:'Les Lapibreizh',creator:'Carnet Santé Lapibreizh');
    pdf.addPage(pw.MultiPage(
      pageFormat:PdfPageFormat.a4,
      margin:const pw.EdgeInsets.all(28),
      header:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
        pw.Text('LES LAPIBREIZH',style:pw.TextStyle(fontSize:9,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#463622'))),
        pw.Text('Concours & Expositions',style:pw.TextStyle(fontSize:9,color:PdfColors.grey700)),
      ]),
      footer:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
        pw.Text('Palmarès généré par Carnet Santé Lapibreizh',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
        pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
      ]),
      build:(ctx)=>[
        pw.Container(
          padding:const pw.EdgeInsets.all(14),
          decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColor.fromHex('#D4AF67'),width:1.5),borderRadius:pw.BorderRadius.circular(10)),
          child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.stretch,children:[
            pw.Text('PALMARÈS CONCOURS & EXPOSITIONS',textAlign:pw.TextAlign.center,style:pw.TextStyle(fontSize:18,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#171512'))),
            pw.SizedBox(height:7),
            pw.Text(((rr['name']??'') as String).trim().isEmpty?'Lapin sans nom':rr['name'],textAlign:pw.TextAlign.center,style:pw.TextStyle(fontSize:15,fontWeight:pw.FontWeight.bold)),
            pw.Text('${((rr['breed']??'') as String).trim().isEmpty?'Race non renseignée':rr['breed']} • Tatouage : ${((rr['tattoo']??'') as String).trim().isEmpty?'—':rr['tattoo']}',textAlign:pw.TextAlign.center,style:const pw.TextStyle(fontSize:9,color:PdfColors.grey700)),
          ]),
        ),
        pw.SizedBox(height:12),
        ...items.map((item){
          final award=competitionAwardLabel(item);
          final grams=item['weightGrams'] is int?item['weightGrams'] as int:int.tryParse('${item['weightGrams']}')??0;
          return pw.Container(
            margin:const pw.EdgeInsets.only(bottom:8),
            padding:const pw.EdgeInsets.all(9),
            decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColor.fromHex('#D4AF67')),borderRadius:pw.BorderRadius.circular(7)),
            child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
              pw.Text('${item['date']??''} • ${((item['name']??'') as String).trim().isEmpty?'Concours / exposition':item['name']}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold,fontSize:12)),
              if(((item['location']??'') as String).trim().isNotEmpty)pw.Text('Lieu : ${item['location']}'),
              if(((item['category']??'') as String).trim().isNotEmpty)pw.Text('Classe / catégorie : ${item['category']}'),
              if(((item['judge']??'') as String).trim().isNotEmpty)pw.Text('Juge : ${item['judge']}'),
              if(((item['score']??'') as String).trim().isNotEmpty)pw.Text('Note : ${item['score']} points'),
              if(((item['qualification']??'') as String).trim().isNotEmpty&&item['qualification']!='Non renseigné')pw.Text('Qualificatif : ${item['qualification']}'),
              if(((item['ranking']??'') as String).trim().isNotEmpty)pw.Text('Classement : ${item['ranking']}'),
              if(award.isNotEmpty&&award!='Aucune')pw.Text('Récompense : $award',style:pw.TextStyle(fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#B35C00'))),
              if(grams>0)pw.Text('Poids du jour : $grams g'),
              if(((item['cageNumber']??'') as String).trim().isNotEmpty)pw.Text('N° cage / passage : ${item['cageNumber']}'),
              if(((item['comments']??'') as String).trim().isNotEmpty)pw.Text('Appréciations : ${item['comments']}'),
            ]),
          );
        }),
      ],
    ));
    final dir=await getTemporaryDirectory();
    final name=((rr['name']??'Lapin') as String).trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]+'),'_');
    final file=File('${dir.path}/Palmares-Concours-${name.isEmpty?'Lapin':name}.pdf');
    await file.writeAsBytes(await pdf.save(),flush:true);
    if(!mounted)return;
    await Share.shareXFiles([XFile(file.path)],subject:'Palmarès concours de ${rr['name']}',text:'Historique Concours & Expositions généré par Carnet Santé Lapibreizh.');
  }

  DateTime? engagementEarliestDeparture(){
    final d=Notifications.parseDate(r!['engagementDeliveryDate'] as String?);
    return d?.add(const Duration(days:7));
  }

  Future<File> _buildEngagementCertificatePdf(Map<String,dynamic> data)async{
    final pdf=pw.Document(
      title:'Certificat d’engagement et de connaissance - lapin',
      author:'Les Lapibreizh',
      creator:'Carnet Santé Lapibreizh',
    );

    pw.MemoryImage? mentionImage;
    pw.MemoryImage? signatureImage;
    final mentionPath=((data['engagementMentionImage']??'') as String);
    final signaturePath=((data['engagementSignatureImage']??'') as String);
    if(mentionPath.isNotEmpty&&File(mentionPath).existsSync()){
      try{mentionImage=pw.MemoryImage(await File(mentionPath).readAsBytes());}catch(_){}
    }
    if(signaturePath.isNotEmpty&&File(signaturePath).existsSync()){
      try{signatureImage=pw.MemoryImage(await File(signaturePath).readAsBytes());}catch(_){}
    }

    final delivered=Notifications.parseDate(data['engagementDeliveryDate'] as String?);
    final earliest=delivered?.add(const Duration(days:7));
    final rabbitName=((r!['name']??'') as String).trim();
    final breed=((r!['breed']??'') as String).trim();

    pw.Widget sectionTitle(String value)=>pw.Container(
      margin:const pw.EdgeInsets.only(top:12,bottom:5),
      padding:const pw.EdgeInsets.symmetric(horizontal:9,vertical:6),
      decoration:pw.BoxDecoration(color:PdfColor.fromHex('#171512'),borderRadius:pw.BorderRadius.circular(6)),
      child:pw.Text(value,style:pw.TextStyle(color:PdfColor.fromHex('#D4AF67'),fontWeight:pw.FontWeight.bold,fontSize:12)),
    );

    pw.Widget line(String label,dynamic value){
      final s=(value??'').toString().trim();
      return pw.Padding(
        padding:const pw.EdgeInsets.symmetric(vertical:2),
        child:pw.Row(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
          pw.SizedBox(width:135,child:pw.Text(label,style:pw.TextStyle(fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#463622')))),
          pw.Expanded(child:pw.Text(s.isEmpty?'—':s)),
        ]),
      );
    }

    pdf.addPage(pw.MultiPage(
      pageFormat:PdfPageFormat.a4,
      margin:const pw.EdgeInsets.all(28),
      header:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
        pw.Text('LES LAPIBREIZH',style:pw.TextStyle(fontSize:9,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#463622'))),
        pw.Text('Certificat d’engagement et de connaissance • Lapin',style:pw.TextStyle(fontSize:8,color:PdfColors.grey700)),
      ]),
      footer:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
        pw.Text('Document généré par Carnet Santé Lapibreizh',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
        pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
      ]),
      build:(ctx)=>[
        pw.Container(
          padding:const pw.EdgeInsets.all(14),
          decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColor.fromHex('#D4AF67'),width:1.5),borderRadius:pw.BorderRadius.circular(10)),
          child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.stretch,children:[
            pw.Text('CERTIFICAT D’ENGAGEMENT ET DE CONNAISSANCE',textAlign:pw.TextAlign.center,style:pw.TextStyle(fontSize:17,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#171512'))),
            pw.SizedBox(height:4),
            pw.Text('Acquisition d’un lapin de compagnie',textAlign:pw.TextAlign.center,style:pw.TextStyle(fontSize:12,color:PdfColor.fromHex('#463622'))),
          ]),
        ),

        sectionTitle('Personne qui reçoit le certificat'),
        line('Nom / prénom',data['engagementRecipientName']),
        line('Adresse',data['engagementRecipientAddress']),
        line('Contact / e-mail',data['engagementRecipientEmail']),

        sectionTitle('Délivrance du certificat'),
        line('Délivré par',data['engagementIssuerName']),
        line('Qualité / habilitation',data['engagementIssuerQualification']),
        line('Référence',data['engagementIssuerReference']),
        line('Date de délivrance',data['engagementDeliveryDate']),
        if(earliest!=null)line('Cession possible dès le',Notifications.formatDate(earliest)),

        sectionTitle('Animal concerné'),
        line('Nom du lapin',rabbitName),
        line('Race',breed),
        line('Identification',r!['identification']),
        line('Tatouage',r!['tattoo']),

        sectionTitle('Besoins physiologiques'),
        pw.Bullet(text:'Accès permanent à une alimentation adaptée, avec du foin de qualité et de l’eau propre à volonté.'),
        pw.Bullet(text:'Espace de vie suffisant, exercice quotidien, zones de repos et environnement sécurisé.'),
        pw.Bullet(text:'Conditions de température, d’hygiène et d’hébergement compatibles avec les besoins du lapin.'),

        sectionTitle('Besoins comportementaux'),
        pw.Bullet(text:'Possibilité d’explorer, se cacher, ronger, creuser, se déplacer et adopter ses comportements naturels.'),
        pw.Bullet(text:'Interactions sociales adaptées et manipulations respectueuses du tempérament et du bien-être de l’animal.'),
        pw.Bullet(text:'Enrichissement régulier et prévention de l’ennui.'),

        sectionTitle('Besoins médicaux'),
        pw.Bullet(text:'Suivi régulier par un vétérinaire compétent en médecine du lapin et vaccination selon les recommandations vétérinaires.'),
        pw.Bullet(text:'Surveillance quotidienne de l’appétit, du transit, du comportement, des dents, du poids et de l’état général.'),
        pw.Bullet(text:'Consultation rapide en cas de baisse d’appétit, arrêt du transit, douleur, abattement ou autre signe inhabituel.'),

        sectionTitle('Identification'),
        pw.Text('Le futur détenteur doit connaître les règles d’identification applicables à sa situation et l’intérêt d’une identification permettant de relier l’animal à son détenteur.'),

        sectionTitle('Implications financières et logistiques'),
        pw.Text('La détention d’un lapin implique des dépenses et une organisation durables : alimentation, habitat et enrichissement, soins vétérinaires, vaccinations, garde pendant les absences, transport et éventuels soins d’urgence.'),

        sectionTitle('Engagement de l’acquéreur'),
        pw.Text('Mention à recopier de façon manuscrite :',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
        pw.SizedBox(height:4),
        pw.Container(
          padding:const pw.EdgeInsets.all(8),
          decoration:pw.BoxDecoration(color:PdfColors.grey100,borderRadius:pw.BorderRadius.circular(6)),
          child:pw.Text('Je m’engage expressément à respecter, durant toute sa vie, les besoins physiologiques, comportementaux et médicaux de mon lapin.'),
        ),
        if(mentionImage!=null)...[
          pw.SizedBox(height:8),
          pw.Text('Mention manuscrite du signataire :',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
          pw.Container(height:90,alignment:pw.Alignment.centerLeft,child:pw.Image(mentionImage!,fit:pw.BoxFit.contain)),
        ],
        pw.SizedBox(height:6),
        line('Fait à',data['engagementPlace']),
        line('Signé le',data['engagementSignedDate']),
        if(signatureImage!=null)...[
          pw.Text('Signature manuscrite numérique :',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
          pw.Container(height:75,alignment:pw.Alignment.centerLeft,child:pw.Image(signatureImage!,fit:pw.BoxFit.contain)),
        ],
        pw.SizedBox(height:10),
        pw.Text(
          'La cession ne peut intervenir moins de sept jours après la délivrance du certificat. '
          'Ce document atteste des informations enregistrées et de la signature manuscrite numérique apposée dans l’application.',
          style:pw.TextStyle(fontSize:9,color:PdfColors.grey700),
        ),
      ],
    ));

    final bytes=await pdf.save();
    final dir=await getTemporaryDirectory();
    final safeName=(rabbitName.isEmpty?'Lapin':rabbitName).replaceAll(RegExp(r'[^A-Za-z0-9_-]+'),'_');
    final file=File('${dir.path}/Certificat-Engagement-$safeName.pdf');
    await file.writeAsBytes(bytes,flush:true);
    return file;
  }

  Future<void> editEngagementCertificate()async{
    final data=Map<String,dynamic>.from(r!);
    await showDialog(
      context:context,
      builder:(ctx)=>EngagementCertificateDialog(
        data:data,
        onSave:(v)async{
          final oldMention=((r!['engagementMentionImage']??'') as String);
          final oldSignature=((r!['engagementSignatureImage']??'') as String);
          final oldPdf=((r!['engagementCertificatePdf']??'') as String);

          r=v;
          final generated=await _buildEngagementCertificatePdf(v);
          final savedPdf=await PrivateFiles.importFile(generated.path,'documents');
          r!['engagementCertificatePdf']=savedPdf;
          await persist();

          if(oldMention.isNotEmpty&&oldMention!=r!['engagementMentionImage'])await PrivateFiles.deleteFile(oldMention);
          if(oldSignature.isNotEmpty&&oldSignature!=r!['engagementSignatureImage'])await PrivateFiles.deleteFile(oldSignature);
          if(oldPdf.isNotEmpty&&oldPdf!=savedPdf)await PrivateFiles.deleteFile(oldPdf);

          if(ctx.mounted)Navigator.pop(ctx);
          if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Certificat d’engagement enregistré et archivé en PDF.')));
        },
      ),
    );
  }

  Future<void> viewEngagementCertificate()async{
    final p=((r!['engagementCertificatePdf']??'') as String);
    if(p.isEmpty||!File(p).existsSync())return;
    await OpenFilex.open(p);
  }

  Future<void> shareEngagementCertificate()async{
    final p=((r!['engagementCertificatePdf']??'') as String);
    if(p.isEmpty||!File(p).existsSync())return;
    await Share.shareXFiles(
      [XFile(p)],
      subject:'Certificat d’engagement et de connaissance',
      text:'Certificat d’engagement et de connaissance pour l’acquisition d’un lapin de compagnie.',
    );
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
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Supprimer ce document ?'),content:const Text('La copie enregistrée dans le carnet sera supprimée. Le fichier original ne sera pas touché.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))]))??false;
    if(ok){await PrivateFiles.deleteFile(p);r![key]='';await persist();}
  }

  pw.Widget _pdfTitle(String title){
    return pw.Container(
      margin:const pw.EdgeInsets.only(top:14,bottom:6),
      padding:const pw.EdgeInsets.symmetric(horizontal:10,vertical:7),
      decoration:pw.BoxDecoration(
        color:PdfColor.fromHex('#171512'),
        borderRadius:pw.BorderRadius.circular(8),
      ),
      child:pw.Text(title,style:pw.TextStyle(color:PdfColor.fromHex('#D4AF67'),fontSize:14,fontWeight:pw.FontWeight.bold)),
    );
  }
  pw.Widget _pdfLine(String label,dynamic value){
    final s=(value??'').toString().trim();
    return pw.Padding(
      padding:const pw.EdgeInsets.symmetric(vertical:2),
      child:pw.Row(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
        pw.SizedBox(width:120,child:pw.Text(label,style:pw.TextStyle(fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#463622')))),
        pw.Expanded(child:pw.Text(s.isEmpty?'—':s)),
      ]),
    );
  }

  Future<void> exportPdf() async {
    try{
      final rr=r!;
      final pdf=pw.Document(
        title:'Carnet de santé de ${((rr['name']??'') as String).isEmpty?'Lapin':rr['name']}',
        author:'Les Lapibreizh',
        creator:'Carnet Santé Lapibreizh',
      );

      pw.MemoryImage? rabbitImage;
      final photo=((rr['photo']??'') as String);
      if(photo.isNotEmpty&&File(photo).existsSync()){
        try{rabbitImage=pw.MemoryImage(await File(photo).readAsBytes());}catch(_){}
      }

      final rabbitId=((rr['id']??'') as String);
      final linkedBreedings=breedings.where((b)=>b['maleId']==rabbitId||b['femaleId']==rabbitId).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat:PdfPageFormat.a4,
          margin:const pw.EdgeInsets.all(28),
          header:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
            pw.Text('LES LAPIBREIZH',style:pw.TextStyle(fontSize:9,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#463622'))),
            pw.Text('Carnet de santé',style:pw.TextStyle(fontSize:9,color:PdfColors.grey700)),
          ]),
          footer:(ctx)=>pw.Row(mainAxisAlignment:pw.MainAxisAlignment.spaceBetween,children:[
            pw.Text('Document généré par Carnet Santé Lapibreizh',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
            pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}',style:const pw.TextStyle(fontSize:8,color:PdfColors.grey600)),
          ]),
          build:(ctx)=>[
            pw.Container(
              padding:const pw.EdgeInsets.all(14),
              decoration:pw.BoxDecoration(
                border:pw.Border.all(color:PdfColor.fromHex('#D4AF67'),width:1.5),
                borderRadius:pw.BorderRadius.circular(12),
              ),
              child:pw.Row(crossAxisAlignment:pw.CrossAxisAlignment.center,children:[
                if(rabbitImage!=null)
                  pw.Container(
                    width:86,height:86,
                    decoration:pw.BoxDecoration(borderRadius:pw.BorderRadius.circular(10)),
                    child:pw.ClipRRect(horizontalRadius:10,verticalRadius:10,child:pw.Image(rabbitImage!,fit:pw.BoxFit.cover)),
                  ),
                if(rabbitImage!=null)pw.SizedBox(width:14),
                pw.Expanded(child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
                  pw.Text(
                    ((rr['name']??'') as String).trim().isEmpty?'Lapin sans nom':rr['name'],
                    style:pw.TextStyle(fontSize:24,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#171512')),
                  ),
                  pw.SizedBox(height:4),
                  pw.Text(((rr['breed']??'') as String).trim().isEmpty?'Race non renseignée':rr['breed'],style:pw.TextStyle(fontSize:12,color:PdfColor.fromHex('#463622'))),
                  pw.SizedBox(height:8),
                  pw.Text('Dossier individuel de santé',style:pw.TextStyle(fontSize:11,fontWeight:pw.FontWeight.bold,color:PdfColor.fromHex('#D4AF67'))),
                ])),
              ]),
            ),

            _pdfTitle('Identité'),
            _pdfLine('Sexe',rr['sex']),
            _pdfLine('Statut',rr['sterilized']),
            _pdfLine('Naissance',rr['birth']),
            _pdfLine('Sevrage',rr['weaning']),
            _pdfLine('Identification',rr['identification']),
            _pdfLine('Tatouage',rr['tattoo']),

            _pdfTitle('Filiation'),
            _pdfLine('Père',rr['fatherName']),
            _pdfLine('Race du père',rr['fatherBreed']),
            _pdfLine('Mère',rr['motherName']),
            _pdfLine('Race de la mère',rr['motherBreed']),

            _pdfTitle('Suivi du poids'),
            if(((rr['weights'] as List?)??[]).isEmpty)
              pw.Text('Aucune pesée enregistrée.')
            else
              pw.TableHelper.fromTextArray(
                headers:['Date','Poids','Note'],
                data:((rr['weights'] as List?)??[]).map((e){
                  final w=e as Map;
                  final grams=w['grams'] is int?w['grams'] as int:int.tryParse('${w['grams']}')??0;
                  return [
                    w['date']??'',
                    grams>0?'$grams g':'—',
                    w['note']??'',
                  ];
                }).toList(),
                headerDecoration:pw.BoxDecoration(color:PdfColor.fromHex('#F1E4C6')),
                headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold),
                cellStyle:const pw.TextStyle(fontSize:9),
                cellPadding:const pw.EdgeInsets.all(5),
              ),

            _pdfTitle('Traitements médicaux'),
            if(((rr['medications'] as List?)??[]).isEmpty)
              pw.Text('Aucun traitement médical enregistré.')
            else
              ...sortedMedications().map((item){
                final times=((item['times'] as List?)??[]).map((e)=>e.toString()).join(', ');
                final completed=(item['completed']??false)==true;
                return pw.Container(
                  margin:const pw.EdgeInsets.only(bottom:6),
                  padding:const pw.EdgeInsets.all(7),
                  decoration:pw.BoxDecoration(color:PdfColors.grey100,borderRadius:pw.BorderRadius.circular(6)),
                  child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
                    pw.Text('${item['name']??'Médicament'} • ${completed?'Terminé':'En cours'}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
                    if(((item['reason']??'') as String).isNotEmpty)pw.Text('Motif : ${item['reason']}'),
                    pw.Text('Période : ${item['startDate']??''}${((item['endDate']??'') as String).isNotEmpty?' → ${item['endDate']}':' • sans date de fin'}'),
                    if(((item['dose']??'') as String).isNotEmpty)pw.Text('Dose : ${item['dose']}${((item['route']??'') as String).isNotEmpty?' • ${item['route']}':''}'),
                    if(times.isNotEmpty)pw.Text('Horaires : $times'),
                    if(((item['vet']??'') as String).isNotEmpty)pw.Text('Prescrit / suivi : ${item['vet']}'),
                    if(((item['notes']??'') as String).isNotEmpty)pw.Text('Notes : ${item['notes']}'),
                  ]),
                );
              }),

            _pdfTitle('Vaccins'),
            if(((rr['vaccines'] as List?)??[]).isEmpty)
              pw.Text('Aucun vaccin enregistré.')
            else
              pw.TableHelper.fromTextArray(
                headers:['Date','Produit'],
                data:((rr['vaccines'] as List?)??[]).map((e)=>[
                  (e as Map)['date']??'',
                  e['product']??'',
                ]).toList(),
                headerDecoration:pw.BoxDecoration(color:PdfColor.fromHex('#F1E4C6')),
                headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold),
                cellStyle:const pw.TextStyle(fontSize:9),
                cellPadding:const pw.EdgeInsets.all(5),
              ),

            _pdfTitle('Vermifuges'),
            if(((rr['dewormings'] as List?)??[]).isEmpty)
              pw.Text('Aucun vermifuge enregistré.')
            else
              pw.TableHelper.fromTextArray(
                headers:['Date','Produit'],
                data:((rr['dewormings'] as List?)??[]).map((e)=>[
                  (e as Map)['date']??'',
                  e['product']??'',
                ]).toList(),
                headerDecoration:pw.BoxDecoration(color:PdfColor.fromHex('#F1E4C6')),
                headerStyle:pw.TextStyle(fontWeight:pw.FontWeight.bold),
                cellStyle:const pw.TextStyle(fontSize:9),
                cellPadding:const pw.EdgeInsets.all(5),
              ),

            _pdfTitle('Rendez-vous vétérinaires'),
            if(((rr['appointments'] as List?)??[]).isEmpty)
              pw.Text('Aucun rendez-vous enregistré.')
            else
              ...((rr['appointments'] as List?)??[]).map((raw){
                final a=raw as Map;
                return pw.Container(
                  margin:const pw.EdgeInsets.only(bottom:6),
                  padding:const pw.EdgeInsets.all(7),
                  decoration:pw.BoxDecoration(
                    color:PdfColors.grey100,
                    borderRadius:pw.BorderRadius.circular(6),
                  ),
                  child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
                    pw.Text('${a['date']??''} • ${a['time']??''}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
                    if(((a['reason']??'') as String).isNotEmpty)pw.Text('Motif : ${a['reason']}'),
                    if(((a['vet']??'') as String).isNotEmpty)pw.Text('Vétérinaire : ${a['vet']}'),
                    if(((a['description']??'') as String).isNotEmpty)pw.Text('Notes : ${a['description']}'),
                  ]),
                );
              }),

            if(appMode=='Éleveur'&&((rr['competitions'] as List?)??[]).isNotEmpty)...[
              _pdfTitle('Concours & Expositions'),
              ...sortedCompetitions().map((item){
                final award=competitionAwardLabel(item);
                return pw.Container(
                  margin:const pw.EdgeInsets.only(bottom:6),
                  padding:const pw.EdgeInsets.all(7),
                  decoration:pw.BoxDecoration(color:PdfColors.grey100,borderRadius:pw.BorderRadius.circular(6)),
                  child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
                    pw.Text('${item['date']??''} • ${((item['name']??'') as String).trim().isEmpty?'Concours / exposition':item['name']}',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
                    if(((item['location']??'') as String).trim().isNotEmpty)pw.Text('Lieu : ${item['location']}'),
                    if(((item['score']??'') as String).trim().isNotEmpty)pw.Text('Note : ${item['score']} pts'),
                    if(((item['ranking']??'') as String).trim().isNotEmpty)pw.Text('Classement : ${item['ranking']}'),
                    if(award.isNotEmpty&&award!='Aucune')pw.Text('Récompense : $award'),
                  ]),
                );
              }),
            ],

            if(appMode=='Éleveur')...[
              _pdfTitle('Adoption / départ'),
              _pdfLine('Statut',rr['adoptionStatus']),
              _pdfLine('Adoptant',rr['adopterName']),
              _pdfLine('Contact',rr['adopterContact']),
              _pdfLine('Date de départ',rr['departureDate']),
              _pdfLine('Notes',rr['adoptionNotes']),
              _pdfLine('Carnet remis',(rr['healthBookGiven']??false)==true?'Oui':'Non'),
              _pdfLine('Certificat remis',(rr['healthCertificateGiven']??false)==true?'Oui':'Non'),
              _pdfLine('Consignes remises',(rr['adoptionInfoGiven']??false)==true?'Oui':'Non'),
              _pdfLine('Certificat engagement',(rr['engagementAccepted']??false)==true?'Signé':'Non signé'),
              _pdfLine('Délivré le',rr['engagementDeliveryDate']),
              _pdfLine('Signé le',rr['engagementSignedDate']),
            ],

            if(appMode=='Éleveur'&&linkedBreedings.isNotEmpty)...[
              _pdfTitle('Reproduction'),
              ...linkedBreedings.map((b){
                final t=ReproductionStore.totals(b);
                final partner=(rr['sex']=='Mâle')
                    ? rabbitNameById((b['femaleId']??'') as String)
                    : rabbitNameById((b['maleId']??'') as String);
                return pw.Container(
                  margin:const pw.EdgeInsets.only(bottom:6),
                  padding:const pw.EdgeInsets.all(7),
                  decoration:pw.BoxDecoration(border:pw.Border.all(color:PdfColor.fromHex('#D4AF67')),borderRadius:pw.BorderRadius.circular(6)),
                  child:pw.Column(crossAxisAlignment:pw.CrossAxisAlignment.start,children:[
                    pw.Text('${b['matingDate']??'Date non renseignée'} • $partner',style:pw.TextStyle(fontWeight:pw.FontWeight.bold)),
                    pw.Text('Nés : ${t['born']} • Vivants : ${t['liveBirth']} • Morts : ${t['deadBirth']}'),
                    if(((b['weaningDate']??'') as String).isNotEmpty)pw.Text('Sevrage : ${b['weaningDate']} • Vivants : ${t['weaned']}'),
                  ]),
                );
              }),
            ],

            _pdfTitle('Documents'),
            _pdfLine('Carnet de santé',((rr['healthBook']??'') as String).isEmpty?'Non joint':'Joint dans l’application'),
            _pdfLine('Passeport',((rr['passport']??'') as String).isEmpty?'Non joint':'Joint dans l’application'),

            pw.SizedBox(height:16),
            pw.Text(
              'Ce document reprend les informations enregistrées dans l’application et ne remplace pas un document vétérinaire officiel.',
              style:pw.TextStyle(fontSize:8,color:PdfColors.grey600),
            ),
          ],
        ),
      );

      final dir=await getTemporaryDirectory();
      final name=((rr['name']??'Lapin') as String).trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]+'),'_');
      final file=File('${dir.path}/Carnet-Sante-${name.isEmpty?'Lapin':name}.pdf');
      await file.writeAsBytes(await pdf.save(),flush:true);

      if(!mounted)return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject:'Carnet de santé de ${((rr['name']??'') as String).isEmpty?'Lapin':rr['name']}',
        text:'Dossier PDF généré par Carnet Santé Lapibreizh.',
      );
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Création du PDF impossible : $e')));
    }
  }

  Future<void> share()async{
    final rr=r!; final text="Carnet de santé – Les Lapibreizh\n\n${rr['name']}\nSexe : ${rr['sex']}\nRace : ${rr['breed']}\nNaissance : ${rr['birth']}\nSevrage : ${rr['weaning']}\n\nPère : ${rr['fatherName']} – ${rr['fatherBreed']} – ${rr['fatherBirth']}\nMère : ${rr['motherName']} – ${rr['motherBreed']} – ${rr['motherBirth']}\n\nVaccins :\n${lines(rr['vaccines'])}\n\nVermifuges :\n${lines(rr['dewormings'])}";
    final paths=<String>[]; for(final k in ['photo','healthBook','passport']){final p=rr[k];if(p is String&&p.isNotEmpty&&File(p).existsSync())paths.add(p);} for(final k in ['vaccines','dewormings']){for(final x in rr[k] as List){final p=x['photo'];if(p is String&&p.isNotEmpty&&File(p).existsSync())paths.add(p);}}
    if(paths.isEmpty){await Share.share(text,subject:'Carnet de santé de ${rr['name']}');}else{await Share.shareXFiles(paths.map((p)=>XFile(p)).toList(),text:text,subject:'Carnet de santé de ${rr['name']}');}
  }
  String lines(dynamic l){final x=l as List;if(x.isEmpty)return 'Aucun enregistrement';return x.map((e)=>'• ${e['date']} — ${e['product']}').join('\n');}
  Future<void> deleteRabbit()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Supprimer cette fiche ?'),content:const Text('Cette action retire la fiche du carnet.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))]))??false;if(ok){
    final doomed=Map<String,dynamic>.from(r!);
    await Notifications.cancelRabbit(doomed);
    await ReproductionStore.removeRabbit((doomed['id']??'') as String);
    for(final k in ['photo','healthBook','passport','engagementMentionImage','engagementSignatureImage','engagementCertificatePdf']){await PrivateFiles.deleteFile((doomed[k]??'') as String);}
    for(final k in ['vaccines','dewormings']){for(final x in doomed[k] as List){await PrivateFiles.deleteFile((x['photo']??'') as String);}}
    for(final raw in ((doomed['medications'] as List?)??[])){
      final x=raw as Map;
      await Notifications.cancelToken((x['notificationKey']??'') as String);
      await PrivateFiles.deleteFile((x['photo']??'') as String);
      await PrivateFiles.deleteFile((x['prescription']??'') as String);
    }
    for(final x in ((doomed['competitions'] as List?)??[])){
      await PrivateFiles.deleteFile(((x as Map)['photo']??'') as String);
      await PrivateFiles.deleteFile((x['judgingSheet']??'') as String);
    }
    all.removeAt(widget.index);await Store.save(all);if(mounted)Navigator.pop(context);
  }}

  List<String> get visibleRabbitOrder{
    final defaults=appMode=='Éleveur'?rabbitDefaultsEleveur:rabbitDefaultsAdoptant;
    return rabbitOrder.where((id){
      if(!defaults.contains(id))return false;
      if(id=='reproduction'){
        final sex=(r?['sex']??'') as String;
        return sex=='Mâle'||sex=='Femelle';
      }
      return true;
    }).toList();
  }

  Future<void> toggleRabbitOrganizing(bool value) async {
    if(value){
      setState(()=>rabbitOrganizing=true);
      return;
    }
    final defaults=appMode=='Éleveur'?rabbitDefaultsEleveur:rabbitDefaultsAdoptant;
    await LayoutStore.save(appMode=='Éleveur'?'rabbit_eleveur':'rabbit_adoptant',rabbitOrder,defaults);
    if(!mounted)return;
    setState(()=>rabbitOrganizing=false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nouvel ordre enregistré.')));
  }

  void reorderRabbit(int oldIndex,int newIndex){
    final visible=visibleRabbitOrder;
    if(newIndex>oldIndex)newIndex--;
    final moved=visible.removeAt(oldIndex);
    visible.insert(newIndex,moved);
    final visibleSet=visibleRabbitOrder.toSet();
    final queue=List<String>.from(visible);
    final updated=<String>[];
    for(final id in rabbitOrder){
      if(visibleSet.contains(id)){
        updated.add(queue.removeAt(0));
      }else{
        updated.add(id);
      }
    }
    setState(()=>rabbitOrder=updated);
  }

  Widget rabbitOrganizeControl()=>Container(
    margin:const EdgeInsets.only(bottom:8),
    padding:const EdgeInsets.fromLTRB(12,10,10,10),
    decoration:BoxDecoration(
      color:rabbitOrganizing?const Color(0xFFE8F3EC):premiumCard,
      borderRadius:BorderRadius.circular(18),
      border:Border.all(color:rabbitOrganizing?gold:softGoldLine,width:rabbitOrganizing?1.15:.9),
      boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.03), blurRadius: 12, offset: const Offset(0, 5))],
    ),
    child:Row(children:[
      Container(
        width:34,height:34,
        decoration:BoxDecoration(color:const Color(0xFFE8F3EC),borderRadius:BorderRadius.circular(5)),
        child:Icon(rabbitOrganizing?Icons.drag_indicator:Icons.tune,color:lapiGreenDark,size:20),
      ),
      const SizedBox(width:10),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Organiser',style:TextStyle(fontWeight:FontWeight.w900,color:ink)),
        Text(
          rabbitOrganizing
            ?'Maintenez un cadre appuyé pour le déplacer.'
            :'Personnalisez l’ordre de cette fiche.',
          style:const TextStyle(fontSize:10,color:Colors.black54),
        ),
      ])),
      Switch(value:rabbitOrganizing,onChanged:toggleRabbitOrganizing),
    ]),
  );

  Widget rabbitSection(String id,Map<String,dynamic> rr){
    switch(id){
      case 'identity':
        return section('Identité',Icons.badge,[
          info('Sexe',rr['sex']),info('Statut',rr['sterilized']),info('Naissance',rr['birth']),
          info('Sevrage',rr['weaning']),info('Race',rr['breed']),info('Couleur / variété',rr['color']),
          info('Identification (facultatif)',rr['identification']),info('Tatouage (facultatif)',rr['tattoo']),
        ]);
      case 'filiation':
        return section('Filiation',Icons.account_tree,[
          info('Père',rr['fatherName']),info('Race du père',rr['fatherBreed']),info('Couleur du père',rr['fatherColor']),info('Naissance du père',rr['fatherBirth']),
          const Divider(),
          info('Mère',rr['motherName']),info('Race de la mère',rr['motherBreed']),info('Couleur de la mère',rr['motherColor']),info('Naissance de la mère',rr['motherBirth']),
        ]);
      case 'alerts': return dataAlertsSection();
      case 'health': return healthJourneySection();
      case 'medications': return medicationsSection();
      case 'weight': return weightSection();
      case 'adoption': return adoptionSection();
      case 'reproduction': return reproductionSection();
      case 'competitions': return competitionsSection();
      case 'vaccines': return treatmentSection('Vaccins','vaccines',Icons.vaccines);
      case 'dewormings': return treatmentSection('Vermifuges','dewormings',Icons.medication);
      case 'appointments': return appointmentSection();
      case 'documents':
        return PremiumCard(child:Padding(
          padding:const EdgeInsets.all(10),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            header('Documents',Icons.folder_copy),
            docButton('Carnet de santé','healthBook'),
            const SizedBox(height:8),
            docButton('Passeport','passport'),
          ]),
        ));
      default: return const SizedBox.shrink();
    }
  }

  Widget rabbitFrame(String id,int index,Widget child){
    final content=Padding(
      padding:const EdgeInsets.only(bottom:10),
      child:AbsorbPointer(
        absorbing:rabbitOrganizing,
        child:child,
      ),
    );
    return rabbitOrganizing
        ?ReorderableDelayedDragStartListener(
            key:ValueKey('rabbit_$id'),
            index:index,
            child:content,
          )
        :KeyedSubtree(key:ValueKey('rabbit_$id'),child:content);
  }

  @override Widget build(BuildContext context){
    if(r==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    final rr=r!;
    final visible=visibleRabbitOrder;

    final photoCard=Container(
      decoration:BoxDecoration(
        gradient:const LinearGradient(colors:[premiumCard, Color(0xFFFFFCF4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius:BorderRadius.circular(14),
        border:Border.all(color:lineSoft),
        boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.04), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child:Padding(
        padding:const EdgeInsets.all(14),
        child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(crossAxisAlignment:CrossAxisAlignment.center,children:[
          GestureDetector(
            onTap:rabbitOrganizing?null:showRabbitPhoto,
            child:Hero(
              tag:'rabbit${widget.index}',
              child:Container(
                width:94,height:94,
                decoration:BoxDecoration(
                  color:mist,
                  borderRadius:BorderRadius.circular(18),
                  border:Border.all(color:gold.withValues(alpha:.55)),
                  boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.04), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                clipBehavior:Clip.antiAlias,
                child:rr['photo'].isEmpty
                  ?const Icon(Icons.add_a_photo_outlined,size:38,color:lapiGreenDark)
                  :Image.file(File(rr['photo']),fit:BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width:14),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(
              rr['name'].isEmpty?'Nom à renseigner':rr['name'],
              maxLines:2,
              overflow:TextOverflow.ellipsis,
              style:const TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:ink,height:1.05,fontFamily:'serif'),
            ),
            const SizedBox(height:8),
            if(rr['breed'].isNotEmpty)
              Text(rr['breed'],style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700,color:brown)),
            if(rr['sex'].isNotEmpty||rr['birth'].isNotEmpty)...[
              const SizedBox(height:5),
              Text(
                [rr['sex'],rr['birth']].where((e)=>(e??'').toString().isNotEmpty).join('  •  '),
                style:const TextStyle(fontSize:12,color:Colors.black54),
              ),
            ],
            const SizedBox(height:8),
            PremiumFilledButton.icon(
              onPressed:rabbitOrganizing?null:editIdentity,
              icon:const Icon(Icons.edit_outlined,size:18),
              label:const Text('Modifier la fiche'),
            ),
          ])),
        ]),
        const SizedBox(height:7),
        Row(children:[
          Expanded(child:OutlinedButton.icon(
            onPressed:rabbitOrganizing?null:replaceRabbitPhoto,
            icon:const Icon(Icons.photo_camera_outlined,size:18),
            label:Text(rr['photo'].isEmpty?'Ajouter une photo':'Changer la photo'),
          )),
          if(rr['photo'].isNotEmpty)...[
            const SizedBox(width:8),
            IconButton(
              tooltip:'Supprimer la photo',
              onPressed:rabbitOrganizing?null:removeRabbitPhoto,
              icon:const Icon(Icons.delete_outline,color:Colors.redAccent),
            ),
          ],
        ]),
      ]),
    ));

    final compactSections=visible.where((id)=>id!='health'&&id!='weight').toList();
    final leftIds=<String>[];
    final rightIds=<String>[];
    for(var i=0;i<compactSections.length;i++){
      (i.isEven?leftIds:rightIds).add(compactSections[i]);
    }

    Widget premiumColumn(List<String> ids)=>Column(
      crossAxisAlignment:CrossAxisAlignment.stretch,
      children:[
        for(var i=0;i<ids.length;i++)
          Padding(
            padding:const EdgeInsets.only(bottom:8),
            child:rabbitSection(ids[i],rr),
          ),
      ],
    );

    return Scaffold(
      bottomNavigationBar:Material(
        color:heroGreen,
        elevation:16,
        child:SafeArea(
          top:false,
          child:Container(
            decoration:const BoxDecoration(
              gradient:LinearGradient(colors:[Color(0xFF0D3A26),Color(0xFF145438)]),
              border:Border(top:BorderSide(color:Color(0x66D4AF67))),
            ),
            child:Row(children:[
              Expanded(child:_rabbitBottomNavItem(Icons.home_outlined,'Accueil',false,()=>Navigator.pop(context))),
              Expanded(child:_rabbitBottomNavItem(Icons.pets_outlined,'Mes lapins',true,(){})),
              Expanded(child:_rabbitBottomNavItem(Icons.notifications_none,'Rappels',false,(){})),
              Expanded(child:_rabbitBottomNavItem(Icons.more_horiz,'Plus',false,(){})),
            ]),
          ),
        ),
      ),
      body:Scenic(compact:true,child:SafeArea(child:CustomScrollView(slivers:[
        SliverAppBar(
          backgroundColor:lapiGreenDark,
          foregroundColor:Colors.white,
          surfaceTintColor:Colors.transparent,
          elevation:0,
          pinned:true,
          toolbarHeight:54,
          flexibleSpace:Container(
            decoration:const BoxDecoration(
              gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[heroGreen,heroGreen2]),
              border:Border(bottom:BorderSide(color:Color(0x55D4AF67))),
            ),
          ),
          title:Text(
            rr['name'].isEmpty?'Fiche du lapin':rr['name'],
            style:const TextStyle(fontFamily:'serif',fontSize:20,fontWeight:FontWeight.w800,color:Colors.white),
          ),
          actions:[
            IconButton(tooltip:'PDF',onPressed:rabbitOrganizing?null:exportPdf,icon:const Icon(Icons.picture_as_pdf,size:22)),
            IconButton(onPressed:rabbitOrganizing?null:share,icon:const Icon(Icons.share,size:22)),
            PopupMenuButton<String>(
              enabled:!rabbitOrganizing,
              onSelected:(v){if(v=='delete')deleteRabbit();},
              itemBuilder:(_)=>const [PopupMenuItem(value:'delete',child:Text('Supprimer la fiche'))],
            ),
          ],
        ),
        if(rabbitOrganizing)...[
          SliverPadding(
            padding:const EdgeInsets.fromLTRB(10,10,10,4),
            sliver:SliverList.list(children:[
              photoCard,
              modeBanner(),
              rabbitOrganizeControl(),
            ]),
          ),
          SliverPadding(
            padding:const EdgeInsets.symmetric(horizontal:10),
            sliver:SliverReorderableList(
              itemCount:visible.length,
              onReorder:reorderRabbit,
              itemBuilder:(context,index){
                final id=visible[index];
                return rabbitFrame(id,index,rabbitSection(id,rr));
              },
            ),
          ),
        ]else
          SliverToBoxAdapter(
            child:Padding(
              padding:const EdgeInsets.fromLTRB(10,10,10,4),
              child:LayoutBuilder(builder:(context,c){
                final useTwoColumns=c.maxWidth>=720;
                if(!useTwoColumns){
                  return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
                    photoCard,
                    const SizedBox(height:8),
                    modeBanner(),
                    rabbitOrganizeControl(),
                    if(visible.contains('health'))Padding(padding:const EdgeInsets.only(bottom:8),child:healthJourneySection()),
                    if(visible.contains('weight'))Padding(padding:const EdgeInsets.only(bottom:8),child:weightSection()),
                    ...compactSections.map((id)=>Padding(
                      padding:const EdgeInsets.only(bottom:8),
                      child:SizedBox(width:double.infinity,child:rabbitSection(id,rr)),
                    )),
                  ]);
                }
                return Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
                    photoCard,
                    const SizedBox(height:8),
                    modeBanner(),
                    rabbitOrganizeControl(),
                    premiumColumn(leftIds),
                  ])),
                  const SizedBox(width:8),
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
                    if(visible.contains('health'))Padding(padding:const EdgeInsets.only(bottom:8),child:healthJourneySection()),
                    if(visible.contains('weight'))Padding(padding:const EdgeInsets.only(bottom:8),child:weightSection()),
                    premiumColumn(rightIds),
                  ])),
                ]);
              }),
            ),
          ),
        SliverPadding(
          padding:const EdgeInsets.fromLTRB(10,4,10,24),
          sliver:SliverList.list(children:[
            Row(children:[
              Expanded(child:PremiumFilledButton.icon(onPressed:rabbitOrganizing?null:exportPdf,icon:const Icon(Icons.picture_as_pdf,size:19),label:const Text('Créer le dossier PDF'))),
              const SizedBox(width:8),
              Expanded(child:OutlinedButton.icon(onPressed:rabbitOrganizing?null:share,icon:const Icon(Icons.share,size:19),label:const Text('Partager la fiche'))),
            ]),
          ]),
        ),
      ]))),
    );
  }
  Widget _rabbitBottomNavItem(IconData icon,String label,bool selected,VoidCallback onTap)=>InkWell(
    onTap:onTap,
    child:Padding(
      padding:const EdgeInsets.symmetric(vertical:7),
      child:Column(mainAxisSize:MainAxisSize.min,children:[
        Icon(icon,size:23,color:selected?warmGoldText:Colors.white),
        const SizedBox(height:2),
        Text(label,style:TextStyle(fontSize:11,fontWeight:selected?FontWeight.w800:FontWeight.w600,color:selected?warmGoldText:Colors.white,fontFamily:selected?'serif':null)),
        if(selected)...[
          const SizedBox(height:3),
          Container(width:26,height:2,decoration:BoxDecoration(color:gold,borderRadius:BorderRadius.circular(99))),
        ],
      ]),
    ),
  );

  Widget header(String t,IconData i)=>Padding(
    padding:const EdgeInsets.only(bottom:9),
    child:Row(children:[
      Container(
        width:32,height:32,
        decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFFF3FAF4),Color(0xFFFFFBF3)]),borderRadius:BorderRadius.circular(12),border:Border.all(color:gold.withValues(alpha:.35))),
        child:Icon(i,color:lapiGreenDark,size:18),
      ),
      const SizedBox(width:10),
      Expanded(child:Text(t,style:const TextStyle(fontSize:16.5,fontWeight:FontWeight.w800,color:ink,height:1.05,fontFamily:'serif'))),
    ]),
  );
  Widget section(String t,IconData i,List<Widget> ch)=>Container(
    decoration:BoxDecoration(
      boxShadow:[BoxShadow(color:Colors.black.withValues(alpha:.03),blurRadius:12,offset:const Offset(0,6))],
    ),
    child:SizedBox(
      width:double.infinity,
      child:PremiumCard(
      shape:RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(14),
        side:const BorderSide(color:softGoldLine,width:.9),
      ),
      child:Stack(children:[
        Positioned(right:6,bottom:4,child:IgnorePointer(child:Icon(Icons.eco_outlined,color:gold.withValues(alpha:.42),size:22))),
        Padding(
          padding:const EdgeInsets.all(10),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header(t,i),...ch]),
        ),
      ]),
      ),
    ),
  );
  Widget info(String a,dynamic b){
    final value=(b??'').toString().isEmpty?'—':b.toString();
    return Container(
      padding:const EdgeInsets.symmetric(vertical:5),
      decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF0F2F0)))),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(flex:5,child:Text(a,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700,color:Color(0xFF68736C)))),
        const SizedBox(width:12),
        Expanded(flex:6,child:Text(value,style:const TextStyle(fontSize:11.5,fontWeight:FontWeight.w800,color:ink))),
      ]),
    );
  }
  Widget modeBanner()=>Container(
    margin:const EdgeInsets.only(bottom:8),
    padding:const EdgeInsets.symmetric(horizontal:13,vertical:12),
    decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[Color(0xFFF4FAF5),Color(0xFFF8F3E8)]),
      borderRadius:BorderRadius.circular(18),
      border:Border.all(color:gold.withValues(alpha:.30)),
      boxShadow:[BoxShadow(color: Colors.black.withValues(alpha:.03), blurRadius: 12, offset: const Offset(0, 5))],
    ),
    child:Row(children:[
      Icon(appMode=='Éleveur'?Icons.home_work_outlined:Icons.favorite_outline,color:lapiGreenDark),
      const SizedBox(width:10),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(appMode=='Éleveur'?'Mode élevage':'Mode adoptant',style:const TextStyle(color:lapiGreenDark,fontWeight:FontWeight.w900)),
        Text(
          appMode=='Éleveur'
            ?'Toutes les fonctions professionnelles sont visibles.'
            :'Une fiche simplifiée centrée sur le suivi quotidien.',
          style:const TextStyle(color:Color(0xFF506057),fontSize:11),
        ),
      ])),
    ]),
  );

  List<String> _dataAlerts(){
    final alerts=<String>[];
    if(((r!['name']??'') as String).trim().isEmpty)alerts.add('Nom du lapin à renseigner');
    if(((r!['birth']??'') as String).trim().isEmpty)alerts.add('Date de naissance à renseigner');
    if(((r!['sex']??'') as String).trim().isEmpty)alerts.add('Sexe à renseigner');
    if(((r!['breed']??'') as String).trim().isEmpty)alerts.add('Race à renseigner');
    if(((r!['vaccines'] as List?)??[]).isEmpty)alerts.add('Aucun vaccin enregistré dans le carnet');
    if(appMode=='Éleveur'){
      final status=((r!['adoptionStatus']??'À l’élevage') as String);
      if(status!='À l’élevage'&&((r!['adopterName']??'') as String).trim().isEmpty)alerts.add('Nom de l’adoptant à renseigner');
      if(status=='Adopté / parti'&&((r!['departureDate']??'') as String).trim().isEmpty)alerts.add('Date de départ à renseigner');
      final engagementSigned=(r!['engagementAccepted']??false) as bool &&
          ((r!['engagementDeliveryDate']??'') as String).trim().isNotEmpty &&
          ((r!['engagementCertificatePdf']??'') as String).trim().isNotEmpty;
      if(status!='À l’élevage'&&!engagementSigned)alerts.add('Certificat d’engagement et de connaissance à compléter');
      final delivery=Notifications.parseDate(r!['engagementDeliveryDate'] as String?);
      final departure=Notifications.parseDate(r!['departureDate'] as String?);
      if(status=='Adopté / parti'&&delivery!=null&&departure!=null){
        final earliest=delivery.add(const Duration(days:7));
        if(departure.isBefore(earliest))alerts.add('Délai légal de 7 jours du certificat d’engagement à respecter');
      }
    }
    return alerts;
  }

  Widget dataAlertsSection(){
    final alerts=_dataAlerts();
    if(alerts.isEmpty){
      return Container(
        margin:const EdgeInsets.symmetric(vertical:4),
        padding:const EdgeInsets.all(13),
        decoration:BoxDecoration(color:const Color(0xFF2E7A55).withValues(alpha:.08),borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFF2E7A55).withValues(alpha:.45))),
        child:const Row(children:[Icon(Icons.check_circle_outline,color:Color(0xFF2E7D32)),SizedBox(width:9),Expanded(child:Text('Les informations essentielles de cette fiche sont complètes.',style:TextStyle(fontWeight:FontWeight.w700,color:ink)))]),
      );
    }
    return PremiumCard(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Row(children:[
        Container(width:38,height:38,decoration:BoxDecoration(color:gold.withValues(alpha:.14),shape:BoxShape.circle),child:const Icon(Icons.fact_check_outlined,color:Color(0xFFEF6C00))),
        const SizedBox(width:9),
        const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('À compléter',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:ink,fontFamily:'serif')),Text('Quelques informations méritent votre attention.',style:TextStyle(fontSize:11,color:Colors.black54))])),
      ]),
      const SizedBox(height:7),
      ...alerts.take(5).map((a)=>Padding(padding:const EdgeInsets.only(bottom:5),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.circle,size:7,color:Color(0xFFEF6C00)),const SizedBox(width:8),Expanded(child:Text(a,style:const TextStyle(fontSize:13)))]))),
      if(alerts.length>5)Text('+ ${alerts.length-5} autre${alerts.length-5>1?'s':''} élément${alerts.length-5>1?'s':''}',style:const TextStyle(fontSize:12,color:Colors.black54,fontWeight:FontWeight.w700)),
      const SizedBox(height:8),
      Wrap(spacing:8,runSpacing:6,children:[
        OutlinedButton.icon(onPressed:editIdentity,icon:const Icon(Icons.badge_outlined),label:const Text('Identité')),
        if(appMode=='Éleveur')OutlinedButton.icon(onPressed:editAdoption,icon:const Icon(Icons.volunteer_activism_outlined),label:const Text('Adoption')),
      ]),
    ])));
  }

  Widget adoptionSection(){
    final status=((r!['adoptionStatus']??'À l’élevage') as String);
    final healthBookGiven=(r!['healthBookGiven']??false) as bool;
    final certificateGiven=(r!['healthCertificateGiven']??false) as bool;
    final infoGiven=(r!['adoptionInfoGiven']??false) as bool;
    final engagementOk=(r!['engagementAccepted']??false) as bool &&
        ((r!['engagementDeliveryDate']??'') as String).trim().isNotEmpty &&
        ((r!['engagementCertificatePdf']??'') as String).trim().isNotEmpty;
    final done=[healthBookGiven,certificateGiven,engagementOk,infoGiven].where((x)=>x).length;
    final progress=done/4;
    final earliest=engagementEarliestDeparture();
    final departure=Notifications.parseDate(r!['departureDate'] as String?);
    final delayOk=earliest==null||departure==null||!departure.isBefore(earliest);
    Color statusColor=status=='Adopté / parti'?const Color(0xFF2D7654):status=='Réservé'?const Color(0xFF9A762A):lapiGreenDark;

    Widget step(String label,bool ok)=>Padding(
      padding:const EdgeInsets.only(bottom:6),
      child:Row(children:[
        Icon(ok?Icons.check_circle:Icons.radio_button_unchecked,color:ok?const Color(0xFF2E7A55):Colors.black38,size:19),
        const SizedBox(width:8),
        Expanded(child:Text(label,style:TextStyle(fontSize:13,fontWeight:ok?FontWeight.w700:FontWeight.w500,color:ok?ink:Colors.black54))),
      ]),
    );

    return PremiumCard(child:Padding(
      padding:const EdgeInsets.all(10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        header('Adoption & départ',Icons.volunteer_activism_outlined),
        Row(children:[
          Container(
            padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
            decoration:BoxDecoration(color:statusColor.withValues(alpha:.11),borderRadius:BorderRadius.circular(15),border:Border.all(color:statusColor.withValues(alpha:.60))),
            child:Text(status,style:TextStyle(fontWeight:FontWeight.w900,color:statusColor)),
          ),
          const Spacer(),
          Text('$done / 4 prêts',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:brown)),
        ]),
        const SizedBox(height:11),
        ClipRRect(borderRadius:BorderRadius.circular(14),child:LinearProgressIndicator(value:progress,minHeight:9,backgroundColor:Colors.black.withValues(alpha:.07),color:gold)),
        const SizedBox(height:8),
        if(((r!['adopterName']??'') as String).trim().isNotEmpty)info('Adoptant',r!['adopterName']),
        if(((r!['adopterContact']??'') as String).trim().isNotEmpty)info('Contact',r!['adopterContact']),
        if(((r!['departureDate']??'') as String).trim().isNotEmpty)info('Départ',r!['departureDate']),

        const SizedBox(height:8),
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(color:gold.withValues(alpha:.07),borderRadius:BorderRadius.circular(15)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            const Text('Préparation du départ',style:TextStyle(fontWeight:FontWeight.w900,color:brown)),
            const SizedBox(height:8),
            step('Carnet de santé remis',healthBookGiven),
            step('Certificat de santé remis',certificateGiven),
            step('Certificat d’engagement complété et signé',engagementOk),
            step('Consignes / documents d’adoption remis',infoGiven),
          ]),
        ),

        const SizedBox(height:8),
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(
            color:engagementOk?const Color(0xFFEAF4EC):gold.withValues(alpha:.07),
            borderRadius:BorderRadius.circular(16),
            border:Border.all(color:engagementOk?const Color(0xFF9BC7AA):softGoldLine),
          ),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(children:[
              Icon(engagementOk?Icons.verified_outlined:Icons.draw_outlined,color:engagementOk?lapiGreenDark:gold),
              const SizedBox(width:8),
              const Expanded(child:Text('Certificat d’engagement et de connaissance',style:TextStyle(fontWeight:FontWeight.w900,color:ink))),
            ]),
            const SizedBox(height:5),
            if(engagementOk)...[
              Text('Délivré le ${r!['engagementDeliveryDate']} • signé le ${r!['engagementSignedDate']}',style:const TextStyle(fontSize:12,color:Colors.black54)),
              if(earliest!=null)Text('Cession possible à partir du ${Notifications.formatDate(earliest)}',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:brown)),
              if(!delayOk)const Padding(
                padding:EdgeInsets.only(top:6),
                child:Text('Attention : la date de départ renseignée ne respecte pas encore le délai minimal de 7 jours.',style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:Color(0xFFEF6C00))),
              ),
              const SizedBox(height:8),
              Wrap(spacing:6,runSpacing:6,children:[
                OutlinedButton.icon(onPressed:viewEngagementCertificate,icon:const Icon(Icons.picture_as_pdf),label:const Text('Voir le PDF')),
                OutlinedButton.icon(onPressed:shareEngagementCertificate,icon:const Icon(Icons.share),label:const Text('Remettre une copie')),
                TextButton.icon(onPressed:editEngagementCertificate,icon:const Icon(Icons.edit),label:const Text('Modifier')),
              ]),
            ]else...[
              const Text('Formulaire digital, mention manuscrite et signature directement sur l’écran.',style:TextStyle(fontSize:12,color:Colors.black54)),
              const SizedBox(height:8),
              PremiumFilledButton.icon(onPressed:editEngagementCertificate,icon:const Icon(Icons.draw),label:const Text('Créer le certificat digital')),
            ],
          ]),
        ),

        if(((r!['identification']??'') as String).trim().isNotEmpty||((r!['tattoo']??'') as String).trim().isNotEmpty)...[
          const SizedBox(height:7),
          Container(
            padding:const EdgeInsets.all(10),
            decoration:BoxDecoration(color:Colors.white.withValues(alpha:.65),borderRadius:BorderRadius.circular(14)),
            child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
              const Text('Repères facultatifs',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,color:brown)),
              if(((r!['identification']??'') as String).trim().isNotEmpty)Text('Identification : ${r!['identification']}',style:const TextStyle(fontSize:12)),
              if(((r!['tattoo']??'') as String).trim().isNotEmpty)Text('Tatouage : ${r!['tattoo']}',style:const TextStyle(fontSize:12)),
            ]),
          ),
        ],

        if(((r!['adoptionNotes']??'') as String).trim().isNotEmpty)...[
          const SizedBox(height:7),
          Text(r!['adoptionNotes'],style:const TextStyle(fontSize:12,color:Colors.black54,fontStyle:FontStyle.italic)),
        ],
        const SizedBox(height:7),
        OutlinedButton.icon(onPressed:editAdoption,icon:const Icon(Icons.edit_note),label:const Text('Gérer l’adoption / le départ')),
      ]),
    ));
  }

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
        Text(label,style:TextStyle(fontSize:10.5,fontWeight:FontWeight.w700,color:color)),
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
        _profileBubble('Femelles',female,const Color(0xFF2E7A55)),
        _profileBubble('Équilibre',balance,const Color(0xFF1E6A49)),
        _profileBubble('Mâles',male,const Color(0xFF9A762A)),
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
        const SizedBox(height:7),
        _chartRow(label:'Vivants à la naissance',male:liveMale,female:liveFemale,color:const Color(0xFF2E7A55),maxValue:maxValue),
        _chartRow(label:'Morts à la naissance',male:deadMale,female:deadFemale,color:gold,maxValue:maxValue),
        _chartRow(label:'Vivants au sevrage',male:weanedMale,female:weanedFemale,color:const Color(0xFF1E6A49),maxValue:maxValue),
        _chartRow(label:'Pertes avant sevrage',male:lossMale,female:lossFemale,color:const Color(0xFF8D6E63),maxValue:maxValue),
      ]),
    );
  }

  Widget _rabbitMini(String rabbitId,{double size=46}){
    final match=all.where((x)=>x['id']==rabbitId);
    final rabbit=match.isEmpty ? <String,dynamic>{} : match.first;
    final provider=fileImage(rabbit['photo']);
    return Column(mainAxisSize:MainAxisSize.min,children:[
      Container(
        width:size,height:size,
        decoration:BoxDecoration(
          color:gold.withValues(alpha:.12),
          shape:BoxShape.circle,
          border:Border.all(color:gold.withValues(alpha:.75)),
          image:provider==null ? null : DecorationImage(image:provider,fit:BoxFit.cover),
        ),
        child:provider==null?Icon(Icons.pets,color:lapiGreenDark,size:size*.45):null,
      ),
      const SizedBox(height:4),
      SizedBox(width:92,child:Text(rabbitNameById(rabbitId),maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w800))),
    ]);
  }

  Widget _colorBarsGraph(
    List<Map<String,dynamic>> colors,{
    void Function(int index)? onEdit,
    void Function(int index)? onDelete,
    VoidCallback? onClearAll,
  }){
    if(colors.isEmpty)return const SizedBox.shrink();
    final maxRaw=colors.fold<int>(1,(m,e){
      final a=ReproductionStore.n(e['male']);
      final b=ReproductionStore.n(e['female']);
      final local=a>b?a:b;
      return local>m?local:m;
    });
    final maxValue=maxRaw<=5?5:maxRaw<=10?10:maxRaw<=15?15:((maxRaw+4)~/5)*5;
    const chartHeight=150.0;
    const maleColor=Color(0xFF2F80ED);
    const femaleColor=Color(0xFFE86A9B);
    final totals=ReproductionStore.colorSexTotals(colors);

    Widget bar(int value,Color color){
      final h=value==0 ? 2.0 : (chartHeight-34)*(value/maxValue);
      return Column(mainAxisAlignment:MainAxisAlignment.end,children:[
        Text('$value',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,color:color)),
        const SizedBox(height:3),
        Container(width:22,height:h,decoration:BoxDecoration(color:color,borderRadius:const BorderRadius.vertical(top:Radius.circular(7)))),
      ]);
    }

    return Container(
      padding:const EdgeInsets.fromLTRB(10,10,10,10),
      decoration:BoxDecoration(color:Colors.white.withValues(alpha:.76),borderRadius:BorderRadius.circular(14),border:Border.all(color:gold.withValues(alpha:.42))),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Row(children:[
          const Icon(Icons.bar_chart,color:lapiGreenDark,size:19),
          const SizedBox(width:6),
          const Expanded(child:Text('Répartition des couleurs',style:TextStyle(fontWeight:FontWeight.w900,color:ink))),
          if(onClearAll!=null)IconButton(tooltip:'Tout supprimer',visualDensity:VisualDensity.compact,onPressed:onClearAll,icon:const Icon(Icons.close,color:Colors.red,size:21)),
        ]),
        Wrap(spacing:12,runSpacing:4,children:[
          Text('♂ ${totals['male']} mâle${totals['male']==1 ? '' : 's'}',style:const TextStyle(color:maleColor,fontWeight:FontWeight.w900)),
          Text('♀ ${totals['female']} femelle${totals['female']==1 ? '' : 's'}',style:const TextStyle(color:femaleColor,fontWeight:FontWeight.w900)),
          Text('Total ${totals['total']}',style:const TextStyle(fontWeight:FontWeight.w900,color:brown)),
        ]),
        const SizedBox(height:8),
        Row(crossAxisAlignment:CrossAxisAlignment.end,children:[
          SizedBox(
            width:30,height:chartHeight,
            child:Column(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.end,children:[
              Text('$maxValue',style:const TextStyle(fontSize:9,color:Colors.black54)),
              Text('${(maxValue*.75).round()}',style:const TextStyle(fontSize:9,color:Colors.black54)),
              Text('${(maxValue*.50).round()}',style:const TextStyle(fontSize:9,color:Colors.black54)),
              Text('${(maxValue*.25).round()}',style:const TextStyle(fontSize:9,color:Colors.black54)),
              const Text('0',style:TextStyle(fontSize:9,color:Colors.black54)),
            ]),
          ),
          const SizedBox(width:5),
          Expanded(child:SingleChildScrollView(
            scrollDirection:Axis.horizontal,
            child:Row(crossAxisAlignment:CrossAxisAlignment.end,children:colors.asMap().entries.map((entry){
              final i=entry.key;
              final item=entry.value;
              final label=(item['color']??'').toString();
              final m=ReproductionStore.n(item['male']);
              final f=ReproductionStore.n(item['female']);
              return InkWell(
                onTap:onEdit==null?null:()=>onEdit(i),
                borderRadius:BorderRadius.circular(10),
                child:SizedBox(
                  width:88,
                  child:Column(mainAxisSize:MainAxisSize.min,children:[
                    SizedBox(
                      height:chartHeight,
                      child:Stack(children:[
                        Positioned.fill(child:Row(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[bar(m,maleColor),const SizedBox(width:6),bar(f,femaleColor)])),
                        if(onDelete!=null)Positioned(right:3,top:0,child:InkWell(onTap:()=>onDelete(i),child:const Icon(Icons.close,color:Colors.red,size:18))),
                      ]),
                    ),
                    const SizedBox(height:5),
                    SizedBox(height:32,child:Text(label,maxLines:2,overflow:TextOverflow.ellipsis,textAlign:TextAlign.center,style:const TextStyle(fontSize:10,fontWeight:FontWeight.w800))),
                  ]),
                ),
              );
            }).toList()),
          )),
        ]),
        const SizedBox(height:5),
        const Row(mainAxisAlignment:MainAxisAlignment.end,children:[
          Icon(Icons.swipe_left,size:15,color:Colors.black45),
          SizedBox(width:4),
          Text('Faites défiler horizontalement pour voir toutes les couleurs',style:TextStyle(fontSize:9.5,color:Colors.black45)),
        ]),
      ]),
    );
  }

  Future<void> _editRecordColor(Map<String,dynamic> record,int index)async{
    final colors=ReproductionStore.colorsOf(record);
    if(index<0||index>=colors.length)return;
    final used=colors.asMap().entries.where((e)=>e.key!=index).map((e)=>(e.value['color']??'').toString()).toSet();
    final result=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>ColorCountDialog(initial:colors[index],unavailable:used));
    if(result==null)return;
    colors[index]=result;
    final updated=Map<String,dynamic>.from(record)..['colors']=colors;
    await ReproductionStore.upsert(updated);
    await refreshBreedings();
  }

  Future<void> _deleteRecordColor(Map<String,dynamic> record,int index)async{
    final colors=ReproductionStore.colorsOf(record);
    if(index<0||index>=colors.length)return;
    final label=(colors[index]['color']??'cette couleur').toString();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:Text('Supprimer $label ?'),
      content:const Text('La colonne sera supprimée de cette portée et les statistiques seront recalculées.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    colors.removeAt(index);
    final updated=Map<String,dynamic>.from(record)..['colors']=colors;
    await ReproductionStore.upsert(updated);
    await refreshBreedings();
  }

  Future<void> _clearRecordColors(Map<String,dynamic> record)async{
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer toutes les couleurs ?'),
      content:const Text('Toutes les colonnes de couleurs de cette portée seront supprimées.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Tout supprimer'))],
    ))??false;
    if(!ok)return;
    final updated=Map<String,dynamic>.from(record)..['colors']=<Map<String,dynamic>>[];
    await ReproductionStore.upsert(updated);
    await refreshBreedings();
  }

  Widget _coupleColorSummaries(List<Map<String,dynamic>> records,String currentSex){
    final groups=<String,List<Map<String,dynamic>>>{};
    for(final record in records){
      final partnerId=(record[currentSex=='Mâle'?'femaleId':'maleId']??'').toString();
      if(partnerId.isEmpty)continue;
      groups.putIfAbsent(partnerId,()=>[]).add(record);
    }
    if(groups.isEmpty)return const SizedBox.shrink();
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Text('Croisements & couleurs obtenues',style:TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:ink)),
      const SizedBox(height:4),
      const Text('Les portées d’un même couple sont additionnées automatiquement.',style:TextStyle(fontSize:11,color:Colors.black54)),
      const SizedBox(height:9),
      ...groups.entries.map((entry){
        final partnerId=entry.key;
        final coupleRecords=entry.value;
        final colors=ReproductionStore.aggregateColors(coupleRecords);
        final births=coupleRecords.fold<int>(0,(sum,e)=>sum+ReproductionStore.n(ReproductionStore.totals(e)['born']));
        final maleId=currentSex=='Mâle'?(r!['id']??'').toString():partnerId;
        final femaleId=currentSex=='Femelle'?(r!['id']??'').toString():partnerId;
        return Container(
          margin:const EdgeInsets.only(bottom:12),
          padding:const EdgeInsets.all(10),
          decoration:BoxDecoration(color:gold.withValues(alpha:.065),borderRadius:BorderRadius.circular(16),border:Border.all(color:gold.withValues(alpha:.55))),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
              _rabbitMini(maleId),
              const Padding(padding:EdgeInsets.fromLTRB(8,16,8,0),child:Text('×',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:gold))),
              _rabbitMini(femaleId),
            ]),
            const SizedBox(height:5),
            Text('${coupleRecords.length} ${coupleRecords.length>1 ? 'portées' : 'portée'} • $births lapereau${births>1 ? 'x' : ''}',textAlign:TextAlign.center,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:brown)),
            if(colors.isNotEmpty)...[
              const SizedBox(height:8),
              _colorBarsGraph(colors),
            ]else
              const Padding(padding:EdgeInsets.only(top:8),child:Text('Aucune couleur renseignée pour ce croisement.',textAlign:TextAlign.center,style:TextStyle(fontSize:11,color:Colors.black54))),
          ]),
        );
      }),
    ]);
  }

  Widget reproductionSection(){
    final id=(r!['id']??'') as String;
    final allRecords=breedings.where((b)=>b['maleId']==id||b['femaleId']==id).toList();
    allRecords.sort((a,b){
      final ad=_reproDate(a['matingDate'] as String?)??DateTime(1900);
      final bd=_reproDate(b['matingDate'] as String?)??DateTime(1900);
      return bd.compareTo(ad);
    });
    final sex=(r!['sex']??'') as String;
    final q=reproSearch.trim().toLowerCase();
    final records=allRecords.where((b){
      if(q.isEmpty)return true;
      final partnerId=sex=='Mâle'?(b['femaleId']??'').toString():(b['maleId']??'').toString();
      final partner=rabbitNameById(partnerId).toLowerCase();
      final date=(b['matingDate']??'').toString().toLowerCase();
      final birth=(b['birthDate']??'').toString().toLowerCase();
      return partner.contains(q)||date.contains(q)||birth.contains(q);
    }).toList();
    final cumulative=ReproductionStore.aggregate(allRecords);
    return PremiumCard(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      header(sex=='Mâle'?'Reproduction / Saillies':'Reproduction / Portées',Icons.favorite),
      _reproductionProfile(allRecords),
      if(allRecords.isNotEmpty)...[
        const SizedBox(height:9),
        _breedingChart(cumulative,cumulative:true),
        const SizedBox(height:16),
        _coupleColorSummaries(allRecords,sex),
        const SizedBox(height:8),
        TextField(
          decoration:InputDecoration(
            labelText:'Rechercher une portée / un croisement',
            hintText:'Ex. Perle ou 2026',
            prefixIcon:const Icon(Icons.search),
            suffixIcon:reproSearch.isEmpty?null:IconButton(onPressed:()=>setState(()=>reproSearch=''),icon:const Icon(Icons.close)),
          ),
          onChanged:(v)=>setState(()=>reproSearch=v),
        ),
        const SizedBox(height:12),
      ],
      if(allRecords.isEmpty)Padding(padding:const EdgeInsets.only(top:12,bottom:10),child:Text(sex=='Mâle'?'Aucune saillie enregistrée.':'Aucune portée enregistrée.',style:const TextStyle(color:Colors.black54))),
      if(allRecords.isNotEmpty&&records.isEmpty)const Padding(padding:EdgeInsets.symmetric(vertical:16),child:Text('Aucune portée ne correspond à cette recherche.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54))),
      ...records.map((b){
        final t=ReproductionStore.totals(b);
        final colors=ReproductionStore.colorsOf(b);
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
            if(colors.isNotEmpty)Padding(
              padding:const EdgeInsets.fromLTRB(10,0,10,10),
              child:_colorBarsGraph(
                colors,
                onEdit:(i)=>_editRecordColor(b,i),
                onDelete:(i)=>_deleteRecordColor(b,i),
                onClearAll:()=>_clearRecordColors(b),
              ),
            ),
          ]),
        );
      }),
      OutlinedButton.icon(onPressed:addBreeding,icon:const Icon(Icons.add),label:Text(sex=='Mâle'?'Ajouter une saillie':'Ajouter une portée / saillie')),
    ])));
  }


  List<Map<String,dynamic>> _healthEvents(){
    final events=<Map<String,dynamic>>[];

    for(final key in ['vaccines','dewormings']){
      final list=(r![key] as List?)??[];
      for(var i=0;i<list.length;i++){
        final item=Map<String,dynamic>.from(list[i] as Map);
        final d=Notifications.parseDate(item['date'] as String?);
        if(d==null)continue;
        final product=((item['product']??'') as String).trim();
        events.add({
          'kind':key=='vaccines'?'Vaccin':'Vermifuge',
          'key':key,
          'index':i,
          'item':item,
          'dt':DateTime(d.year,d.month,d.day,12),
          'dateLabel':item['date']??'',
          'title':product.isEmpty?(key=='vaccines'?'Vaccin':'Vermifuge'):product,
          'detail':'',
        });
      }
    }

    for(final raw in ((r!['appointments'] as List?)??[])){
      final item=raw as Map<String,dynamic>;
      final d=appointmentDate(item);
      if(d==null)continue;
      final reason=((item['reason']??'') as String).trim();
      final vet=((item['vet']??'') as String).trim();
      final description=((item['description']??'') as String).trim();
      final details=<String>[
        if(vet.isNotEmpty)vet,
        if(description.isNotEmpty)description,
      ];
      events.add({
        'kind':'Vétérinaire',
        'key':'appointments',
        'index':-1,
        'item':item,
        'dt':d,
        'dateLabel':'${item['date']??''} • ${item['time']??''}',
        'title':reason.isEmpty?'Consultation vétérinaire':reason,
        'detail':details.join(' • '),
      });
    }

    events.sort((a,b)=>(b['dt'] as DateTime).compareTo(a['dt'] as DateTime));
    return events;
  }

  Color _healthColor(String kind){
    if(kind=='Vaccin')return const Color(0xFF2D7654);
    if(kind=='Vermifuge')return const Color(0xFF3C674F);
    return const Color(0xFF1D6044);
  }

  IconData _healthIcon(String kind){
    if(kind=='Vaccin')return Icons.vaccines;
    if(kind=='Vermifuge')return Icons.medication;
    return Icons.local_hospital;
  }

  Widget _healthStat(String label,int value,IconData icon,Color color){
    return Container(
      width:108,
      padding:const EdgeInsets.symmetric(horizontal:8,vertical:8),
      decoration:BoxDecoration(
        color:premiumCard,
        borderRadius:BorderRadius.circular(17),
        border:Border.all(color:softGoldLine,width:.85),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(icon,color:color,size:21),
        const SizedBox(height:7),
        Text('$value',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:color)),
        Text(label,style:const TextStyle(fontSize:10.5,fontWeight:FontWeight.w700,color:ink)),
      ]),
    );
  }

  Widget _healthActivityChart(List<Map<String,dynamic>> past){
    final now=DateTime.now();
    final months=List.generate(6,(i)=>DateTime(now.year,now.month-(5-i),1));
    final counts=months.map((m)=>past.where((e){
      final d=e['dt'] as DateTime;
      return d.year==m.year&&d.month==m.month;
    }).length).toList();
    final maxCount=counts.fold<int>(1,(m,v)=>v>m?v:m);
    const names=['J','F','M','A','M','J','J','A','S','O','N','D'];

    return Container(
      padding:const EdgeInsets.fromLTRB(13,13,13,10),
      decoration:BoxDecoration(
        color:ivory.withValues(alpha:.72),
        borderRadius:BorderRadius.circular(17),
        border:Border.all(color:gold.withValues(alpha:.58)),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Text('Activité santé • 6 derniers mois',style:TextStyle(fontWeight:FontWeight.w800,color:brown)),
        const SizedBox(height:8),
        SizedBox(
          height:92,
          child:Row(
            crossAxisAlignment:CrossAxisAlignment.end,
            children:List.generate(months.length,(i)=>Expanded(
              child:Padding(
                padding:const EdgeInsets.symmetric(horizontal:3),
                child:Column(mainAxisAlignment:MainAxisAlignment.end,children:[
                  Text('${counts[i]}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:brown)),
                  const SizedBox(height:3),
                  Expanded(child:Align(
                    alignment:Alignment.bottomCenter,
                    child:FractionallySizedBox(
                      heightFactor:counts[i] == 0 ? 0.04 : counts[i] / maxCount,
                      widthFactor:.62,
                      child:Container(
                        decoration:BoxDecoration(
                          color:gold,
                          borderRadius:BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height:4),
                  Text(names[months[i].month-1],style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700)),
                ]),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  Future<void> _openHealthEvent(Map<String,dynamic> event)async{
    final kind=event['kind'] as String;
    if(kind=='Vaccin'){
      await editTreatment('vaccines',event['index'] as int,'Vaccin');
    }else if(kind=='Vermifuge'){
      await editTreatment('dewormings',event['index'] as int,'Vermifuge');
    }else{
      await editAppointment(event['item'] as Map<String,dynamic>);
    }
  }

  Widget _healthEventTile(Map<String,dynamic> event,{bool last=false}){
    final kind=event['kind'] as String;
    final color=_healthColor(kind);
    final detail=(event['detail']??'') as String;
    return InkWell(
      borderRadius:BorderRadius.circular(16),
      onTap:()=>_openHealthEvent(event),
      child:Padding(        padding:const EdgeInsets.symmetric(vertical:4),
        child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          SizedBox(
            width:40,
            child:Column(children:[
              Container(
                width:34,height:34,
                decoration:BoxDecoration(
                  color:color.withValues(alpha:.13),
                  shape:BoxShape.circle,
                  border:Border.all(color:color,width:1.6),
                ),
                child:Icon(_healthIcon(kind),size:18,color:color),
              ),
              if(!last)Container(width:2,height:66,color:gold.withValues(alpha:.42)),
            ]),
          ),
          const SizedBox(width:8),
          Expanded(child:Container(
            margin:const EdgeInsets.only(bottom:7),
            padding:const EdgeInsets.fromLTRB(12,10,10,10),
            decoration:BoxDecoration(
              color:premiumCard,
              borderRadius:BorderRadius.circular(15),
              border:Border.all(color:softGoldLine,width:.8),
            ),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Expanded(child:Text(event['dateLabel'] as String,style:TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:color))),
                Container(
                  padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
                  decoration:BoxDecoration(color:color.withValues(alpha:.11),borderRadius:BorderRadius.circular(12)),
                  child:Text(kind,style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:color)),
                ),
              ]),
              const SizedBox(height:5),
              Text(event['title'] as String,style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800,color:ink)),
              if(detail.isNotEmpty)...[
                const SizedBox(height:3),
                Text(detail,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,color:Colors.black54)),
              ],
              const SizedBox(height:4),
              const Text('Appuyer pour ouvrir ou modifier',style:TextStyle(fontSize:10,color:Colors.black45)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget healthJourneySection(){
    final allEvents=_healthEvents();
    final now=DateTime.now();
    final past=allEvents.where((e)=>!(e['dt'] as DateTime).isAfter(now)).toList();
    final future=allEvents.where((e)=>(e['dt'] as DateTime).isAfter(now)&&e['kind']=='Vétérinaire').toList()
      ..sort((a,b)=>(a['dt'] as DateTime).compareTo(b['dt'] as DateTime));

    final vaccines=past.where((e)=>e['kind']=='Vaccin').length;
    final dewormings=past.where((e)=>e['kind']=='Vermifuge').length;
    final vetVisits=past.where((e)=>e['kind']=='Vétérinaire').length;
    final yearAgo=now.subtract(const Duration(days:365));
    final recent=past.where((e)=>(e['dt'] as DateTime).isAfter(yearAgo)).length;

    bool keep(Map<String,dynamic> e){
      if(healthFilter=='Vaccins')return e['kind']=='Vaccin';
      if(healthFilter=='Vermifuges')return e['kind']=='Vermifuge';
      if(healthFilter=='Véto')return e['kind']=='Vétérinaire';
      return true;
    }

    final filtered=past.where(keep).toList();
    final shown=healthExpanded?filtered:filtered.take(6).toList();

    return PremiumCard(child:Padding(
      padding:const EdgeInsets.all(10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        header('Parcours santé',Icons.timeline),
        const Text(
          'Toute l’histoire médicale réunie au même endroit.',
          style:TextStyle(color:Colors.black54),
        ),
        const SizedBox(height:9),

        Wrap(spacing:8,runSpacing:8,children:[
          _healthStat('Événements',past.length,Icons.monitor_heart,const Color(0xFF315B49)),
          _healthStat('Vaccins',vaccines,Icons.vaccines,const Color(0xFF2D7654)),
          _healthStat('Vermifuges',dewormings,Icons.medication,const Color(0xFF3C674F)),
          _healthStat('Visites véto',vetVisits,Icons.local_hospital,const Color(0xFF1D6044)),
        ]),

        const SizedBox(height:11),
        Container(
          padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),
          decoration:BoxDecoration(
            gradient:const LinearGradient(colors:[heroGreen,heroGreen2]),
            borderRadius:BorderRadius.circular(15),
          ),
          child:Row(children:[
            const Icon(Icons.insights,color:gold,size:20),
            const SizedBox(width:8),
            Expanded(child:Text(
              '$recent événement${recent>1?'s':''} enregistré${recent>1?'s':''} sur les 12 derniers mois',
              style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700),
            )),
          ]),
        ),

        if(future.isNotEmpty)...[
          const SizedBox(height:9),
          InkWell(
            borderRadius:BorderRadius.circular(16),
            onTap:()=>_openHealthEvent(future.first),
            child:Container(
              padding:const EdgeInsets.all(13),
              decoration:BoxDecoration(
                gradient:LinearGradient(colors:[gold.withValues(alpha:.24),Colors.white.withValues(alpha:.78)]),
                borderRadius:BorderRadius.circular(16),
                border:Border.all(color:gold,width:1.3),
              ),
              child:Row(children:[
                Container(
                  width:42,height:42,
                  decoration:BoxDecoration(color:ink,shape:BoxShape.circle,border:Border.all(color:gold)),
                  child:const Icon(Icons.event_available,color:gold),
                ),
                const SizedBox(width:11),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  const Text('PROCHAIN RENDEZ-VOUS',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,color:brown,letterSpacing:.7)),
                  const SizedBox(height:2),
                  Text(future.first['dateLabel'] as String,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900,color:ink)),
                  Text(future.first['title'] as String,style:const TextStyle(color:brown,fontWeight:FontWeight.w600)),
                ])),
                const Icon(Icons.chevron_right,color:brown),
              ]),
            ),
          ),
        ],

        if(past.isNotEmpty)...[
          const SizedBox(height:9),
          _healthActivityChart(past),
          const SizedBox(height:15),
          const Text('Chronologie médicale',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:ink)),
          const SizedBox(height:3),
          const Text('Du plus récent au plus ancien',style:TextStyle(fontSize:12,color:Colors.black54)),
          const SizedBox(height:7),
          Wrap(spacing:7,runSpacing:7,children:[
            for(final f in ['Tout','Vaccins','Vermifuges','Véto'])
              ChoiceChip(
                label:Text(
                  f,
                  style:TextStyle(
                    color:healthFilter==f?warmGoldText:Colors.white,
                    fontWeight:FontWeight.w800,
                  ),
                ),
                selected:healthFilter==f,
                backgroundColor:heroGreen2,
                selectedColor:heroGreen,
                checkmarkColor:warmGoldText,
                side:BorderSide(color:healthFilter==f?gold:Colors.white24,width:healthFilter==f?1.15:.7),
                onSelected:(_)=>setState((){healthFilter=f;healthExpanded=false;}),
              ),
          ]),
          const SizedBox(height:8),
        ],

        if(past.isEmpty&&future.isEmpty)
          Container(
            padding:const EdgeInsets.all(10),
            decoration:BoxDecoration(color:gold.withValues(alpha:.08),borderRadius:BorderRadius.circular(16)),
            child:const Column(children:[
              Icon(Icons.favorite_border,color:brown,size:34),
              SizedBox(height:8),
              Text('Le parcours santé commencera dès le premier soin ou rendez-vous.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54)),
            ]),
          ),

        if(past.isNotEmpty&&filtered.isEmpty)
          const Padding(
            padding:EdgeInsets.symmetric(vertical:12),
            child:Text('Aucun événement dans cette catégorie.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54)),
          ),

        ...shown.asMap().entries.map((e)=>_healthEventTile(e.value,last:e.key==shown.length-1)),

        if(filtered.length>6)
          TextButton.icon(
            onPressed:()=>setState(()=>healthExpanded=!healthExpanded),
            icon:Icon(healthExpanded?Icons.expand_less:Icons.expand_more),
            label:Text(healthExpanded?'Réduire la chronologie':'Voir toute la chronologie (${filtered.length})'),
          ),

        if(past.isNotEmpty)...[
          const Divider(height:24),
          Builder(builder:(_){
            final first=past.last['dateLabel'] as String;
            final last=past.first['dateLabel'] as String;
            return Row(children:[
              const Icon(Icons.history,color:brown,size:19),
              const SizedBox(width:7),
              Expanded(child:Text(
                first==last?'Suivi enregistré le $last':'Suivi enregistré de $first à $last',
                style:const TextStyle(fontSize:12,color:Colors.black54,fontWeight:FontWeight.w600),
              )),
            ]);
          }),
        ],
      ]),
    ));
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
    return PremiumCard(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
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

    return PremiumCard(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
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



class CompetitionDialog extends StatefulWidget{
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const CompetitionDialog({super.key,required this.item,required this.onSave});
  @override State<CompetitionDialog> createState()=>_CompetitionDialogState();
}

class _CompetitionDialogState extends State<CompetitionDialog>{
  late Map<String,dynamic>d;
  final picker=ImagePicker();
  String? newPhotoSource;
  String? newSheetSource;
  bool removePhoto=false;
  bool removeSheet=false;

  static const awards=[
    'Aucune','GPE – Grand Prix d’Exposition','GPH – Grand Prix d’Honneur',
    'PH – Prix d’Honneur','PS – Prix Spécial','Meilleur de Race',
    'Meilleur Mâle','Meilleure Femelle','Champion de France','Champion Régional',
    'Champion Interrégional','Coupe de France','Grand Prix d’Élevage',
    'Prix d’Élevage','Challenge','Trophée','Super GPE','Autre récompense',
  ];
  static const qualifications=['Non renseigné','Excellent','Très bon','Bon','Passable','Disqualifié'];

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.item);
    d['id']??='c_${DateTime.now().microsecondsSinceEpoch}';
    for(final key in ['date','name','location','category','cageNumber','judge','tattoo','score','ranking','customAward','comments','photo','judgingSheet']){d[key]??='';}
    d['weightGrams']??=0;
    d['qualification']??='Non renseigné';
    d['award']??='Aucune';
  }

  Future<void> pickDate()async{
    final current=Notifications.parseDate(d['date'] as String?)??DateTime.now();
    final x=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime.now().add(const Duration(days:3650)),initialDate:current);
    if(x!=null)setState(()=>d['date']=Notifications.formatDate(x));
  }

  Future<void> choosePhoto()async{
    final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:95);
    if(x!=null)setState((){newPhotoSource=x.path;removePhoto=false;});
  }

  Future<void> chooseSheet()async{
    final x=await FilePicker.platform.pickFiles(type:FileType.any);
    final path=x?.files.single.path;
    if(path!=null)setState((){newSheetSource=path;removeSheet=false;});
  }

  Future<void> save()async{
    if(((d['date']??'') as String).trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez la date du concours.')));
      return;
    }
    final oldPhoto=((widget.item['photo']??'') as String);
    final oldSheet=((widget.item['judgingSheet']??'') as String);

    if(removePhoto){d['photo']='';}
    if(removeSheet){d['judgingSheet']='';}
    if(newPhotoSource!=null){
      final saved=await PrivateFiles.importFile(newPhotoSource!,'competitions');
      if(saved.isNotEmpty)d['photo']=saved;
    }
    if(newSheetSource!=null){
      final saved=await PrivateFiles.importFile(newSheetSource!,'competitions');
      if(saved.isNotEmpty)d['judgingSheet']=saved;
    }

    await widget.onSave(d);
    if((removePhoto||newPhotoSource!=null)&&oldPhoto.isNotEmpty&&oldPhoto!=d['photo'])await PrivateFiles.deleteFile(oldPhoto);
    if((removeSheet||newSheetSource!=null)&&oldSheet.isNotEmpty&&oldSheet!=d['judgingSheet'])await PrivateFiles.deleteFile(oldSheet);
  }

  Widget field(String label,String key,{TextInputType? keyboardType,int maxLines=1,String? hint})=>Padding(
    padding:const EdgeInsets.only(top:10),
    child:TextFormField(
      initialValue:(d[key]??'').toString(),
      keyboardType:keyboardType,
      maxLines:maxLines,
      decoration:InputDecoration(labelText:label,hintText:hint),
      onChanged:(v)=>d[key]=v,
    ),
  );

  @override Widget build(BuildContext context){
    final grams=d['weightGrams'] is int?d['weightGrams'] as int:int.tryParse('${d['weightGrams']}')??0;
    final hasPhoto=newPhotoSource!=null||(!removePhoto&&((d['photo']??'') as String).isNotEmpty);
    final hasSheet=newSheetSource!=null||(!removeSheet&&((d['judgingSheet']??'') as String).isNotEmpty);
    return Dialog.fullscreen(child:Scaffold(
      appBar:AppBar(title:const Text('Concours & Exposition'),actions:[TextButton(onPressed:save,child:const Text('ENREGISTRER'))]),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(
          padding:const EdgeInsets.all(14),
          decoration:BoxDecoration(color:ink,borderRadius:BorderRadius.circular(18),border:Border.all(color:gold)),
          child:const Row(children:[
            Icon(Icons.emoji_events,color:gold,size:30),SizedBox(width:10),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('CARNET DE CONCOURS',style:TextStyle(color:gold,fontWeight:FontWeight.w900,fontSize:12,letterSpacing:.8)),
              Text('Jugement, classement et palmarès',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:18)),
            ])),
          ]),
        ),
        const SizedBox(height:16),
        const Text('Événement',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:8),
        TextFormField(readOnly:true,controller:TextEditingController(text:d['date']??''),decoration:const InputDecoration(labelText:'Date',suffixIcon:Icon(Icons.calendar_month)),onTap:pickDate),
        field('Nom du concours / exposition','name',hint:'Ex. Exposition nationale de…'),
        field('Lieu','location'),
        field('Classe / catégorie','category',hint:'Ex. Géant Papillon Français'),
        field('N° de cage / passage','cageNumber'),
        field('Juge','judge'),
        const SizedBox(height:18),
        const Text('Lapin présenté',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
        field('Tatouage au concours','tattoo',hint:'Facultatif'),
        Padding(
          padding:const EdgeInsets.only(top:10),
          child:TextFormField(
            initialValue:grams>0?'$grams':'',
            keyboardType:TextInputType.number,
            decoration:const InputDecoration(labelText:'Poids le jour du concours',suffixText:'g'),
            onChanged:(v)=>d['weightGrams']=int.tryParse(v.trim())??0,
          ),
        ),
        const SizedBox(height:18),
        const Text('Jugement',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
        field('Note / points','score',keyboardType:const TextInputType.numberWithOptions(decimal:true),hint:'Ex. 95,5'),
        Padding(
          padding:const EdgeInsets.only(top:10),
          child:DropdownButtonFormField<String>(
            value:qualifications.contains(d['qualification'])?d['qualification']:'Non renseigné',
            decoration:const InputDecoration(labelText:'Qualificatif'),
            items:qualifications.map((q)=>DropdownMenuItem(value:q,child:Text(q))).toList(),
            onChanged:(v)=>setState(()=>d['qualification']=v??'Non renseigné'),
          ),
        ),
        field('Classement','ranking',hint:'Ex. 1er / 12'),
        Padding(
          padding:const EdgeInsets.only(top:10),
          child:DropdownButtonFormField<String>(
            value:awards.contains(d['award'])?d['award']:'Autre récompense',
            isExpanded:true,
            decoration:const InputDecoration(labelText:'Récompense obtenue'),
            items:awards.map((a)=>DropdownMenuItem(value:a,child:Text(a,overflow:TextOverflow.ellipsis))).toList(),
            onChanged:(v)=>setState(()=>d['award']=v??'Aucune'),
          ),
        ),
        if(d['award']=='Autre récompense')field('Nom de la récompense','customAward'),
        field('Appréciations / remarques du juge','comments',maxLines:4),
        const SizedBox(height:18),
        const Text('Pièces du concours',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:8),
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(color:gold.withValues(alpha:.07),borderRadius:BorderRadius.circular(16)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(children:[
              Icon(hasPhoto?Icons.check_circle:Icons.photo_outlined,color:hasPhoto?const Color(0xFF2E7A55):brown),
              const SizedBox(width:8),
              const Expanded(child:Text('Photo du concours',style:TextStyle(fontWeight:FontWeight.w800))),
              TextButton(onPressed:choosePhoto,child:Text(hasPhoto?'Remplacer':'Choisir')),
              if(hasPhoto)IconButton(tooltip:'Retirer',onPressed:()=>setState((){newPhotoSource=null;removePhoto=true;}),icon:const Icon(Icons.close)),
            ]),
            const Divider(),
            Row(children:[
              Icon(hasSheet?Icons.check_circle:Icons.description_outlined,color:hasSheet?const Color(0xFF2E7A55):brown),
              const SizedBox(width:8),
              const Expanded(child:Text('Carte / fiche de jugement',style:TextStyle(fontWeight:FontWeight.w800))),              TextButton(onPressed:chooseSheet,child:Text(hasSheet?'Remplacer':'Joindre')),
              if(hasSheet)IconButton(tooltip:'Retirer',onPressed:()=>setState((){newSheetSource=null;removeSheet=true;}),icon:const Icon(Icons.close)),
            ]),
          ]),
        ),
        const SizedBox(height:18),
        PremiumFilledButton.icon(onPressed:save,icon:const Icon(Icons.save),label:const Text('Enregistrer le concours')),
        const SizedBox(height:24),
      ]),
    ));
  }
}

class WeightDialog extends StatefulWidget{
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const WeightDialog({super.key,required this.item,required this.onSave});
  @override State<WeightDialog> createState()=>_WeightDialogState();
}

class _WeightDialogState extends State<WeightDialog>{
  late Map<String,dynamic>d;
  late TextEditingController gramsController;

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.item);
    d['id']??='w_${DateTime.now().microsecondsSinceEpoch}';
    d['date']??=Notifications.formatDate(DateTime.now());
    d['grams']??=0;
    d['note']??='';
    final grams=d['grams'] is int?d['grams'] as int:int.tryParse('${d['grams']}')??0;
    gramsController=TextEditingController(text:grams>0?'$grams':'');
  }

  @override void dispose(){
    gramsController.dispose();
    super.dispose();
  }

  Future<void> pickDate()async{
    final current=Notifications.parseDate(d['date'] as String?)??DateTime.now();
    final x=await showDatePicker(
      context:context,
      firstDate:DateTime(1990),
      lastDate:DateTime.now().add(const Duration(days:365)),
      initialDate:current.isAfter(DateTime.now().add(const Duration(days:365)))?DateTime.now():current,
    );
    if(x!=null)setState(()=>d['date']=Notifications.formatDate(x));
  }

  @override Widget build(BuildContext context)=>AlertDialog(
    title:Text(widget.item['grams']!=null&&ReproductionStore.n(widget.item['grams'])>0?'Modifier la pesée':'Nouvelle pesée'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['date']??''),
        decoration:const InputDecoration(labelText:'Date de la pesée',suffixIcon:Icon(Icons.calendar_month)),
        onTap:pickDate,
      ),
      const SizedBox(height:12),
      TextField(
        controller:gramsController,
        keyboardType:TextInputType.number,
        decoration:const InputDecoration(
          labelText:'Poids en grammes',
          hintText:'Ex. 5420',
          suffixText:'g',
        ),
      ),
      const SizedBox(height:12),
      TextFormField(
        initialValue:d['note']??'',
        minLines:2,
        maxLines:4,
        decoration:const InputDecoration(
          labelText:'Note facultative',
          hintText:'Ex. contrôle mensuel, après maladie…',
        ),
        onChanged:(v)=>d['note']=v,
      ),
    ])),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Annuler')),
      PremiumFilledButton(
        onPressed:(){
          final grams=int.tryParse(gramsController.text.trim());
          if(((d['date']??'') as String).isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez la date de la pesée.')));
            return;
          }
          if(grams==null||grams<=0||grams>30000){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Indiquez un poids valide en grammes.')));
            return;
          }
          d['grams']=grams;
          widget.onSave(d);
        },
        child:const Text('Enregistrer'),
      ),
    ],
  );
}

class WeightPoint{
  final DateTime date;
  final int grams;
  const WeightPoint({required this.date,required this.grams});
}

class WeightChartPainter extends CustomPainter{
  final List<WeightPoint> points;
  const WeightChartPainter({required this.points});

  @override void paint(Canvas canvas,Size size){
    if(points.isEmpty)return;

    const left=48.0;
    const right=12.0;
    const top=14.0;
    const bottom=34.0;
    final chart=Rect.fromLTRB(left,top,size.width-right,size.height-bottom);
    if(chart.width<=0||chart.height<=0)return;

    final minWeight=points.map((e)=>e.grams).reduce((a,b)=>a<b?a:b);
    final maxWeight=points.map((e)=>e.grams).reduce((a,b)=>a>b?a:b);
    final padding=((maxWeight-minWeight)*0.15).round().clamp(100,1000);
    final yMin=(minWeight-padding).clamp(0,30000);
    final yMax=(maxWeight+padding).clamp(yMin+100,30000);
    final firstDate=points.first.date;
    final lastDate=points.last.date;
    final totalDays=(lastDate.difference(firstDate).inDays).abs();

    final grid=Paint()..color=const Color(0x22000000)..strokeWidth=1;
    final axis=Paint()..color=const Color(0x66506057)..strokeWidth=1.2;
    final line=Paint()
      ..color=lapiGreen
      ..strokeWidth=3
      ..style=PaintingStyle.stroke
      ..strokeCap=StrokeCap.round
      ..strokeJoin=StrokeJoin.round;
    final dot=Paint()..color=lapiGreenDark;

    canvas.drawLine(Offset(chart.left,chart.top),Offset(chart.left,chart.bottom),axis);
    canvas.drawLine(Offset(chart.left,chart.bottom),Offset(chart.right,chart.bottom),axis);

    final textStyle=const TextStyle(color:Color(0xFF6B6258),fontSize:9,fontWeight:FontWeight.w600);
    void drawText(String value,Offset offset,{TextAlign align=TextAlign.left,double? maxWidth}){
      final painter=TextPainter(
        text:TextSpan(text:value,style:textStyle),
        textDirection:TextDirection.ltr,
        textAlign:align,
      )..layout(maxWidth:maxWidth??80);
      painter.paint(canvas,offset);
    }

    for(var i=0;i<=4;i++){
      final y=chart.top+chart.height*i/4;
      canvas.drawLine(Offset(chart.left,y),Offset(chart.right,y),grid);
      final weight=(yMax-(yMax-yMin)*i/4).round();
      drawText('${weight} g',Offset(0,y-6),maxWidth:left-5);
    }

    Offset pointOffset(WeightPoint p){
      final days=totalDays==0?0:p.date.difference(firstDate).inDays;
      final x=totalDays==0
          ? chart.left+chart.width/2
          : chart.left+chart.width*(days/totalDays);
      final ratio=(p.grams-yMin)/(yMax-yMin);
      final y=chart.bottom-chart.height*ratio;
      return Offset(x,y);
    }

    if(points.length>1){
      final path=Path();
      for(var i=0;i<points.length;i++){
        final o=pointOffset(points[i]);
        if(i==0)path.moveTo(o.dx,o.dy);else path.lineTo(o.dx,o.dy);
      }
      canvas.drawPath(path,line);
    }

    for(final p in points){
      final o=pointOffset(p);
      canvas.drawCircle(o,5,dot);
      canvas.drawCircle(o,2.4,Paint()..color=Colors.white);
    }

    String shortDate(DateTime d)=>'${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}';
    if(points.length==1){
      final label=shortDate(points.first.date);
      drawText(label,Offset(chart.left+chart.width/2-20,chart.bottom+8),maxWidth:50);
    }else{
      drawText(shortDate(firstDate),Offset(chart.left,chart.bottom+8),maxWidth:55);
      final last=shortDate(lastDate);
      final tp=TextPainter(text:TextSpan(text:last,style:textStyle),textDirection:TextDirection.ltr)..layout();
      tp.paint(canvas,Offset(chart.right-tp.width,chart.bottom+8));
    }
  }

  @override bool shouldRepaint(covariant WeightChartPainter oldDelegate){
    if(oldDelegate.points.length!=points.length)return true;
    for(var i=0;i<points.length;i++){
      if(oldDelegate.points[i].grams!=points[i].grams||oldDelegate.points[i].date!=points[i].date)return true;
    }
    return false;
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
  @override void initState(){super.initState();d=Map<String,dynamic>.from(widget.data);d['sterilized']??='';d['color']??='';d['fatherColor']??='';d['motherColor']??='';}

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
      raceColorFields('breed','color'),
      field('Numéro d’identification (facultatif)','identification'),
      field('Numéro de tatouage (facultatif)','tattoo'),
      dateField('Date de naissance','birth'),
      dateField('Date de sevrage','weaning'),
      const SizedBox(height:20),
      const Text('Père',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      field('Nom du père','fatherName'),raceColorFields('fatherBreed','fatherColor',raceLabel:'Race du père',colorLabel:'Couleur / variété du père'),dateField('Date de naissance du père','fatherBirth'),
      const SizedBox(height:20),
      const Text('Mère',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      field('Nom de la mère','motherName'),raceColorFields('motherBreed','motherColor',raceLabel:'Race de la mère',colorLabel:'Couleur / variété de la mère'),dateField('Date de naissance de la mère','motherBirth'),
    ]),
  ));

  Widget choiceTitle(String label)=>Padding(padding:const EdgeInsets.only(bottom:7),child:Text(label,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:brown)));

  Future<void> chooseRace(String raceKey,String colorKey,String title)async{
    final selected=await showDialog<String>(context:context,builder:(_)=>RacePickerDialog(initial:(d[raceKey]??'').toString(),title:title));
    if(selected==null)return;
    setState((){
      final changed=(d[raceKey]??'').toString()!=selected;
      d[raceKey]=selected;
      if(changed)d[colorKey]='';
    });
  }

  Future<void> chooseColor(String raceKey,String colorKey)async{
    final breed=(d[raceKey]??'').toString();
    if(breed.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez d’abord la race.')));
      return;
    }
    final selected=await showDialog<String>(context:context,builder:(_)=>BreedColorPickerDialog(breed:breed,initial:(d[colorKey]??'').toString()));
    if(selected!=null)setState(()=>d[colorKey]=selected);
  }

  Widget raceColorFields(String raceKey,String colorKey,{String raceLabel='Race',String colorLabel='Couleur / variété'}){
    final race=(d[raceKey]??'').toString();
    final color=(d[colorKey]??'').toString();
    final standard=RabbitBreedCatalog.isStandard(race,color);
    return Padding(
      padding:const EdgeInsets.only(top:10),
      child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        InkWell(
          borderRadius:BorderRadius.circular(12),
          onTap:()=>chooseRace(raceKey,colorKey,raceLabel),
          child:InputDecorator(
            decoration:InputDecoration(labelText:raceLabel,suffixIcon:const Icon(Icons.arrow_drop_down)),
            child:Text(race.isEmpty?'Sélectionner une race':race,style:TextStyle(color:race.isEmpty?Colors.black54:ink,fontWeight:FontWeight.w700)),
          ),
        ),
        const SizedBox(height:10),
        InkWell(
          borderRadius:BorderRadius.circular(12),
          onTap:()=>chooseColor(raceKey,colorKey),
          child:InputDecorator(
            decoration:InputDecoration(labelText:colorLabel,suffixIcon:const Icon(Icons.arrow_drop_down)),
            child:Row(children:[
              if(standard)...[const Text('🏅'),const SizedBox(width:6)],
              Expanded(child:Text(color.isEmpty?'Sélectionner une couleur / variété':color,style:TextStyle(color:color.isEmpty?Colors.black54:ink,fontWeight:FontWeight.w700))),
            ]),
          ),
        ),
        if(color.isNotEmpty)Padding(
          padding:const EdgeInsets.only(top:4,left:4),
          child:Text(standard?'🏅 Variété reconnue au standard de la race':'Variété / type enregistré hors repère standard',style:const TextStyle(fontSize:10,color:Colors.black54)),
        ),
      ]),
    );
  }

  Widget field(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(initialValue:d[key]??'',decoration:InputDecoration(labelText:label),onChanged:(v)=>d[key]=v));
  Widget dateField(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(
    readOnly:true,controller:TextEditingController(text:d[key]??''),decoration:InputDecoration(labelText:label,suffixIcon:const Icon(Icons.calendar_month)),
    onTap:()async{final x=await showDatePicker(context:context,firstDate:DateTime(1990),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:Notifications.parseDate(d[key])??DateTime.now());if(x!=null)setState(()=>d[key]=Notifications.formatDate(x));},
  ));
}


class EngagementCertificateDialog extends StatefulWidget{
  final Map<String,dynamic> data;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const EngagementCertificateDialog({super.key,required this.data,required this.onSave});
  @override State<EngagementCertificateDialog> createState()=>_EngagementCertificateDialogState();
}

class _EngagementCertificateDialogState extends State<EngagementCertificateDialog>{
  late Map<String,dynamic>d;
  final mentionKey=GlobalKey<HandwritingPadState>();
  final signatureKey=GlobalKey<HandwritingPadState>();

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.data);
    d['engagementRecipientName']??=d['adopterName']??'';
    d['engagementRecipientAddress']??='';
    d['engagementRecipientEmail']??=d['adopterContact']??'';
    d['engagementDeliveryDate']??='';
    d['engagementSignedDate']??='';
    d['engagementPlace']??='';
    d['engagementIssuerName']??='';
    d['engagementIssuerQualification']??='';
    d['engagementIssuerReference']??='';
    d['engagementMentionImage']??='';
    d['engagementSignatureImage']??='';
    d['engagementAccepted']??=false;
  }

  Future<void> pickDelivery()async{
    final current=Notifications.parseDate(d['engagementDeliveryDate'] as String?)??DateTime.now();
    final x=await showDatePicker(
      context:context,
      firstDate:DateTime(2022,10,1),
      lastDate:DateTime.now(),
      initialDate:current.isAfter(DateTime.now())?DateTime.now():current,
    );
    if(x!=null)setState(()=>d['engagementDeliveryDate']=Notifications.formatDate(x));
  }

  Future<void> save()async{
    final required=[
      d['engagementRecipientName'],
      d['engagementDeliveryDate'],
      d['engagementPlace'],
      d['engagementIssuerName'],
      d['engagementIssuerQualification'],
    ].map((e)=>(e??'').toString().trim()).toList();
    if(required.any((e)=>e.isEmpty)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Complétez l’identité, la délivrance, le lieu et les informations du délivreur.')));
      return;
    }

    final mentionState=mentionKey.currentState;
    final signatureState=signatureKey.currentState;
    final existingMention=((d['engagementMentionImage']??'') as String);
    final existingSignature=((d['engagementSignatureImage']??'') as String);

    if((mentionState==null||!mentionState.hasInk)&&existingMention.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('La mention d’engagement doit être recopiée à la main.')));
      return;
    }
    if((signatureState==null||!signatureState.hasInk)&&existingSignature.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('La signature doit être apposée sur l’écran.')));
      return;
    }

    var mentionPath=existingMention;
    var signaturePath=existingSignature;

    if(mentionState!=null&&mentionState.hasInk){
      final bytes=await mentionState.exportPng();
      if(bytes!=null)mentionPath=await PrivateFiles.saveBytes(bytes,'documents',extension:'.png');
    }
    if(signatureState!=null&&signatureState.hasInk){
      final bytes=await signatureState.exportPng();
      if(bytes!=null)signaturePath=await PrivateFiles.saveBytes(bytes,'documents',extension:'.png');
    }

    d['engagementMentionImage']=mentionPath;
    d['engagementSignatureImage']=signaturePath;
    d['engagementSignedDate']=Notifications.formatDate(DateTime.now());
    d['engagementAccepted']=true;
    await widget.onSave(d);
  }

  Widget section(String title,String body,IconData icon)=>Container(
    margin:const EdgeInsets.only(bottom:10),
    padding:const EdgeInsets.all(12),
    decoration:BoxDecoration(color:Colors.white.withValues(alpha:.76),borderRadius:BorderRadius.circular(16),border:Border.all(color:gold.withValues(alpha:.45))),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Icon(icon,color:brown,size:20),const SizedBox(width:7),Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w900,color:ink)))]),
      const SizedBox(height:5),
      Text(body,style:const TextStyle(fontSize:12,height:1.35,color:Colors.black87)),
    ]),
  );

  @override Widget build(BuildContext context){
    final delivery=Notifications.parseDate(d['engagementDeliveryDate'] as String?);
    final earliest=delivery?.add(const Duration(days:7));
    final existingMention=((d['engagementMentionImage']??'') as String);
    final existingSignature=((d['engagementSignatureImage']??'') as String);

    return Dialog.fullscreen(child:Scaffold(
      appBar:AppBar(
        title:const Text('Certificat d’engagement'),
        actions:[TextButton(onPressed:save,child:const Text('ENREGISTRER'))],
      ),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Container(
          padding:const EdgeInsets.all(14),
          decoration:BoxDecoration(color:ink,borderRadius:BorderRadius.circular(18),border:Border.all(color:gold)),
          child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('CERTIFICAT DIGITAL',style:TextStyle(color:gold,fontWeight:FontWeight.w900,fontSize:12,letterSpacing:.8)),
            SizedBox(height:4),
            Text('Engagement et connaissance des besoins du lapin',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:19)),
            SizedBox(height:5),
            Text('Le délai de réflexion est calculé à partir de la date de délivrance.',style:TextStyle(color:Colors.white70,fontSize:11)),
          ]),
        ),
        const SizedBox(height:16),

        const Text('Futur acquéreur',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:8),
        TextFormField(initialValue:d['engagementRecipientName']??'',decoration:const InputDecoration(labelText:'Nom et prénom'),onChanged:(v)=>d['engagementRecipientName']=v),
        const SizedBox(height:10),
        TextFormField(initialValue:d['engagementRecipientAddress']??'',minLines:2,maxLines:3,decoration:const InputDecoration(labelText:'Adresse'),onChanged:(v)=>d['engagementRecipientAddress']=v),
        const SizedBox(height:10),
        TextFormField(initialValue:d['engagementRecipientEmail']??'',decoration:const InputDecoration(labelText:'Téléphone / e-mail'),onChanged:(v)=>d['engagementRecipientEmail']=v),

        const SizedBox(height:18),
        const Text('Personne qui délivre le certificat',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:8),
        TextFormField(initialValue:d['engagementIssuerName']??'',decoration:const InputDecoration(labelText:'Nom et prénom du délivreur'),onChanged:(v)=>d['engagementIssuerName']=v),
        const SizedBox(height:10),
        TextFormField(initialValue:d['engagementIssuerQualification']??'',decoration:const InputDecoration(labelText:'Qualité / habilitation (ACACED, vétérinaire, équivalence…)'),onChanged:(v)=>d['engagementIssuerQualification']=v),
        const SizedBox(height:10),
        TextFormField(initialValue:d['engagementIssuerReference']??'',decoration:const InputDecoration(labelText:'Référence / numéro (facultatif)'),onChanged:(v)=>d['engagementIssuerReference']=v),
        const SizedBox(height:10),
        TextFormField(
          readOnly:true,
          controller:TextEditingController(text:d['engagementDeliveryDate']??''),
          decoration:const InputDecoration(labelText:'Date de délivrance',suffixIcon:Icon(Icons.calendar_month)),
          onTap:pickDelivery,
        ),
        if(earliest!=null)
          Padding(
            padding:const EdgeInsets.only(top:8),
            child:Container(
              padding:const EdgeInsets.all(10),
              decoration:BoxDecoration(color:gold.withValues(alpha:.10),borderRadius:BorderRadius.circular(14)),
              child:Text('Cession possible à partir du ${Notifications.formatDate(earliest)}.',style:const TextStyle(fontWeight:FontWeight.w900,color:brown)),
            ),
          ),

        const SizedBox(height:18),
        const Text('Informations essentielles',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:8),
        section('Besoins physiologiques','Foin de qualité et eau propre à volonté, alimentation adaptée, espace suffisant, exercice quotidien, zones de repos, hygiène et température appropriées.',Icons.grass),
        section('Besoins comportementaux','Le lapin doit pouvoir explorer, se cacher, ronger, creuser, se déplacer, bénéficier d’enrichissements et d’interactions sociales adaptées.',Icons.psychology_alt_outlined),
        section('Besoins médicaux','Suivi vétérinaire adapté au lapin, vaccinations selon les recommandations, surveillance de l’appétit, du transit, des dents, du poids et de l’état général.',Icons.health_and_safety_outlined),
        section('Identification','Le futur détenteur doit connaître les règles d’identification applicables à sa situation et l’intérêt de pouvoir relier l’animal à son détenteur.',Icons.badge_outlined),
        section('Implications financières et logistiques','Alimentation, habitat, enrichissement, soins vétérinaires, urgences, garde pendant les absences et transport représentent un engagement durable.',Icons.account_balance_wallet_outlined),

        const SizedBox(height:8),
        const Text('Mention manuscrite obligatoire',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:6),
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(color:gold.withValues(alpha:.10),borderRadius:BorderRadius.circular(14),border:Border.all(color:gold)),
          child:const Text(
            'À recopier à la main : « Je m’engage expressément à respecter, durant toute sa vie, les besoins physiologiques, comportementaux et médicaux de mon lapin. »',
            style:TextStyle(fontWeight:FontWeight.w700,color:brown,height:1.35),
          ),
        ),
        const SizedBox(height:8),
        if(existingMention.isNotEmpty)
          Padding(
            padding:const EdgeInsets.only(bottom:8),
            child:Row(children:[
              const Icon(Icons.check_circle,color:Color(0xFF2E7D32)),
              const SizedBox(width:7),
              const Expanded(child:Text('Une mention manuscrite est déjà enregistrée. Dessinez ci-dessous uniquement pour la remplacer.',style:TextStyle(fontSize:12,color:Colors.black54))),
            ]),
          ),
        HandwritingPad(key:mentionKey,height:150,label:'Recopiez ici la mention avec le doigt ou un stylet'),

        const SizedBox(height:18),
        TextFormField(initialValue:d['engagementPlace']??'',decoration:const InputDecoration(labelText:'Fait à'),onChanged:(v)=>d['engagementPlace']=v),
        const SizedBox(height:12),        const Text('Signature manuscrite numérique',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:ink)),
        const SizedBox(height:5),
        const Text('La signature est dessinée directement sur l’écran et intégrée au PDF archivé.',style:TextStyle(fontSize:11,color:Colors.black54)),
        const SizedBox(height:8),
        if(existingSignature.isNotEmpty)
          Padding(
            padding:const EdgeInsets.only(bottom:8),
            child:Row(children:[
              const Icon(Icons.check_circle,color:Color(0xFF2E7D32)),
              const SizedBox(width:7),
              const Expanded(child:Text('Une signature est déjà enregistrée. Dessinez ci-dessous uniquement pour la remplacer.',style:TextStyle(fontSize:12,color:Colors.black54))),
            ]),
          ),
        HandwritingPad(key:signatureKey,height:130,label:'Signez ici'),

        const SizedBox(height:18),
        PremiumFilledButton.icon(onPressed:save,icon:const Icon(Icons.verified),label:const Text('Signer, générer et archiver le PDF')),
        const SizedBox(height:8),
        const Text(
          'La cession du lapin ne doit pas intervenir moins de 7 jours après la délivrance du certificat.',
          textAlign:TextAlign.center,
          style:TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:brown),
        ),
        const SizedBox(height:24),
      ]),
    ));
  }
}

class HandwritingPad extends StatefulWidget{
  final double height;
  final String label;
  const HandwritingPad({super.key,required this.height,required this.label});
  @override State<HandwritingPad> createState()=>HandwritingPadState();
}

class HandwritingPadState extends State<HandwritingPad>{
  final boundaryKey=GlobalKey();
  final strokes=<List<Offset>>[];

  bool get hasInk=>strokes.any((s)=>s.length>1);

  void start(DragStartDetails d)=>setState(()=>strokes.add([d.localPosition]));
  void update(DragUpdateDetails d){
    if(strokes.isEmpty)return;
    setState(()=>strokes.last.add(d.localPosition));
  }

  void clear()=>setState(()=>strokes.clear());

  Future<Uint8List?> exportPng()async{
    final boundary=boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if(boundary==null)return null;
    final image=await boundary.toImage(pixelRatio:2.5);
    final data=await image.toByteData(format:ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Row(children:[
      Expanded(child:Text(widget.label,style:const TextStyle(fontSize:11,color:Colors.black54))),
      TextButton.icon(onPressed:clear,icon:const Icon(Icons.refresh,size:17),label:const Text('Effacer')),
    ]),
    GestureDetector(
      onPanStart:start,
      onPanUpdate:update,
      child:RepaintBoundary(
        key:boundaryKey,
        child:Container(
          height:widget.height,
          decoration:BoxDecoration(
            color:Colors.white,
            borderRadius:BorderRadius.circular(14),
            border:Border.all(color:gold,width:1.4),
          ),
          clipBehavior:Clip.antiAlias,
          child:CustomPaint(
            painter:HandwritingPainter(strokes),
            child:const SizedBox.expand(),
          ),
        ),
      ),
    ),
  ]);
}

class HandwritingPainter extends CustomPainter{
  final List<List<Offset>> strokes;
  const HandwritingPainter(this.strokes);

  @override void paint(Canvas canvas,Size size){
    final paint=Paint()
      ..color=ink
      ..strokeWidth=2.2
      ..strokeCap=StrokeCap.round
      ..strokeJoin=StrokeJoin.round
      ..style=PaintingStyle.stroke;
    for(final stroke in strokes){
      if(stroke.length<2)continue;
      final path=Path()..moveTo(stroke.first.dx,stroke.first.dy);
      for(final p in stroke.skip(1))path.lineTo(p.dx,p.dy);
      canvas.drawPath(path,paint);
    }
  }

  @override bool shouldRepaint(covariant HandwritingPainter oldDelegate)=>true;
}

class AdoptionDialog extends StatefulWidget{
  final Map<String,dynamic> data;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const AdoptionDialog({super.key,required this.data,required this.onSave});
  @override State<AdoptionDialog> createState()=>_AdoptionDialogState();
}

class _AdoptionDialogState extends State<AdoptionDialog>{
  late Map<String,dynamic>d;
  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.data);
    d['adoptionStatus']??='À l’élevage';
    d['adopterName']??='';
    d['adopterContact']??='';
    d['departureDate']??='';
    d['adoptionNotes']??='';
    d['healthBookGiven']??=false;
    d['healthCertificateGiven']??=false;
    d['adoptionInfoGiven']??=false;
  }

  Future<void> pickDeparture()async{
    final current=Notifications.parseDate(d['departureDate'] as String?);
    final x=await showDatePicker(context:context,firstDate:DateTime(2020),lastDate:DateTime.now().add(const Duration(days:3650)),initialDate:current??DateTime.now());
    if(x!=null)setState(()=>d['departureDate']=Notifications.formatDate(x));
  }

  @override Widget build(BuildContext context)=>Dialog.fullscreen(child:Scaffold(
    appBar:AppBar(title:const Text('Adoption & départ'),actions:[TextButton(onPressed:()=>widget.onSave(d),child:const Text('ENREGISTRER'))]),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      const Text('Statut du lapin',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
      const SizedBox(height:10),
      Wrap(spacing:8,runSpacing:8,children:[
        for(final status in ['À l’élevage','Réservé','Adopté / parti'])
          ChoiceChip(label:Text(status),selected:d['adoptionStatus']==status,onSelected:(_)=>setState(()=>d['adoptionStatus']=status)),
      ]),
      const SizedBox(height:20),
      const Text('Adoptant',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
      const SizedBox(height:8),
      TextFormField(initialValue:d['adopterName'],decoration:const InputDecoration(labelText:'Nom / famille'),onChanged:(v)=>d['adopterName']=v),
      const SizedBox(height:10),
      TextFormField(initialValue:d['adopterContact'],decoration:const InputDecoration(labelText:'Téléphone / contact'),onChanged:(v)=>d['adopterContact']=v),
      const SizedBox(height:10),
      TextFormField(readOnly:true,controller:TextEditingController(text:d['departureDate']??''),decoration:const InputDecoration(labelText:'Date de départ prévue / réelle',suffixIcon:Icon(Icons.calendar_month)),onTap:pickDeparture),
      const SizedBox(height:20),
      const Text('Préparation du départ',style:TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:ink)),
      const SizedBox(height:5),
      Container(
        padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(color:gold.withValues(alpha:.08),borderRadius:BorderRadius.circular(16)),
        child:const Row(children:[
          Icon(Icons.info_outline,color:brown),
          SizedBox(width:9),
          Expanded(child:Text('Identification et tatouage sont facultatifs et ne bloquent pas la préparation du départ.',style:TextStyle(fontWeight:FontWeight.w700))),
        ]),
      ),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('Carnet de santé remis'),value:d['healthBookGiven'] as bool,onChanged:(v)=>setState(()=>d['healthBookGiven']=v??false)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('Certificat de santé remis'),value:d['healthCertificateGiven'] as bool,onChanged:(v)=>setState(()=>d['healthCertificateGiven']=v??false)),
      CheckboxListTile(contentPadding:EdgeInsets.zero,title:const Text('Consignes / documents d’adoption remis'),value:d['adoptionInfoGiven'] as bool,onChanged:(v)=>setState(()=>d['adoptionInfoGiven']=v??false)),
      const SizedBox(height:10),
      TextFormField(initialValue:d['adoptionNotes'],minLines:3,maxLines:7,decoration:const InputDecoration(labelText:'Notes de départ / informations utiles'),onChanged:(v)=>d['adoptionNotes']=v),
      const SizedBox(height:18),
      PremiumFilledButton.icon(onPressed:()=>widget.onSave(d),icon:const Icon(Icons.save),label:const Text('Enregistrer le suivi d’adoption')),
      const SizedBox(height:24),
    ]),
  ));
}

class ColorCountDialog extends StatefulWidget{
  final Map<String,dynamic>? initial;
  final Set<String> unavailable;
  final String breed;
  const ColorCountDialog({super.key,this.initial,this.unavailable=const <String>{},this.breed=''});
  @override State<ColorCountDialog> createState()=>_ColorCountDialogState();
}

class _ColorCountDialogState extends State<ColorCountDialog>{
  late String color;
  late int male;
  late int female;

  @override void initState(){
    super.initState();
    final initialColor=(widget.initial?['color']??'').toString();
    final available=RabbitBreedCatalog.colorsFor(widget.breed).map((e)=>(e['name']??'').toString()).where((c)=>c.isNotEmpty&&!widget.unavailable.contains(c)).toList();
    color=initialColor.isNotEmpty?initialColor:(available.isNotEmpty?available.first:'Non déterminé');
    male=ReproductionStore.n(widget.initial?['male']);
    female=ReproductionStore.n(widget.initial?['female']);
  }

  @override Widget build(BuildContext context)=>AlertDialog(
    title:Text(widget.initial==null?'Ajouter une couleur':'Modifier la couleur'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      InkWell(
        borderRadius:BorderRadius.circular(12),
        onTap:()async{
          final selected=await showDialog<String>(context:context,builder:(_)=>BreedColorPickerDialog(
            breed:widget.breed,
            initial:color,
            unavailable:widget.unavailable,
          ));
          if(selected!=null)setState(()=>color=selected);
        },
        child:InputDecorator(
          decoration:const InputDecoration(labelText:'Couleur / variété',suffixIcon:Icon(Icons.arrow_drop_down)),
          child:Row(children:[
            if(RabbitBreedCatalog.isStandard(widget.breed,color))...[const Text('🏅'),const SizedBox(width:6)],
            Expanded(child:Text(color,style:const TextStyle(fontWeight:FontWeight.w700))),
          ]),
        ),
      ),
      const SizedBox(height:4),
      Align(alignment:Alignment.centerLeft,child:Text(widget.breed.isEmpty?'Race de portée non définie':widget.breed,style:const TextStyle(fontSize:10,color:Colors.black54))),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child:DropdownButtonFormField<int>(
          value:male,
          decoration:const InputDecoration(labelText:'Mâles'),
          items:List.generate(21,(i)=>DropdownMenuItem(value:i,child:Text('$i'))),
          onChanged:(v)=>setState(()=>male=v??0),
        )),
        const SizedBox(width:10),
        Expanded(child:DropdownButtonFormField<int>(
          value:female,
          decoration:const InputDecoration(labelText:'Femelles'),
          items:List.generate(21,(i)=>DropdownMenuItem(value:i,child:Text('$i'))),
          onChanged:(v)=>setState(()=>female=v??0),
        )),
      ]),
      const SizedBox(height:8),
      Text('Total : ${male+female} lapereau${male+female>1 ? 'x' : ''}',style:const TextStyle(fontWeight:FontWeight.w800,color:brown)),
    ])),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Annuler')),
      PremiumFilledButton(
        onPressed:male+female==0?null:()=>Navigator.pop(context,{'color':color,'male':male,'female':female}),
        child:const Text('Valider'),
      ),
    ],
  );
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
    d['colors']=ReproductionStore.colorsOf(d);
  }

  List<Map<String,dynamic>> get partners=>widget.allRabbits.where((x)=>x['id']!=widget.currentRabbit['id']&&x['sex']==(currentIsMale?'Femelle':'Mâle')).toList();
  List<Map<String,dynamic>> get colorEntries=>List<Map<String,dynamic>>.from((d['colors'] as List?)??[]);

  Map<String,dynamic>? get selectedPartner{
    final partnerKey=currentIsMale?'femaleId':'maleId';
    final id=(d[partnerKey]??'').toString();
    final hits=partners.where((p)=>(p['id']??'').toString()==id);
    return hits.isEmpty?null:hits.first;
  }

  String get litterBreed{
    final a=(widget.currentRabbit['breed']??'').toString().trim();
    final b=(selectedPartner?['breed']??'').toString().trim();
    if(a.isNotEmpty&&b.isNotEmpty&&a==b)return a;
    if(a.isNotEmpty&&b.isEmpty)return a;
    if(b.isNotEmpty&&a.isEmpty)return b;
    if(a.isNotEmpty&&b.isNotEmpty&&a!=b)return 'Croisé';
    return '';
  }

  Future<void> addColor()async{
    final used=colorEntries.map((e)=>(e['color']??'').toString()).toSet();
    final available=RabbitBreedCatalog.colorsFor(litterBreed).map((e)=>(e['name']??'').toString()).where((c)=>c.isNotEmpty).toSet();
    if(available.isNotEmpty&&used.containsAll(available)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Toutes les couleurs disponibles sont déjà renseignées.')));
      return;
    }
    final result=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>ColorCountDialog(unavailable:used,breed:litterBreed));
    if(result==null)return;
    final list=colorEntries..add(result);
    setState(()=>d['colors']=list);
  }

  Future<void> editColor(int index)async{
    final list=colorEntries;
    if(index<0||index>=list.length)return;
    final used=list.asMap().entries.where((e)=>e.key!=index).map((e)=>(e.value['color']??'').toString()).toSet();
    final result=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>ColorCountDialog(initial:list[index],unavailable:used,breed:litterBreed));
    if(result==null)return;
    list[index]=result;
    setState(()=>d['colors']=list);
  }

  Future<void> deleteColor(int index)async{
    final list=colorEntries;
    if(index<0||index>=list.length)return;
    final label=(list[index]['color']??'cette couleur').toString();
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:Text('Supprimer $label ?'),
      content:const Text('Cette couleur sera retirée de cette portée et du graphique.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Supprimer'))],
    ))??false;
    if(!ok)return;
    list.removeAt(index);
    setState(()=>d['colors']=list);
  }

  Future<void> clearColors()async{
    if(colorEntries.isEmpty)return;
    final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Supprimer toutes les couleurs ?'),
      content:const Text('Le tableau des couleurs de cette portée sera entièrement vidé.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Annuler')),PremiumFilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Tout supprimer'))],
    ))??false;
    if(ok)setState(()=>d['colors']=<Map<String,dynamic>>[]);
  }

  bool validateColors(){
    final colors=ReproductionStore.colorSexTotals(colorEntries);
    if(colors['total']==0)return true;
    final totals=ReproductionStore.totals(d);
    if(colors['male']!=totals['maleTotal']||colors['female']!=totals['femaleTotal']){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(
        'Vérifiez les couleurs : ${colors['male']} mâle(s) / ${colors['female']} femelle(s) saisis, mais la portée contient ${totals['maleTotal']} mâle(s) / ${totals['femaleTotal']} femelle(s).',
      )));
      return false;
    }
    return true;
  }

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
          if(!validateColors())return;
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
        if(litterBreed.isNotEmpty)Padding(
          padding:const EdgeInsets.only(top:6,left:4),
          child:Text('Race utilisée pour les couleurs : $litterBreed',style:const TextStyle(fontSize:10.5,color:Colors.black54,fontWeight:FontWeight.w700)),
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
        PremiumCard(child:Padding(
          padding:const EdgeInsets.all(12),
          child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
            Row(children:[
              const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('Couleurs des lapereaux',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:ink)),
                SizedBox(height:2),
                Text('La liste des couleurs / variétés dépend de la race du couple. 🏅 indique une variété reconnue au standard.',style:TextStyle(fontSize:11,color:Colors.black54)),
              ])),
              if(colorEntries.isNotEmpty)IconButton(
                tooltip:'Tout supprimer',
                onPressed:clearColors,
                icon:const Icon(Icons.close,color:Colors.red),
              ),
            ]),
            if(colorEntries.isEmpty)
              const Padding(padding:EdgeInsets.symmetric(vertical:12),child:Text('Aucune couleur renseignée.',style:TextStyle(color:Colors.black54))),
            ...colorEntries.asMap().entries.map((entry){
              final i=entry.key;
              final item=entry.value;
              return Container(
                margin:const EdgeInsets.only(bottom:7),
                decoration:BoxDecoration(color:gold.withValues(alpha:.08),borderRadius:BorderRadius.circular(12),border:Border.all(color:gold.withValues(alpha:.42))),
                child:ListTile(
                  dense:true,
                  onTap:()=>editColor(i),
                  title:Text((item['color']??'').toString(),style:const TextStyle(fontWeight:FontWeight.w800)),
                  subtitle:Text('♂ ${ReproductionStore.n(item['male'])}   •   ♀ ${ReproductionStore.n(item['female'])}   •   total ${ReproductionStore.n(item['male'])+ReproductionStore.n(item['female'])}'),
                  trailing:IconButton(tooltip:'Supprimer cette couleur',onPressed:()=>deleteColor(i),icon:const Icon(Icons.close,color:Colors.red,size:21)),
                ),
              );
            }),
            const SizedBox(height:4),
            OutlinedButton.icon(onPressed:addColor,icon:const Icon(Icons.add),label:const Text('Ajouter une couleur')),
            if(colorEntries.isNotEmpty)...[
              const SizedBox(height:8),
              Builder(builder:(_){
                final ct=ReproductionStore.colorSexTotals(colorEntries);
                return Text('Total couleurs : ♂ ${ct['male']}   •   ♀ ${ct['female']}   •   ${ct['total']} lapereau(x)',style:const TextStyle(fontWeight:FontWeight.w800,color:brown));
              }),
            ],
          ]),
        )),
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
          return PremiumCard(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
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
      PremiumFilledButton(
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


class MedicationDialog extends StatefulWidget{
  final Map<String,dynamic> item;
  final Future<void> Function(Map<String,dynamic>) onSave;
  const MedicationDialog({super.key,required this.item,required this.onSave});
  @override State<MedicationDialog> createState()=>_MedicationDialogState();
}

class _MedicationDialogState extends State<MedicationDialog>{
  late Map<String,dynamic>d;

  @override void initState(){
    super.initState();
    d=Map<String,dynamic>.from(widget.item);
    d['times']=List<String>.from((d['times'] as List?)??['09:00']);
    d['route']??='Voie orale';
    d['completed']??=false;
    d['notificationsEnabled']??=true;
    d['notificationKey']??='m_${DateTime.now().microsecondsSinceEpoch}';
    d['photo']??='';
    d['prescription']??='';
  }

  Future<void> pickDate(String key,{bool future=true})async{
    final current=Notifications.parseDate(d[key] as String?)??DateTime.now();
    final x=await showDatePicker(
      context:context,
      firstDate:DateTime.now().subtract(const Duration(days:3650)),
      lastDate:DateTime.now().add(const Duration(days:3650)),
      initialDate:current,
    );
    if(x!=null)setState(()=>d[key]=Notifications.formatDate(x));
  }

  Future<void> addTime()async{
    final t=await showTimePicker(context:context,initialTime:const TimeOfDay(hour:9,minute:0));
    if(t==null)return;
    final value='${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
    final times=List<String>.from(d['times'] as List);
    if(!times.contains(value))times.add(value);
    times.sort();
    setState(()=>d['times']=times);
  }

  Future<void> attachImage()async{
    final x=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:88);
    if(x==null)return;
    final saved=await PrivateFiles.importFile(x.path,'treatments');
    if(saved.isNotEmpty)setState(()=>d['photo']=saved);
  }

  Future<void> attachPrescription()async{
    final result=await FilePicker.platform.pickFiles(type:FileType.any);
    final source=result?.files.single.path;
    if(source==null)return;
    final saved=await PrivateFiles.importFile(source,'documents');
    if(saved.isNotEmpty)setState(()=>d['prescription']=saved);
  }

  @override Widget build(BuildContext context)=>Dialog.fullscreen(child:Scaffold(
    appBar:AppBar(
      title:Text(((widget.item['name']??'') as String).isEmpty?'Nouveau traitement':'Modifier le traitement'),
      actions:[TextButton(onPressed:save,child:const Text('ENREGISTRER'))],
    ),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      Container(
        padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(color:gold.withValues(alpha:.09),borderRadius:BorderRadius.circular(15),border:Border.all(color:gold.withValues(alpha:.5))),
        child:const Text('Saisissez uniquement la posologie indiquée par votre vétérinaire. L’application sert au suivi et aux rappels, pas au calcul d’une dose.',style:TextStyle(fontSize:12,fontWeight:FontWeight.w700,color:brown)),
      ),
      const SizedBox(height:14),
      TextFormField(initialValue:d['name']??'',decoration:const InputDecoration(labelText:'Médicament / produit *'),onChanged:(v)=>d['name']=v),
      const SizedBox(height:10),
      TextFormField(initialValue:d['reason']??'',decoration:const InputDecoration(labelText:'Motif / affection'),onChanged:(v)=>d['reason']=v),
      const SizedBox(height:10),
      TextFormField(initialValue:d['dose']??'',decoration:const InputDecoration(labelText:'Dose prescrite',hintText:'Ex. 0,8 ml'),onChanged:(v)=>d['dose']=v),
      const SizedBox(height:10),
      DropdownButtonFormField<String>(
        value:['Voie orale','Injection','Application locale','Gouttes','Autre'].contains(d['route'])?d['route']:'Autre',
        decoration:const InputDecoration(labelText:'Voie d’administration'),
        items:['Voie orale','Injection','Application locale','Gouttes','Autre'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),
        onChanged:(v)=>setState(()=>d['route']=v??'Voie orale'),
      ),
      const SizedBox(height:10),
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['startDate']??''),
        decoration:const InputDecoration(labelText:'Début du traitement *',suffixIcon:Icon(Icons.calendar_month)),
        onTap:()=>pickDate('startDate'),
      ),
      const SizedBox(height:10),
      TextFormField(
        readOnly:true,
        controller:TextEditingController(text:d['endDate']??''),
        decoration:InputDecoration(
          labelText:'Fin prévue (facultatif)',
          suffixIcon:Row(mainAxisSize:MainAxisSize.min,children:[
            if(((d['endDate']??'') as String).isNotEmpty)IconButton(onPressed:()=>setState(()=>d['endDate']=''),icon:const Icon(Icons.close)),
            const Icon(Icons.calendar_month),
          ]),
        ),
        onTap:()=>pickDate('endDate'),
      ),
      const SizedBox(height:14),
      Row(children:[
        const Expanded(child:Text('Horaires de prise',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900,color:ink))),
        OutlinedButton.icon(onPressed:addTime,icon:const Icon(Icons.add),label:const Text('Horaire')),
      ]),
      const SizedBox(height:6),
      Wrap(spacing:7,runSpacing:7,children:[
        for(final time in List<String>.from(d['times'] as List))
          InputChip(
            label:Text(time),
            avatar:const Icon(Icons.schedule,size:17),
            onDeleted:(d['times'] as List).length<=1?null:()=>setState(()=>(d['times'] as List).remove(time)),
          ),
      ]),
      const SizedBox(height:10),
      SwitchListTile(
        contentPadding:EdgeInsets.zero,
        title:const Text('Rappels de prise'),
        subtitle:const Text('Une notification est programmée à chaque horaire enregistré.'),
        value:d['notificationsEnabled'] as bool,
        onChanged:(v)=>setState(()=>d['notificationsEnabled']=v),
      ),
      const SizedBox(height:10),
      TextFormField(initialValue:d['vet']??'',decoration:const InputDecoration(labelText:'Vétérinaire / clinique'),onChanged:(v)=>d['vet']=v),
      const SizedBox(height:10),      TextFormField(initialValue:d['notes']??'',minLines:3,maxLines:6,decoration:const InputDecoration(labelText:'Notes / observations'),onChanged:(v)=>d['notes']=v),
      const SizedBox(height:14),
      OutlinedButton.icon(onPressed:attachImage,icon:Icon(((d['photo']??'') as String).isEmpty?Icons.add_a_photo:Icons.check_circle),label:Text(((d['photo']??'') as String).isEmpty?'Ajouter une photo du produit':'Photo du produit ajoutée')),
      const SizedBox(height:8),
      OutlinedButton.icon(onPressed:attachPrescription,icon:Icon(((d['prescription']??'') as String).isEmpty?Icons.note_add_outlined:Icons.check_circle),label:Text(((d['prescription']??'') as String).isEmpty?'Ajouter ordonnance / document':'Ordonnance / document ajouté')),
      const SizedBox(height:10),
      SwitchListTile(
        contentPadding:EdgeInsets.zero,
        title:const Text('Traitement terminé'),
        value:d['completed'] as bool,
        onChanged:(v)=>setState(()=>d['completed']=v),
      ),
      const SizedBox(height:18),
      PremiumFilledButton.icon(onPressed:save,icon:const Icon(Icons.save),label:const Text('Enregistrer le traitement')),
      const SizedBox(height:24),
    ]),
  ));

  Future<void> save()async{
    if(((d['name']??'') as String).trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Indiquez le nom du médicament.')));
      return;
    }
    if(((d['startDate']??'') as String).trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choisissez la date de début.')));
      return;
    }
    final start=Notifications.parseDate(d['startDate'] as String?);
    final end=Notifications.parseDate(d['endDate'] as String?);
    if(start!=null&&end!=null&&end.isBefore(start)){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('La date de fin doit être postérieure au début.')));
      return;
    }
    await widget.onSave(d);
  }
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