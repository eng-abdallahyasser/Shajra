import 'package:flutter/material.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';

/// A data-driven map widget that renders the actual zones and trees
/// from a [GreenhouseEntity].
class GreenhouseDetailMap extends StatelessWidget {
  final GreenhouseEntity greenhouse;

  const GreenhouseDetailMap({super.key, required this.greenhouse});

  /// Scale factor matching the create wizard: 1 meter = 15 pixels.
  static const double metersToPixels = 15.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final floorW = (greenhouse.width * metersToPixels).clamp(200, 3000);
    final floorH = (greenhouse.length * metersToPixels).clamp(150, 3000);
    final aspect = floorW / floorH;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Greenhouse Layout',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 24 / 18,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Map card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: layout map title + legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 13.5,
                          height: 13.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LAYOUT MAP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 16 / 12,
                            letterSpacing: 0.6,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LegendDot(color: cs.primary, label: 'Healthy'),
                        const SizedBox(width: 12),
                        const _LegendDot(color: Color(0xFFF97316), label: 'Warning'),
                        const SizedBox(width: 12),
                        const _LegendDot(color: Color(0xFFBA1A1A), label: 'Critical'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Map canvas
                AspectRatio(
                  aspectRatio: aspect,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasW = constraints.maxWidth;
                      final canvasH = constraints.maxHeight;
                      final scaleX = canvasW / floorW;
                      final scaleY = canvasH / floorH;

                      return Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          border: Border.all(color: cs.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // Grid dot pattern
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _GridDotPainter(
                                  color: cs.primary.withValues(alpha: 0.1),
                                ),
                              ),
                            ),

                            // Render zones
                            ...greenhouse.zonesData.map((zone) {
                              final left = (double.parse(zone['left'] as String) * metersToPixels * scaleX).clamp(0, canvasW - 10).toDouble();
                              final top = (double.parse(zone['top'] as String) * metersToPixels * scaleY).clamp(0, canvasH - 10).toDouble();
                              final zW = (double.parse(zone['width'] as String) * metersToPixels * scaleX).clamp(10, canvasW).toDouble();
                              final zH = (double.parse(zone['height'] as String) * metersToPixels * scaleY).clamp(10, canvasH).toDouble();
                              final label = zone['name'] as String? ?? 'Zone';

                              return Positioned(
                                left: left,
                                top: top,
                                child: Container(
                                  width: zW,
                                  height: zH,
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: cs.primary.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                      height: 13 / 9,
                                      letterSpacing: 0.5,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Render trees
                            ...greenhouse.treesData.asMap().entries.map((entry) {
                              final i = entry.key;
                              final tree = entry.value;
                              final x = (double.parse(tree['x'] as String) * metersToPixels * scaleX).clamp(0, canvasW);
                              final y = (double.parse(tree['y'] as String) * metersToPixels * scaleY).clamp(0, canvasH);
                              // Alternate colors based on index for visual variety
                              final isHealthy = i % 3 != 1;
                              final markerColor = isHealthy ? cs.primary : cs.error;

                              return Positioned(
                                left: x - 12,
                                top: y - 12,
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: markerColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: markerColor.withValues(alpha: 0.2),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.eco, size: 11, color: Colors.white),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            // Dimensions label at bottom
                            Positioned(
                              bottom: 6,
                              right: 8,
                              child: Text(
                                '${greenhouse.width} × ${greenhouse.length} m',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 9,
                                  color: cs.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single legend dot with label
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 15 / 10,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Paints a dotted grid overlay on the map canvas
class _GridDotPainter extends CustomPainter {
  final Color color;

  _GridDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    const dotRadius = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
