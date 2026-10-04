import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main(){
  setUpAll(() async {
    await LapiFrameAssets.instance.load();
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for(final family in ['LapiText','LapiEditorial','Roboto']){
      final name=family=='LapiEditorial'?'DejaVuSerif':'DejaVuSans';
      await (FontLoader(family)..addFont(rootBundle.load('assets/fonts/$name.ttf'))..addFont(rootBundle.load('assets/fonts/$name-Bold.ttf'))).load();
    }
  });
  Future<void> draw(WidgetTester tester,HandwritingPadState state,PointerDeviceKind kind,int index)async{
    final surface=find.byKey(state.boundaryKey);
    final origin=tester.getTopLeft(surface)+Offset(25+(index%5)*35,30+(index~/5)*45);
    final g=await tester.startGesture(index%5==1?origin+const Offset(0,18):origin,kind:kind);
    // Separate strokes spell LAPIN on several lines, with a lift after each letter.
    final paths=<List<Offset>>[
      [const Offset(0,18),const Offset(15,18)],
      [const Offset(7,0),const Offset(14,18),const Offset(10,9),const Offset(3,9)],
      [const Offset(0,18),Offset.zero,const Offset(14,0),const Offset(14,9),const Offset(0,9)],
      [const Offset(0,18)],
      [const Offset(0,18),Offset.zero,const Offset(14,18),const Offset(14,0)],
    ];
    for(final point in paths[index%5]){await g.moveTo(origin+point);}
    await g.up();
    await tester.pump();
  }
  Future<void> scrollTo(WidgetTester tester,Finder target)async{
    for(var i=0;i<40&&target.hitTestable().evaluate().isEmpty;i++){
      // Scroll in the margin outside the writing canvas, just as on a phone.
      await tester.dragFrom(const Offset(18,650),const Offset(0,-260));
      await tester.pumpAndSettle();
    }
    expect(target.hitTestable(),findsOneWidget);
  }
  Future<void> capture(WidgetTester tester,String name)async{
    final dir=Platform.environment['LAPI_CAPTURE_DIR'];if(dir==null)return;
    await tester.runAsync(()async{
      final boundary=tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture')));
      final img=await boundary.toImage(pixelRatio:2);
      final bytes=await img.toByteData(format:ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive:true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());img.dispose();
    });
  }
  for(final kind in [PointerDeviceKind.touch,PointerDeviceKind.stylus]){
    testWidgets('Certificat : tracés indépendants et défilement — ${kind.name}',(tester)async{
      tester.view.physicalSize=const Size(390,844);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final app=const LapibreizhApp().build(tester.element(find.byType(Container).first)) as MaterialApp;
      await tester.pumpWidget(RepaintBoundary(key:const Key('capture'),child:MaterialApp(
        debugShowCheckedModeBanner:false,theme:app.theme,home:EngagementCertificateDialog(data:emptyRabbit(),onSave:(_)async{}),
      )));
      await tester.pumpAndSettle();
      final scroll=find.byType(Scrollable).first;
      await scrollTo(tester,find.byWidgetPredicate((w)=>w is HandwritingPad&&w.height==450));
      final mention=tester.state<HandwritingPadState>(find.byType(HandwritingPad).first);
      await tester.ensureVisible(find.byKey(mention.boundaryKey));await tester.pumpAndSettle();
      final size=tester.getSize(find.byKey(mention.boundaryKey));
      expect(size.height,450);expect(size.width,lessThan(390));
      final controller=tester.state<ScrollableState>(scroll).position;
      final offset=controller.pixels;
      for(var i=0;i<28;i++){await draw(tester,mention,kind,i);}
      expect(mention.strokes.length,28);expect(controller.pixels,offset);
      final original=mention.strokes.map((s)=>List<Offset>.from(s)).toList();
      await capture(tester,'mention_${kind.name}');
      await scrollTo(tester,find.text('Signez ici'));
      final signature=tester.stateList<HandwritingPadState>(find.byType(HandwritingPad)).firstWhere((s)=>s.widget.label=='Signez ici');
      await tester.ensureVisible(find.byKey(signature.boundaryKey));await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(signature.boundaryKey)).width,size.width);
      expect(tester.getSize(find.byKey(signature.boundaryKey)).height,130);
      expect(tester.getRect(find.byKey(signature.boundaryKey)).top,greaterThan(tester.getRect(find.byKey(mention.boundaryKey)).bottom));
      for(var i=0;i<10;i++){await draw(tester,signature,kind,i);}
      expect(signature.strokes.length,10);expect(mention.strokes,original);
      await capture(tester,'signature_${kind.name}');
      await scrollTo(tester,find.text('Signer, générer et archiver le PDF'));
      expect(find.text('Signer, générer et archiver le PDF').hitTestable(),findsOneWidget);
      // Return to a previously offscreen mention and continue writing.
      await tester.ensureVisible(find.byKey(mention.boundaryKey));await tester.pumpAndSettle();
      expect(mention.strokes,original);
      await draw(tester,mention,kind,28);
      expect(mention.strokes.length,29);expect(signature.strokes.length,10);
      await tester.runAsync(()async{
        final bytes=await mention.exportPng();expect(bytes,isNotNull);
        final codec=await ui.instantiateImageCodec(bytes!);final frame=await codec.getNextFrame();
        final rgba=await frame.image.toByteData(format:ui.ImageByteFormat.rawRgba);
        var dark=0;for(var i=0;i<rgba!.lengthInBytes;i+=4){if(rgba.getUint8(i)<80&&rgba.getUint8(i+1)<80&&rgba.getUint8(i+2)<80)dark++;}
        expect(dark,greaterThan(1000));frame.image.dispose();codec.dispose();
        // The signature remains exportable even while outside the viewport.
        expect(await signature.exportPng(),isNotNull);
      });
      expect(tester.takeException(),isNull);
      signature.clear();await tester.pump();
      expect(signature.hasInk,isFalse);expect(mention.strokes.length,29);
    });
  }
}
