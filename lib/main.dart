import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gold = Color(0xFFD4AF67);
const ink = Color(0xFF171512);
const ivory = Color(0xFFFFFBF2);
const brown = Color(0xFF463622);

void main() => runApp(const LapibreizhApp());

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

class Store {
  static const key='lapibreizh_rabbits_v1';
  static Future<List<Map<String,dynamic>>> load() async {
    final p=await SharedPreferences.getInstance(); final s=p.getString(key); if(s==null)return [];
    return (jsonDecode(s) as List).map((e)=>Map<String,dynamic>.from(e)).toList();
  }
  static Future<void> save(List<Map<String,dynamic>> v) async { final p=await SharedPreferences.getInstance(); await p.setString(key,jsonEncode(v)); }
}


class PrivateFiles {
  static Future<Directory> _root() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/lapibreizh_files');
    if (!await dir.exists()) await dir.create(recursive: true);
    final noMedia = File('${dir.path}/.nomedia');
    if (!await noMedia.exists()) await noMedia.writeAsString('');
    return dir;
  }

  static Future<String> importFile(String sourcePath, String category) async {
    if (sourcePath.isEmpty) return '';
    final source = File(sourcePath);
    if (!await source.exists()) return '';
    final root = await _root();
    final dir = Directory('${root.path}/$category');
    if (!await dir.exists()) await dir.create(recursive: true);
    final dot = sourcePath.lastIndexOf('.');
    final ext = dot >= 0 ? sourcePath.substring(dot) : '';
    final target = File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}$ext');
    await source.copy(target.path);
    return target.path;
  }

  static Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static Future<String> replaceFile(String oldPath, String sourcePath, String category) async {
    final newPath = await importFile(sourcePath, category);
    if (newPath.isNotEmpty) await deleteFile(oldPath);
    return newPath;
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
  Future<void> refresh() async {rabbits=await Store.load(); if(mounted)setState(()=>loading=false);}
  Future<void> addRabbit() async { final r=emptyRabbit(); rabbits.add(r); await Store.save(rabbits); if(!mounted)return; await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:rabbits.length-1))); await refresh(); }
  @override Widget build(BuildContext context)=>Scaffold(
    body:Scenic(child:SafeArea(child:loading?const Center(child:CircularProgressIndicator()):CustomScrollView(slivers:[
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,18,18,8),child:Column(children:[
        Container(width:118,height:118,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:gold,width:3),boxShadow:const [BoxShadow(blurRadius:18,color:Colors.black38)]),clipBehavior:Clip.antiAlias,child:Image.asset('assets/images/logo.png',fit:BoxFit.cover)),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.symmetric(horizontal:18,vertical:10),decoration:BoxDecoration(color:ink.withValues(alpha:.90),borderRadius:BorderRadius.circular(20),border:Border.all(color:gold)),child:const Column(children:[Text('CARNET DE SANTÉ',style:TextStyle(color:gold,fontWeight:FontWeight.w800,fontSize:22,letterSpacing:1.2)),Text('Les Lapibreizh',style:TextStyle(color:Colors.white,fontSize:16))])),
        const SizedBox(height:18),
      ]))),
      if(rabbits.isEmpty) SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(22),child:Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[const Icon(Icons.pets,size:46,color:brown),const SizedBox(height:12),const Text('Votre carnet commence ici',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold)),const SizedBox(height:8),const Text('Créez une fiche pour chaque lapin et gardez son suivi de santé au même endroit.',textAlign:TextAlign.center),const SizedBox(height:16),FilledButton.icon(onPressed:addRabbit,icon:const Icon(Icons.add),label:const Text('Créer mon premier lapin'))]))))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(14,0,14,110),sliver:SliverList.builder(itemCount:rabbits.length,itemBuilder:(c,i){final r=rabbits[i];return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(child:ListTile(contentPadding:const EdgeInsets.all(12),leading:Hero(tag:'rabbit$i',child:CircleAvatar(radius:34,backgroundColor:gold,backgroundImage:fileImage(r['photo']),child:(r['photo']??'').isEmpty?const Icon(Icons.pets,color:ink,size:32):null)),title:Text((r['name']??'').isEmpty?'Lapin sans nom':r['name'],style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),subtitle:Text('${r['breed']?.isEmpty==false?r['breed']:'Race à renseigner'}${r['birth']?.isEmpty==false?'  •  ${r['birth']}':''}'),trailing:const Icon(Icons.chevron_right,color:brown),onTap:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>RabbitPage(index:i)));await refresh();})));})),
    ]))),
    floatingActionButton:rabbits.isEmpty?null:FloatingActionButton.extended(onPressed:addRabbit,backgroundColor:ink,foregroundColor:gold,icon:const Icon(Icons.add),label:const Text('Nouveau lapin')),
  );
}

