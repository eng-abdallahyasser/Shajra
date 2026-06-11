import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that displays a greenhouse zones map with tree markers, legend,
/// and interactive zone indicators.
class GreenhouseMapWidget extends StatelessWidget {
  const GreenhouseMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(),
          SizedBox(height: 16),
          _MapCard(),
        ],
      ),
    );
  }
}

/// "Greenhouse Zones" heading + subtitle
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Greenhouse Zones',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            height: 32 / 24,
            letterSpacing: -0.24,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 0),
        Text(
          'Real-time spatial mapping and vegetation status.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 24 / 16,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The card containing the layout map header, legend, and map canvas
class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MapHeader(),
          SizedBox(height: 16),
          _MapCanvas(),
        ],
      ),
    );
  }
}

/// Header row with LAYOUT MAP title and legend
class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _LayoutMapTitle(),
        const _LegendRow(),
      ],
    );
  }
}

/// "LAYOUT MAP" title with small icon
class _LayoutMapTitle extends StatelessWidget {
  const _LayoutMapTitle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
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
    );
  }
}

/// Legend dots row: Healthy, Warning, Critical
class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(color: cs.primary, label: 'Healthy'),
        const SizedBox(width: 12),
        const _LegendDot(color: Color(0xFFF97316), label: 'Warning'),
        const SizedBox(width: 12),
        const _LegendDot(color: Color(0xFFBA1A1A), label: 'Critical'),
      ],
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

/// The actual map canvas with zones, tree markers, and greenhouse structures
class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 324 / 243,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
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
                    painter: _GridDotPainter(color: cs.primary.withValues(alpha: 0.1)),
                  ),
                ),

                // Zone divider (dashed vertical line) + Zone A/B containers
                _ZoneDivider(w: w, h: h, cs: cs),

                // Zone A label
                Positioned(
                  left: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'ZONE A',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 15 / 10,
                        letterSpacing: 1,
                        color: cs.outline,
                      ),
                    ),
                  ),
                ),

                // Zone B label
                Positioned(
                  left: w * 0.5,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'ZONE B',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 15 / 10,
                        letterSpacing: 1,
                        color: cs.outline,
                      ),
                    ),
                  ),
                ),

                // --- Zone A Trees ---
                _TreeMarker(
                  left: w * 0.1522,
                  top: h * 0.2024,
                  color: cs.primary,
                  iconColor: cs.onPrimary,
                ),
                _TreeMarker(
                  left: w * 0.3012,
                  top: h * 0.4504,
                  color: cs.error,
                  iconColor: Colors.white,
                ),
                _TreeMarker(
                  left: w * 0.1024,
                  top: h * 0.6983,
                  color: cs.primary,
                  iconColor: cs.onPrimary,
                ),

                // --- Zone B Trees ---
                _TreeMarker(
                  left: w * 0.6744,
                  top: h * 0.1528,
                  color: const Color(0xFFBA1A1A),
                  iconColor: Colors.white,
                ),
                _TreeMarker(
                  left: w * 0.7738,
                  top: h * 0.5991,
                  color: cs.primary,
                  iconColor: cs.onPrimary,
                ),
                _TreeMarker(
                  left: w * 0.5253,
                  top: h * 0.6988,
                  color: cs.primary,
                  iconColor: cs.onPrimary,
                ),

                // Greenhouse structure at bottom center
                _GreenhouseStructure(w: w, cs: cs),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Dashed vertical line divider and zone containers
class _ZoneDivider extends StatelessWidget {
  final double w;
  final double h;
  final ColorScheme cs;

  const _ZoneDivider({required this.w, required this.h, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: w * 0.5,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 1,
        child: CustomPaint(
          painter: _DashedLinePainter(color: cs.outlineVariant),
        ),
      ),
    );
  }
}

/// Greenhouse structure at bottom center of map
class _GreenhouseStructure extends StatelessWidget {
  final double w;
  final ColorScheme cs;

  const _GreenhouseStructure({required this.w, required this.cs});

  @override
  Widget build(BuildContext context) {
    final structureWidth = w * 0.33;
    final structureLeft = w * 0.3395;
    return Positioned(
      left: structureLeft,
      bottom: 0,
      child: Container(
        width: structureWidth,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Text(
          'GREENHOUSE',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 8,
            height: 12 / 8,
            color: cs.outline,
          ),
        ),
      ),
    );
  }
}

/// A tree marker dot on the map
class _TreeMarker extends StatelessWidget {
  final double left;
  final double top;
  final Color color;
  final Color iconColor;

  const _TreeMarker({
    required this.left,
    required this.top,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
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
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.eco,
              size: 11,
              color: iconColor,
            ),
          ],
        ),
      ),
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

/// Paints a dashed vertical line
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, min(startY + dashWidth, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
