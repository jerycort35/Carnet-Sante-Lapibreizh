import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';
void main(){
  setUpAll(()async{
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await LapiFrameAssets.instance.load();
    for(final family in ['Roboto','LapiText','LapiEditorial']){
      final name=family=='LapiEditorial'?'DejaVuSerif':'DejaVuSans';
      await (FontLoader(family)..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  for(final kind in [PointerDeviceKind.touch,PointerDeviceKind.stylus]){
    testWidgets('Zoom 2x, déplacement sans encre, validation ${kind.name}',(tester)async{
      tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final key=GlobalKey<HandwritingPadState>();
      final app=const LapibreizhApp().build(tester.element(find.byType(Container).first)) as MaterialApp;
      await tester.pumpWidget(RepaintBoundary(key:const Key('capture'),child:MaterialApp(theme:app.theme,debugShowCheckedModeBanner:false,home:Scaffold(body:HandwritingPad(key:key,height:450,label:'Mention')))));
      await tester.tap(find.byTooltip('Agrandir pour écrire'));await tester.pumpAndSettle();
      final editor=find.byType(HandwritingEditor);
      final pad=tester.state<HandwritingPadState>(find.descendant(of:editor,matching:find.byType(HandwritingPad)));
      final origin=tester.getTopLeft(find.byKey(pad.boundaryKey));
      final g=await tester.startGesture(origin+const Offset(40,40),kind:kind);
      await g.moveBy(const Offset(100,60));await g.up();await tester.pump();
      final dir=Platform.environment['LAPI_CAPTURE_DIR'];
      if(dir!=null)await tester.runAsync(()async{
        final boundary=tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture')));
        final image=await boundary.toImage(pixelRatio:2);
        final data=await image.toByteData(format:ui.ImageByteFormat.png);
        Directory(dir).createSync(recursive:true);
        File('$dir/zoom_${kind.name}.png').writeAsBytesSync(data!.buffer.asUint8List());image.dispose();
      });
      expect(pad.strokes.single.first,const Offset(20,20));
      expect(pad.strokes.single.last,const Offset(70,50));
      await tester.tap(find.text('Écrire'));await tester.pump();
      await tester.dragFrom(origin+const Offset(60,80),const Offset(-20,-30));await tester.pump();
      expect(pad.strokes.length,1);
      await tester.tap(find.text('Déplacer'));await tester.pump();
      await tester.tap(find.text('Valider'));await tester.pumpAndSettle();
      expect(key.currentState!.strokes.single.last,const Offset(70,50));
      await tester.tap(find.byTooltip('Agrandir pour écrire'));await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Effacer'));await tester.pump();
      await tester.tap(find.byTooltip('Annuler'));await tester.pumpAndSettle();
      expect(key.currentState!.strokes.length,1);
      expect(tester.takeException(),isNull);
    });
  }
  testWidgets('Paume avant stylet, contacts parasites et annulation du dernier trait',(tester)async{
    final key=GlobalKey<HandwritingPadState>();
    await tester.pumpWidget(MaterialApp(home:Scaffold(body:HandwritingPad(key:key,height:450,label:'Mention'))));
    final pad=key.currentState!;final origin=tester.getTopLeft(find.byKey(pad.boundaryKey));
    pad.start(PointerDownEvent(pointer:1,kind:PointerDeviceKind.touch,position:origin+const Offset(10,10)));
    pad.end(PointerUpEvent(pointer:1,kind:PointerDeviceKind.touch,position:origin+const Offset(20,20)));
    pad.start(PointerDownEvent(pointer:2,kind:PointerDeviceKind.touch,position:origin+const Offset(90,90)));
    pad.start(PointerDownEvent(pointer:3,kind:PointerDeviceKind.stylus,position:origin+const Offset(30,30)));
    pad.update(PointerMoveEvent(pointer:2,kind:PointerDeviceKind.touch,position:origin+const Offset(150,150)));
    pad.update(PointerMoveEvent(pointer:3,kind:PointerDeviceKind.stylus,position:origin+const Offset(40,40)));
    pad.end(PointerUpEvent(pointer:3,kind:PointerDeviceKind.stylus,position:origin+const Offset(40,40)));
    expect(pad.strokes.length,2);expect(pad.strokes.last,const [Offset(30,30),Offset(40,40)]);
    pad.undo();expect(pad.strokes.single,const [Offset(10,10),Offset(20,20)]);
  });
}