ImageProvider? fileImage(dynamic p){if(p is String&&p.isNotEmpty&&File(p).existsSync())return FileImage(File(p));return null;}
Map<String,dynamic> emptyRabbit()=>{'name':'','sex':'','breed':'','birth':'','weaning':'','photo':'','fatherName':'','fatherBreed':'','fatherBirth':'','motherName':'','motherBreed':'','motherBirth':'','vaccines':[],'dewormings':[],'healthBook':'','passport':''};

class RabbitPage extends StatefulWidget{final int index;const RabbitPage({super.key,required this.index});@override State<RabbitPage> createState()=>_RabbitPageState();}
class _RabbitPageState extends State<RabbitPage>{
  List<Map<String,dynamic>> all=[]; Map<String,dynamic>? r; final picker=ImagePicker();
  @override void initState(){super.initState();load();}
  Future<void> load()async{all=await Store.load();r=all[widget.index];if(mounted)setState((){});}
  Future<void> persist()async{all[widget.index]=r!;await Store.save(all);if(mounted)setState((){});}
  Future<String> pickImage(String category)async{final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:88);if(x==null)return '';return PrivateFiles.importFile(x.path,category);}
  Future<void> editIdentity()async{final data=Map<String,dynamic>.from(r!);await showDialog(context:context,builder:(ctx)=>EditIdentity(data:data,onSave:(v)async{r=v;await persist();Navigator.pop(ctx);}));}
  Future<void> addTreatment(String key,String title)async{final item={'date':'','product':'','photo':''};await showDialog(context:context,builder:(ctx)=>TreatmentDialog(title:title,item:item,onSave:(v)async{(r![key] as List).add(v);await persist();if(ctx.mounted)Navigator.pop(ctx);}));}
  Future<void> attach(String key)async{
    final res=await FilePicker.platform.pickFiles(type:FileType.any);
    final source=res?.files.single.path;
    if(source!=null){
      final old=(r![key]??'') as String;
      final saved=await PrivateFiles.importFile(source,'documents');
      if(saved.isNotEmpty){r![key]=saved;await persist();await PrivateFiles.deleteFile(old);}
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
    for(final k in ['photo','healthBook','passport']){await PrivateFiles.deleteFile((doomed[k]??'') as String);}
    for(final k in ['vaccines','dewormings']){for(final x in doomed[k] as List){await PrivateFiles.deleteFile((x['photo']??'') as String);}}
    all.removeAt(widget.index);await Store.save(all);if(mounted)Navigator.pop(context);
  }}
  @override Widget build(BuildContext context){if(r==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));final rr=r!;return Scaffold(
    body:Scenic(compact:true,child:SafeArea(child:CustomScrollView(slivers:[
      SliverAppBar(backgroundColor:ink.withValues(alpha:.94),foregroundColor:gold,pinned:true,title:Text(rr['name'].isEmpty?'Fiche du lapin':rr['name']),actions:[IconButton(onPressed:share,icon:const Icon(Icons.share)),PopupMenuButton<String>(onSelected:(v){if(v=='delete')deleteRabbit();},itemBuilder:(_)=>const [PopupMenuItem(value:'delete',child:Text('Supprimer la fiche'))])]),
      SliverPadding(padding:const EdgeInsets.fromLTRB(14,16,14,40),sliver:SliverList.list(children:[
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[GestureDetector(onTap:()async{final p=await pickImage('rabbit_photos');if(p.isNotEmpty){final old=(rr['photo']??'') as String;rr['photo']=p;await persist();await PrivateFiles.deleteFile(old);}},child:Hero(tag:'rabbit${widget.index}',child:CircleAvatar(radius:62,backgroundColor:gold,backgroundImage:fileImage(rr['photo']),child:rr['photo'].isEmpty?const Icon(Icons.add_a_photo,size:42,color:ink):null))),const SizedBox(height:12),Text(rr['name'].isEmpty?'Nom à renseigner':rr['name'],style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:ink)),if(rr['breed'].isNotEmpty)Text(rr['breed'],style:const TextStyle(fontSize:16,color:brown)),const SizedBox(height:12),FilledButton.icon(onPressed:editIdentity,icon:const Icon(Icons.edit),label:const Text('Identité & filiation'))]))),
        section('Identité',Icons.badge,[info('Sexe',rr['sex']),info('Naissance',rr['birth']),info('Sevrage',rr['weaning']),info('Race',rr['breed'])]),
        section('Filiation',Icons.account_tree,[info('Père',rr['fatherName']),info('Race du père',rr['fatherBreed']),info('Naissance du père',rr['fatherBirth']),const Divider(),info('Mère',rr['motherName']),info('Race de la mère',rr['motherBreed']),info('Naissance de la mère',rr['motherBirth'])]),
        treatmentSection('Vaccins','vaccines',Icons.vaccines), treatmentSection('Vermifuges','dewormings',Icons.medication),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header('Documents',Icons.folder_copy),docButton('Carnet de santé','healthBook'),const SizedBox(height:8),docButton('Passeport','passport')]))),
        const SizedBox(height:12),FilledButton.icon(onPressed:share,icon:const Icon(Icons.share),label:const Text('Partager la fiche complète')),
      ]))
    ]))),
  );}
  Widget header(String t,IconData i)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[Icon(i,color:brown),const SizedBox(width:8),Text(t,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w800,color:ink))]));
  Widget section(String t,IconData i,List<Widget> ch)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header(t,i),...ch])));
  Widget info(String a,dynamic b)=>Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:145,child:Text(a,style:const TextStyle(fontWeight:FontWeight.w600,color:brown))),Expanded(child:Text((b??'').toString().isEmpty?'—':b.toString()))]));
  Widget treatmentSection(String title,String key,IconData icon){final list=r![key] as List;return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[header(title,icon),if(list.isEmpty)const Padding(padding:EdgeInsets.only(bottom:10),child:Text('Aucun enregistrement.',style:TextStyle(color:Colors.black54))),...list.asMap().entries.map((e)=>ListTile(contentPadding:EdgeInsets.zero,leading:CircleAvatar(backgroundColor:gold.withValues(alpha:.25),backgroundImage:fileImage(e.value['photo']),child:(e.value['photo']??'').isEmpty?Icon(icon,color:brown):null),title:Text(e.value['product']?.isEmpty==false?e.value['product']:'Produit non renseigné',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(e.value['date']??''),trailing:IconButton(icon:const Icon(Icons.delete_outline),onPressed:()async{final photo=(e.value['photo']??'') as String;list.removeAt(e.key);await persist();await PrivateFiles.deleteFile(photo);}))),OutlinedButton.icon(onPressed:()=>addTreatment(key,title.substring(0,title.length-1)),icon:const Icon(Icons.add),label:Text('Ajouter ${title.toLowerCase()}'))])));}
  Widget docButton(String label,String key){
    final p=(r![key]??'') as String;
    if(p.isEmpty)return OutlinedButton.icon(onPressed:()=>attach(key),icon:const Icon(Icons.attach_file,color:brown),label:Text('Ajouter $label'));
    return Row(children:[
      Expanded(child:OutlinedButton.icon(onPressed:()=>attach(key),icon:const Icon(Icons.check_circle,color:Colors.green),label:Text('$label ajouté • remplacer'))),
      PopupMenuButton<String>(onSelected:(v){if(v=='replace')attach(key);if(v=='delete')removeDocument(key);},itemBuilder:(_)=>const [PopupMenuItem(value:'replace',child:Text('Remplacer')),PopupMenuItem(value:'delete',child:Text('Supprimer'))])
    ]);
  }
}

