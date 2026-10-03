part of 'main.dart';

/// Decorative geometry stays in the edge rails. The centre is never scaled or
/// painted over: the same component can grow without stretching its ornaments.
enum LapiFrameKind { card, button, field, panel }

class PremiumGoldFramePainter extends CustomPainter {
  final double radius;
  final int ornamentLevel;
  final LapiFrameKind kind;
  const PremiumGoldFramePainter({
    this.radius = 16,
    this.ornamentLevel = 2,
    this.kind = LapiFrameKind.card,
  });

  Paint _metal(Rect rect, {bool fill = false, double width = 1.1}) => Paint()
    ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..shader = const LinearGradient(
      colors: [
        Color(0xFFAD7728),
        Color(0xFFF5DA92),
        Color(0xFFBE8B37),
        Color(0xFFE8C77E)
      ],
      stops: [0, .36, .7, 1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

  // Sculpted acanthus: a closed contour, a light ridge and an inset vein.
  void _leaf(Canvas canvas, double length, double depth, Rect rect) {
    final leaf = Path()
      ..moveTo(0, 0)
      ..cubicTo(length * .22, -depth, length * .55, -depth, length, 0)
      ..cubicTo(length * .62, -depth * .12, length * .32, depth * .58, 0, 0)
      ..close();
    canvas.drawPath(leaf, _metal(rect, fill: true));
    canvas.drawPath(
        leaf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .55
          ..color = const Color(0xFFAC772D));
    final ridge = Path()
      ..moveTo(1, 0)
      ..cubicTo(
          length * .3, -depth * .32, length * .62, -depth * .2, length * .9, 0);
    canvas.drawPath(
        ridge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFEDBB));
  }

  void _scroll(Canvas canvas, Rect rect,
      {double length = 34, bool leaf = true}) {
    final stem = Path()
      ..moveTo(0, 0)
      ..cubicTo(length * .3, 0, length * .36, 7, length * .7, 7)
      ..cubicTo(length * .96, 7, length, -2, length * .79, -2)
      ..cubicTo(length * .63, -2, length * .67, 4, length * .77, 3);
    canvas.drawPath(stem, _metal(rect, width: 1.25));
    canvas.drawPath(
        stem.shift(const Offset(0, -.7)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .4
          ..color = const Color(0xFFFFE9B0));
    if (leaf) {
      canvas.save();
      canvas.translate(2, 4.4);
      _leaf(canvas, length * .64, 4.6, rect);
      canvas.translate(length * .18, 2.2);
      _leaf(canvas, length * .38, 3.8, rect);
      canvas.restore();
    }
  }

  /// Draws a different arrangement for each role, inside an 11px edge rail.
  void paintOrnaments(Canvas canvas, Size size) {
    if (size.width < 52 || size.height < 28) return;
    final rect = Offset.zero & size;
    final small = kind == LapiFrameKind.button;
    final field = kind == LapiFrameKind.field;
    final tall = size.height > 160 && !small && !field;
    final length = small
        ? 19.0
        : field
            ? 26.0
            : tall
                ? 44.0
                : 32.0;

    if (!field) {
      canvas.save();
      // Horizontal and vertical motifs meet the border tangentially.
      canvas.translate(size.width - radius - 2, 1.2);
      canvas.scale(-1, 1);
      _scroll(canvas, rect, length: length, leaf: !small);
      canvas.restore();
    }
    if (!small) {
      canvas.save();
      canvas.translate(1.2, size.height - radius - 2);
      canvas.rotate(-1.5707963267948966);
      _scroll(canvas, rect,
          length: field
              ? 19
              : tall
                  ? 39
                  : 26);
      canvas.restore();
    }
    if (field) {
      canvas.save();
      canvas.translate(size.width - 1.2, radius + 3);
      canvas.rotate(1.5707963267948966);
      _scroll(canvas, rect, length: 19, leaf: false);
      canvas.restore();
    }
    if (tall || kind == LapiFrameKind.panel) {
      canvas.save();
      canvas.translate(size.width - 1.2, radius + 3);
      canvas.rotate(1.5707963267948966);
      _scroll(canvas, rect, length: 31);
      canvas.restore();
      canvas.save();
      canvas.translate(radius + 3, size.height - 1.2);
      _scroll(canvas, rect, length: 38);
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 2 || size.height <= 2) return;
    final rect = Offset.zero & size;
    final effectiveRadius = radius.clamp(0, size.shortestSide / 2).toDouble();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.deflate(.75), Radius.circular(effectiveRadius)),
      _metal(rect, width: 1.15),
    );
    paintOrnaments(canvas, size);
  }

  @override
  bool shouldRepaint(covariant PremiumGoldFramePainter oldDelegate) =>
      radius != oldDelegate.radius ||
      kind != oldDelegate.kind ||
      ornamentLevel != oldDelegate.ornamentLevel;
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
          foregroundPainter:
              PremiumGoldFramePainter(radius: radius, kind: kind),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: kind == LapiFrameKind.card || kind == LapiFrameKind.panel
                ? Padding(padding: const EdgeInsets.all(4), child: child)
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
    super.paint(canvas, rect,
        gapStart: gapStart,
        gapExtent: gapExtent,
        gapPercentage: gapPercentage,
        textDirection: textDirection);
    canvas.save();
    canvas.translate(rect.left, rect.top);
    const PremiumGoldFramePainter(radius: 13, kind: LapiFrameKind.field)
        .paintOrnaments(canvas, rect.size);
    canvas.restore();
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
    const PremiumGoldFramePainter(radius: 13, kind: LapiFrameKind.button)
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            labelStyle: TextStyle(
                fontFamily: 'LapiText',
                color: selected ? warmGoldText : lapiGreenDark,
                fontSize: 13,
                fontWeight: FontWeight.w700),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}
