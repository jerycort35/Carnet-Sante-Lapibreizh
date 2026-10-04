import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carnet_sante_lapibreizh/main.dart';

void main(){
  for(final kind in [PointerDeviceKind.touch,PointerDeviceKind.stylus]){
    testWidgets('Encre précise : 600 échantillons ${kind.name}, dernier point et aucun rebuild',(tester)async{
      tester.view.physicalSize=const Size(800,800);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final key=GlobalKey<HandwritingPadState>();
      await tester.pumpWidget(MaterialApp(home:Scaffold(body:Padding(padding:const EdgeInsets.fromLTRB(31,123,29,0),child:HandwritingPad(key:key,height:450,label:'Test')))));
      final state=key.currentState!;final canvas=find.byKey(state.boundaryKey);
      final origin=tester.getTopLeft(canvas);
      final paintFinder=find.descendant(of:canvas,matching:find.byType(CustomPaint));
      final initialPainterWidget=tester.widget<CustomPaint>(paintFinder);
      final g=await tester.startGesture(origin+const Offset(20.25,30.75),kind:kind,pointer:1);
      for(var i=1;i<=600;i++){
        await g.moveTo(origin+Offset(20.25+i*.25,30.75+math.sin(i*.04)*12));
      }
      await g.up();await tester.pump();
      expect(state.strokes.single.length,601);
      expect(state.strokes.single.first,const Offset(20.25,30.75));
      expect(state.strokes.single.last.dx,closeTo(170.25,1e-8));
      expect(identical(initialPainterWidget,tester.widget<CustomPaint>(paintFinder)),isTrue);
      // Final contact is included even without a move event at that position.
      state.start(PointerDownEvent(pointer:9,kind:kind,position:origin+const Offset(33.3,44.4)));
      state.end(PointerUpEvent(pointer:9,kind:kind,position:origin+const Offset(34.5,45.6)));
      expect(state.strokes.last.last.dx,closeTo(34.5,1e-8));
      expect(state.strokes.last.last.dy,closeTo(45.6,1e-8));
      // An unrelated second contact cannot overwrite the current pen stroke.
      state.start(PointerDownEvent(pointer:10,kind:kind,position:origin+const Offset(50,60)));
      state.update(PointerMoveEvent(pointer:11,kind:PointerDeviceKind.touch,position:origin+const Offset(200,200)));
      expect(state.strokes.last,const [Offset(50,60)]);
      state.end(PointerCancelEvent(pointer:10,kind:kind));
      state.start(PointerDownEvent(pointer:12,kind:kind,position:origin+const Offset(70,80)));
      expect(state.strokes.length,4);
      expect(state.strokes.last,const [Offset(70,80)]);
      await tester.pump();expect(tester.takeException(),isNull);
    });
  }
  test('Courbe lissée : extrémités exactes, positions sources conservées',(){
    final points=[const Offset(0,0),const Offset(5,10),const Offset(10,0),const Offset(15,10)];
    final copy=List<Offset>.from(points);
    final metric=HandwritingPainter.strokePath(points).computeMetrics().single;
    expect(metric.getTangentForOffset(0)!.position,points.first);
    expect((metric.getTangentForOffset(metric.length)!.position-points.last).distance,lessThan(.001));
    expect(points,copy);
    final dense=[const Offset(0,0),const Offset(1,0),const Offset(1,1),const Offset(2,1)];
    expect(HandwritingPainter.strokePath(dense).computeMetrics().single.length,lessThan(3));
    // Sparse contact samples preserve the deliberate right-angle of an L.
    final sparse=[const Offset(0,0),const Offset(0,18),const Offset(15,18)];
    expect(HandwritingPainter.strokePath(sparse).computeMetrics().single.length,33);
    expect(HandwritingPainter.strokePath([const Offset(0,0),const Offset(3,4)]).computeMetrics().single.length,5);
  });
}