class EditIdentity extends StatefulWidget{final Map<String,dynamic> data;final Future<void> Function(Map<String,dynamic>) onSave;const EditIdentity({super.key,required this.data,required this.onSave});@override State<EditIdentity> createState()=>_EditIdentityState();}
class _EditIdentityState extends State<EditIdentity>{late Map<String,dynamic>d;@override void initState(){super.initState();d=Map.from(widget.data);} @override Widget build(BuildContext context)=>Dialog.fullscreen(child:Scaffold(appBar:AppBar(title:const Text('Identité & filiation'),actions:[TextButton(onPressed:()=>widget.onSave(d),child:const Text('ENREGISTRER'))]),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Le lapin',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),field('Nom','name'),field('Sexe','sex'),field('Race','breed'),dateField('Date de naissance','birth'),dateField('Date de sevrage','weaning'),const SizedBox(height:20),const Text('Père',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),field('Nom du père','fatherName'),field('Race du père','fatherBreed'),dateField('Date de naissance du père','fatherBirth'),const SizedBox(height:20),const Text('Mère',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),field('Nom de la mère','motherName'),field('Race de la mère','motherBreed'),dateField('Date de naissance de la mère','motherBirth')] )));
  Widget field(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(initialValue:d[key]??'',decoration:InputDecoration(labelText:label),onChanged:(v)=>d[key]=v));
  Widget dateField(String label,String key)=>Padding(padding:const EdgeInsets.only(top:10),child:TextFormField(readOnly:true,controller:TextEditingController(text:d[key]??''),decoration:InputDecoration(labelText:label,suffixIcon:const Icon(Icons.calendar_month)),onTap:()async{final x=await showDatePicker(context:context,firstDate:DateTime(1990),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:DateTime.now());if(x!=null)setState(()=>d[key]='${x.day.toString().padLeft(2,'0')}/${x.month.toString().padLeft(2,'0')}/${x.year}');}));
}

class TreatmentDialog extends StatefulWidget{final String title;final Map<String,dynamic> item;final Future<void> Function(Map<String,dynamic>) onSave;const TreatmentDialog({super.key,required this.title,required this.item,required this.onSave});@override State<TreatmentDialog> createState()=>_TreatmentDialogState();}
class _TreatmentDialogState extends State<TreatmentDialog>{late Map<String,dynamic>d;@override void initState(){super.initState();d=Map.from(widget.item);} @override Widget build(BuildContext context)=>AlertDialog(title:Text('Ajouter ${widget.title.toLowerCase()}'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextFormField(initialValue:d['product'],decoration:const InputDecoration(labelText:'Produit utilisé'),onChanged:(v)=>d['product']=v),const SizedBox(height:10),TextFormField(readOnly:true,controller:TextEditingController(text:d['date']),decoration:const InputDecoration(labelText:'Date',suffixIcon:Icon(Icons.calendar_month)),onTap:()async{final x=await showDatePicker(context:context,firstDate:DateTime(2000),lastDate:DateTime.now().add(const Duration(days:365)),initialDate:DateTime.now());if(x!=null)setState(()=>d['date']='${x.day.toString().padLeft(2,'0')}/${x.month.toString().padLeft(2,'0')}/${x.year}');}),const SizedBox(height:10),OutlinedButton.icon(onPressed:()async{final x=await ImagePicker().pickImage(source:ImageSource.gallery,imageQuality:88);if(x!=null){final saved=await PrivateFiles.importFile(x.path,'treatments');if(saved.isNotEmpty)setState(()=>d['photo']=saved);}},icon:Icon((d['photo'] as String).isEmpty?Icons.add_a_photo:Icons.check_circle),label:Text((d['photo'] as String).isEmpty?'Ajouter la photo du produit':'Photo ajoutée'))])),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Annuler')),FilledButton(onPressed:()=>widget.onSave(d),child:const Text('Enregistrer'))]);}
