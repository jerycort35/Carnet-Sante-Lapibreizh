part of 'main.dart';

/// Decorative geometry stays in the edge rails. The centre is never scaled or
/// painted over: the same component can grow without stretching its ornaments.
enum LapiFrameKind { card, button, field, panel }

/// Original illustrated frames, rendered in nine slices: corners keep their
/// proportions while only the empty rails and centre adapt to the component.
class LapiFrameAssets extends ChangeNotifier {
  static final instance = LapiFrameAssets();
  final Map<String, ui.Image> images = {};
  Future<void>? _loading;
  Future<void> load() => _loading ??= _load();
  Future<void> _load() async {
    for (final name in ['lapi_frame_button_alpha.png',
      'lapi_frame_card_alpha.png', 'lapigestion_gold_corner_volute.png']) {
      final bytes = await rootBundle.load('assets/images/$name');
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List(
        bytes.offsetInBytes, bytes.lengthInBytes));
      images[name] = (await codec.getNextFrame()).image;
      codec.dispose();
    }
    notifyListeners();
  }
}

class PremiumGoldFramePainter extends CustomPainter {
  final double radius;
  final int ornamentLevel;
  final LapiFrameKind kind;
  final bool selected;
  PremiumGoldFramePainter({this.radius = 16, this.ornamentLevel = 2,
    this.kind = LapiFrameKind.card, this.selected = false})
      : super(repaint: LapiFrameAssets.instance) {
    LapiFrameAssets.instance.load();
  }

  void _border(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.2);
    final shader = const LinearGradient(colors: [Color(0xFF95601E),
      Color(0xFFFFEBAD), Color(0xFFBA802C), Color(0xFFF3CF75)],
      begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..shader=shader);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2), Radius.circular(radius-2)),
      Paint()..style=PaintingStyle.stroke..strokeWidth=.6..color=const Color(0xFFFFE8A3));
  }

  void _greenOrnaments(Canvas canvas, Size size) {
    _border(canvas,size);
    final image = LapiFrameAssets.instance.images['lapigestion_gold_corner_volute.png'];
    if(image == null) return;
    final d = (kind == LapiFrameKind.panel ? 39.0 : 23.0)
      .clamp(0.0,size.height*.48).toDouble();
    final src = Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble());
    final paint = Paint()..filterQuality=FilterQuality.high;
    canvas.drawImageRect(image,src,Rect.fromLTWH(size.width-d, size.height-d, d,d),paint);
    canvas.save();
    canvas.translate(d,d);canvas.rotate(3.141592653589793);
    canvas.drawImageRect(image,src,Rect.fromLTWH(0,0,d,d),paint);
    canvas.restore();
  }

  void paintOrnaments(Canvas canvas, Size size) => paint(canvas,size);

  @override
  void paint(Canvas canvas, Size size) {
    if(size.width<8 || size.height<8) return;
    if(selected) {_greenOrnaments(canvas,size);return;}
    final compact = kind==LapiFrameKind.button || kind==LapiFrameKind.field;
    final name = compact ? 'lapi_frame_button_alpha.png' : 'lapi_frame_card_alpha.png';
    final image = LapiFrameAssets.instance.images[name];
    if(image == null) {_border(canvas,size);return;}
    // Fixed ornamental corners at their intended physical size. Never stretch
    // a leaf to fill a tall card or squeeze it into a narrow button.
    _border(canvas,size);
    final paint=Paint()..filterQuality=FilterQuality.high;
    final w=image.width.toDouble(),h=image.height.toDouble();
    if(compact) {
      // The extracted button contains transparent margins; use the art region.
      final art=Rect.fromLTRB(w*.008,h*.10,w*.998,h*.82);
      final height=size.height.clamp(0.0,48.0).toDouble();
      final left=(height*.62).clamp(0.0,size.width*.3).toDouble();
      final right=(height*.25).clamp(0.0,size.width*.2).toDouble();
      final leftSource=Rect.fromLTRB(art.left,art.top,w*.235,art.bottom);
      final rightSource=Rect.fromLTRB(w*.88,art.top,art.right,art.bottom);
      if(kind==LapiFrameKind.field && size.height>height){
        // Use complete corner flourishes for tall fields; slicing through a
        // button's leaves would create visible, abruptly cut ornaments.
        final card=LapiFrameAssets.instance.images['lapi_frame_card_alpha.png'];
        if(card!=null){
          final cw=card.width.toDouble(),ch=card.height.toDouble();
          final factor=left/155;
          canvas.drawImageRect(card,Rect.fromLTRB(cw*.674,0,cw,ch*.395),
            Rect.fromLTWH(size.width-128*factor,0,128*factor,75*factor),paint);
          canvas.drawImageRect(card,Rect.fromLTRB(0,ch*.368,cw*.394,ch),
            Rect.fromLTWH(0,size.height-120*factor,155*factor,120*factor),paint);
        }
      }else{
        canvas.drawImageRect(image,leftSource,Rect.fromLTWH(0,0,left,height),paint);
        canvas.drawImageRect(image,rightSource,Rect.fromLTWH(size.width-right,0,right,height),paint);
      }
    } else {
      final factor=(size.height/190).clamp(0.0,.34).toDouble();
      canvas.drawImageRect(image,Rect.fromLTRB(w*.674,0,w,h*.395),
        Rect.fromLTWH(size.width-128*factor,0,128*factor,75*factor),paint);
      canvas.drawImageRect(image,Rect.fromLTRB(0,h*.368,w*.394,h),
        Rect.fromLTWH(0,size.height-120*factor,155*factor,120*factor),paint);
    }
  }
  @override
  bool shouldRepaint(covariant PremiumGoldFramePainter old) =>
    old.kind!=kind || old.radius!=radius || old.selected!=selected;
}

class LapiSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final LapiFrameKind kind;
  final Color color;
  final bool selected;
  const LapiSurface(
      {super.key,
      required this.child,
      this.radius = 16,
      this.kind = LapiFrameKind.card,
      this.color = premiumCard,
      this.selected = false});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? heroGreen : color,
          gradient:selected?null:const LinearGradient(colors:[Color(0xFFFFFAEC),Color(0xFFFFFEF8),Color(0xFFF8EFDA)],begin:Alignment.topLeft,end:Alignment.bottomRight),
          image: selected
              ? const DecorationImage(
                  image:
                      AssetImage('assets/images/lapigestion_green_marble.jpg'),
                  fit: BoxFit.cover)
              : null,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
                color: Color(0x126A4A18), blurRadius: 5, offset: Offset(0, 2))
          ],
        ),
        child: CustomPaint(
          painter:
              PremiumGoldFramePainter(radius: radius, kind: kind, selected:selected),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: kind == LapiFrameKind.card || kind == LapiFrameKind.panel
                ? Padding(padding: const EdgeInsets.all(5), child: child)
                : child,
          ),
        ),
      );
}

/// Native input layout, focus, errors and floating labels are retained.
class LapiFieldBorder extends OutlineInputBorder {
  const LapiFieldBorder({
    super.borderSide = const BorderSide(color: softGoldLine, width: 1),
    super.borderRadius = const BorderRadius.all(Radius.circular(13)),
    super.gapPadding = 4,
  });

  @override
  LapiFieldBorder copyWith(
          {BorderSide? borderSide,
          BorderRadius? borderRadius,
          double? gapPadding}) =>
      LapiFieldBorder(
        borderSide: borderSide ?? this.borderSide,
        borderRadius: borderRadius ?? this.borderRadius,
        gapPadding: gapPadding ?? this.gapPadding,
      );

  @override
  void paint(Canvas canvas, Rect rect,
      {double? gapStart,
      double gapExtent = 0,
      double gapPercentage = 0,
      TextDirection? textDirection}) {
    canvas.save();
    if (gapStart != null && gapExtent > 0 && gapPercentage > 0) {
      final start = textDirection == TextDirection.rtl
          ? rect.right - gapStart - gapExtent - gapPadding
          : rect.left + gapStart - gapPadding;
      final gap = Rect.fromLTWH(start, rect.top - 3,
          (gapExtent + gapPadding * 2) * gapPercentage, 7);
      canvas.clipPath(Path.combine(PathOperation.difference,
          Path()..addRect(rect.inflate(3)), Path()..addRect(gap)));
    }
    canvas.translate(rect.left, rect.top);
    PremiumGoldFramePainter(radius: 13, kind: LapiFrameKind.field)
        .paintOrnaments(canvas, rect.size);
    canvas.restore();
    if (borderSide.width > 1) {
      super.paint(canvas, rect, gapStart: gapStart, gapExtent: gapExtent,
          gapPercentage: gapPercentage, textDirection: textDirection);
    }
  }
}

class LapiButtonBorder extends RoundedRectangleBorder {
  const LapiButtonBorder(
      {super.side = const BorderSide(color: softGoldLine),
      super.borderRadius = const BorderRadius.all(Radius.circular(13))});

  @override
  LapiButtonBorder copyWith(
          {BorderSide? side, BorderRadiusGeometry? borderRadius}) =>
      LapiButtonBorder(
          side: side ?? this.side,
          borderRadius: borderRadius ?? this.borderRadius);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    super.paint(canvas, rect, textDirection: textDirection);
    canvas.save();
    canvas.translate(rect.left, rect.top);
    PremiumGoldFramePainter(radius: 13, kind: LapiFrameKind.button)
        .paintOrnaments(canvas, rect.size);
    canvas.restore();
  }
}

class PremiumFormPanel extends StatelessWidget {
  final Widget child;
  const PremiumFormPanel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LapiSurface(kind: LapiFrameKind.panel, child: child),
        ),
      );
}

class PremiumChoiceChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Color? backgroundColor, selectedColor, checkmarkColor;
  final BorderSide? side;
  const PremiumChoiceChip(
      {super.key,
      required this.label,
      required this.selected,
      this.onSelected,
      this.backgroundColor,
      this.selectedColor,
      this.checkmarkColor,
      this.side});

  @override
  Widget build(BuildContext context) => LapiSurface(
        radius: 12,
        kind: LapiFrameKind.button,
        selected: selected,
        color: cream,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: m.ChoiceChip(
            label: label,
            selected: selected,
            onSelected: onSelected,
            showCheckmark: false,
            backgroundColor: Colors.transparent,
            selectedColor: Colors.transparent,
            disabledColor: Colors.transparent,
            color: const WidgetStatePropertyAll(Colors.transparent),
            side: BorderSide.none,
            elevation: 0,
            pressElevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
            labelStyle: TextStyle(
                fontFamily: 'LapiText',
                color: selected ? warmGoldText : lapiGreenDark,
                fontSize: 12,
                fontWeight: FontWeight.w700),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
