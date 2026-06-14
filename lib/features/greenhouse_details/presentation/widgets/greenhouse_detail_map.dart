import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/tree_data.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/zone_data.dart';

/// A data-driven map widget that renders the actual zones and trees
/// from a [GreenhouseEntity]. Tapping a tree or zone opens a profile bottom sheet.
class GreenhouseDetailMap extends StatelessWidget {
  final GreenhouseEntity greenhouse;

  const GreenhouseDetailMap({super.key, required this.greenhouse});

  /// Scale factor matching the create wizard: 1 meter = 15 pixels.
  static const double metersToPixels = 15.0;

  static void _showTreeProfile(BuildContext context, TreeData tree, List<ZoneData> zones) {
    final cs = Theme.of(context).colorScheme;

    // Find zone name from zoneId
    String zoneName = '—';
    if (tree.zoneId != null) {
      final zone = zones.firstWhereOrNull((z) => z.id == tree.zoneId);
      if (zone != null) zoneName = zone.name;
    }

    // Parse GH number from tree ID
    String ghNumber = '';
    if (tree.id.startsWith('G')) {
      final parts = tree.id.split('-');
      if (parts.isNotEmpty) {
        ghNumber = parts[0].substring(1);
      }
    }

    Get.bottomSheet(
      _ProfileSheetContent(
        icon: Icons.eco,
        iconColor: cs.primary,
        title: tree.id,
        subtitle: 'Tree Profile',
        cs: cs,
        rows: [
          _InfoRowData(icon: Icons.tag, label: 'Micro-Tag', value: tree.id),
          _InfoRowData(icon: Icons.qr_code, label: 'Greenhouse', value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '—'),
          _InfoRowData(icon: Icons.view_in_ar, label: 'Zone', value: tree.zoneId != null ? '$zoneName (${tree.zoneId})' : 'Not assigned'),
          _InfoRowData(icon: Icons.my_location, label: 'Position', value: '(${tree.x}, ${tree.y}) m'),
        ],
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  /// Convenience method to show a tree profile from a TreeData object.
  static void showTreeProfile(BuildContext context, TreeData tree, List<ZoneData> zones) {
    _showTreeProfile(context, tree, zones);
  }

  /// Convenience method to show a zone profile from a zone ID without the full ZoneData object.
  static void showZoneProfile(BuildContext context, String zoneId, String zoneName, int treeCount) {
    final cs = Theme.of(context).colorScheme;

    String ghNumber = '';
    if (zoneId.startsWith('G')) {
      final parts = zoneId.split('-');
      if (parts.isNotEmpty) {
        ghNumber = parts[0].substring(1);
      }
    }

    Get.bottomSheet(
      _ProfileSheetContent(
        icon: Icons.view_in_ar,
        iconColor: cs.primary,
        title: zoneName,
        subtitle: 'Zone Profile',
        cs: cs,
        rows: [
          _InfoRowData(icon: Icons.tag, label: 'Micro-Tag', value: zoneId),
          _InfoRowData(icon: Icons.qr_code, label: 'Greenhouse', value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '—'),
          _InfoRowData(icon: Icons.eco, label: 'Trees in Zone', value: '$treeCount'),
        ],
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  static void _showZoneProfile(BuildContext context, ZoneData zone, List<TreeData> trees) {
    final cs = Theme.of(context).colorScheme;

    // Count trees in this zone
    final treeCount = trees.where((t) => t.zoneId == zone.id).length;

    // Parse GH number
    String ghNumber = '';
    if (zone.id.startsWith('G')) {
      final parts = zone.id.split('-');
      if (parts.isNotEmpty) {
        ghNumber = parts[0].substring(1);
      }
    }

    Get.bottomSheet(
      _ProfileSheetContent(
        icon: Icons.view_in_ar,
        iconColor: cs.primary,
        title: zone.name,
        subtitle: 'Zone Profile',
        cs: cs,
        rows: [
          _InfoRowData(icon: Icons.tag, label: 'Micro-Tag', value: zone.id),
          _InfoRowData(icon: Icons.qr_code, label: 'Greenhouse', value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '—'),
          _InfoRowData(icon: Icons.eco, label: 'Trees in Zone', value: '$treeCount'),
          _InfoRowData(icon: Icons.straighten, label: 'Dimensions', value: '${zone.width}m × ${zone.height}m'),
          _InfoRowData(icon: Icons.my_location, label: 'Position', value: '(${zone.left}, ${zone.top}) m'),
        ],
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final floorW = (greenhouse.width * metersToPixels).clamp(200, 3000);
    final floorH = (greenhouse.height * metersToPixels).clamp(150, 3000);
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

                            // Render zones (tappable)
                            ...greenhouse.zonesData.map((zone) {
                              final left = (zone.left * metersToPixels * scaleX).clamp(0, canvasW - 10).toDouble();
                              final top = (zone.top * metersToPixels * scaleY).clamp(0, canvasH - 10).toDouble();
                              final zW = (zone.width * metersToPixels * scaleX).clamp(10, canvasW).toDouble();
                              final zH = (zone.height * metersToPixels * scaleY).clamp(10, canvasH).toDouble();

                              return Positioned(
                                left: left,
                                top: top,
                                child: GestureDetector(
                                  onTap: () => _showZoneProfile(context, zone, greenhouse.treesData),
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
                                      zone.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                        height: 13 / 9,
                                        letterSpacing: 0.5,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Render trees (tappable with Micro-Tagging labels)
                            ...greenhouse.treesData.asMap().entries.map((entry) {
                              final i = entry.key;
                              final tree = entry.value;
                              final x = (tree.x * metersToPixels * scaleX).clamp(0, canvasW);
                              final y = (tree.y * metersToPixels * scaleY).clamp(0, canvasH);
                              final isHealthy = i % 3 != 1;
                              final markerColor = isHealthy ? cs.primary : cs.error;

                              // Compact label from Micro-Tagging ID
                              final tagParts = tree.id.split('-');
                              final shortLabel = tagParts.length >= 3
                                  ? tagParts.sublist(tagParts.length - 3).join('-')
                                  : tree.id;

                              return Positioned(
                                left: x - 12,
                                top: y - 12 - 16,
                                child: GestureDetector(
                                  onTap: () => _showTreeProfile(context, tree, greenhouse.zonesData),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // ID label above the dot
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: markerColor.withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          shortLabel,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 7,
                                            height: 1.1,
                                            letterSpacing: 0.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SizedBox(
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
                                '${greenhouse.width} × ${greenhouse.height} m',
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

// ---------------------------------------------------------------------------
// Profile bottom sheet helpers
// ---------------------------------------------------------------------------

/// Data for a single info row in the profile sheet.
class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Reusable profile bottom sheet content.
class _ProfileSheetContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final ColorScheme cs;
  final List<_InfoRowData> rows;

  const _ProfileSheetContent({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.cs,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.3,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info rows
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProfileInfoRowWidget(cs: cs, data: row),
                )),
          ],
        ),
      ),
    );
  }
}

/// A single info row in a profile bottom sheet.
class _ProfileInfoRowWidget extends StatelessWidget {
  final ColorScheme cs;
  final _InfoRowData data;

  const _ProfileInfoRowWidget({required this.cs, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 20, color: cs.primary),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
            ],
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
