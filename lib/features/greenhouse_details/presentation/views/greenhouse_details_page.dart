import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/routes/app_routes.dart';
import '../controllers/greenhouse_details_controller.dart';
import '../widgets/greenhouse_detail_map.dart';

class GreenhouseDetailsPage extends StatelessWidget {
  const GreenhouseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GreenhouseDetailsController>();
    final greenhouse = controller.greenhouse;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          greenhouse.name.isNotEmpty ? greenhouse.name : 'Greenhouse Details',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Overall Status ──
              _OverallStatusCard(cs: cs),
              const SizedBox(height: 24),

              // ── 2. Environmental Grid ──
              _EnvironmentalGrid(cs: cs),
              const SizedBox(height: 24),

              // ── 3. Greenhouse Map ──
              GreenhouseDetailMap(greenhouse: greenhouse),
              const SizedBox(height: 24),

              // ── 4. Active Zones ──
              _ActiveZonesSection(cs: cs),
              const SizedBox(height: 24),

              // ── 5. Tree Data ──
              _TreeDataSection(greenhouse: greenhouse, cs: cs),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  1. Overall Status
// ═══════════════════════════════════════════════

class _OverallStatusCard extends StatelessWidget {
  final ColorScheme cs;

  const _OverallStatusCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'OVERALL STATUS',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
              color: cs.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '28',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 64,
                    height: 80 / 64,
                    color: cs.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 39),
                  child: Text(
                    '°C',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.24,
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.2),
              border: Border.all(color: cs.onPrimary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              'Normal',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: cs.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  2. Environmental Grid
// ═══════════════════════════════════════════════

class _EnvironmentalGrid extends StatelessWidget {
  final ColorScheme cs;

  const _EnvironmentalGrid({required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 228,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _EnvTile(
                    cs: cs,
                    svgPath: 'assets/icons/humidity.svg',
                    label: 'HUMIDITY',
                    value: '65%',
                    badgeLabel: 'Good',
                    badgeColor: cs.primary,
                    badgeBg: cs.primary.withValues(alpha: 0.15),
                    statusColor: cs.primary,
                    iconColor: cs.primary,
                  ),
                ),
                const SizedBox(height: 0),
                Expanded(
                  child: _EnvTile(
                    cs: cs,
                    svgPath: 'assets/icons/light lever.svg',
                    label: 'LIGHT LEVEL',
                    value: '8k lux',
                    badgeLabel: 'Good',
                    badgeColor: cs.primary,
                    badgeBg: cs.primary.withValues(alpha: 0.15),
                    statusColor: cs.onSurface,
                    iconColor: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 0),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _EnvTile(
                    cs: cs,
                    svgPath: 'assets/icons/soil moisture.svg',
                    label: 'SOIL MOISTURE',
                    value: '42%',
                    badgeLabel: 'Low',
                    badgeColor: cs.error,
                    badgeBg: cs.error.withValues(alpha: 0.15),
                    statusColor: cs.onSurface,
                    iconColor: cs.error,
                  ),
                ),
                const SizedBox(height: 0),
                Expanded(
                  child: _EnvTile(
                    cs: cs,
                    svgPath: 'assets/icons/co2.svg',
                    label: 'CO2 LEVEL',
                    value: '400 ppm',
                    badgeLabel: 'Good',
                    badgeColor: cs.primary,
                    badgeBg: cs.primary.withValues(alpha: 0.15),
                    statusColor: cs.onSurface,
                    iconColor: cs.primary,
                    valueTop: true,
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

class _EnvTile extends StatelessWidget {
  final String svgPath;
  final String label;
  final String value;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final Color statusColor;
  final Color iconColor;
  final bool valueTop;
  final ColorScheme cs;

  const _EnvTile({
    required this.cs,
    required this.svgPath,
    required this.label,
    required this.value,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    required this.statusColor,
    required this.iconColor,
    this.valueTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                svgPath,
                width: valueTop ? 22 : 16,
                height: valueTop ? 22 : 20,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.6,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: cs.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              height: 24 / 18,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  3. (Greenhouse Map handled by GreenhouseDetailMap widget)
// ═══════════════════════════════════════════════

// ═══════════════════════════════════════════════
//  4. Active Zones
// ═══════════════════════════════════════════════

class _ActiveZonesSection extends StatelessWidget {
  final ColorScheme cs;

  const _ActiveZonesSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GreenhouseDetailsController>();
    final zones = controller.greenhouse.zonesData;
    final trees = controller.greenhouse.treesData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Zones',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: cs.onSurface,
              ),
            ),
            if (zones.isNotEmpty)
              Text(
                '${zones.length} total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: cs.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (zones.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No zones defined',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 128,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: zones.map((z) {
                final treeCount = trees.where((t) => t.zoneId == z.id).length;
                // Alternate status for visual variety
                final idx = zones.indexOf(z);
                final isHealthy = idx % 3 != 1;
                final statusColor = isHealthy ? cs.primary : cs.error;
                final statusLabel = isHealthy ? 'Healthy' : 'Warning';

                return Padding(
                  padding: EdgeInsets.only(right: zones.last == z ? 0 : 16),
                  child: _ZoneCard(
                    cs: cs,
                    name: z.name,
                    zoneId: z.id,
                    status: statusLabel,
                    statusColor: statusColor,
                    treeCount: treeCount,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String name;
  final String zoneId;
  final String status;
  final Color statusColor;
  final int treeCount;
  final ColorScheme cs;

  const _ZoneCard({
    required this.cs,
    required this.name,
    required this.zoneId,
    required this.status,
    required this.statusColor,
    required this.treeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GreenhouseDetailMap.showZoneProfile(context, zoneId, name, treeCount),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.8),
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 24 / 16,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      height: 15 / 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ZoneMetricLabel(label: 'Trees', value: '$treeCount'),
                const SizedBox(width: 24),
                _ZoneMetricLabel(label: 'Tag', value: zoneId),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneMetricLabel extends StatelessWidget {
  final String label;
  final String value;

  const _ZoneMetricLabel({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.3,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  5. Tree Data
// ═══════════════════════════════════════════════

class _TreeDataSection extends StatelessWidget {
  final GreenhouseEntity greenhouse;
  final ColorScheme cs;

  const _TreeDataSection({
    required this.greenhouse,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final trees = greenhouse.treesData;
    final zones = greenhouse.zonesData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trees',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: cs.onSurface,
              ),
            ),
            if (trees.isNotEmpty)
              Text(
                '${trees.length} total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: cs.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (trees.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.8),
              border: Border.all(color: cs.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.eco,
                  size: 48,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No trees in this greenhouse',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          ...trees.asMap().entries.map((entry) {
            final i = entry.key;
            final tree = entry.value;

            // Find zone name
            String zoneName = 'Not assigned';
            if (tree.zoneId != null) {
              final zone = zones.firstWhereOrNull((z) => z.id == tree.zoneId);
              if (zone != null) zoneName = zone.name;
            }

            final isHealthy = i % 3 != 1;
            final statusColor = isHealthy ? cs.primary : cs.error;
            final statusLabel = isHealthy ? 'Healthy' : 'Warning';

            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.treeDetails, arguments: {
                'tree': tree,
                'greenhouse': greenhouse,
              }),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.8),
                    border: Border.all(color: cs.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Tree icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.eco,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Tree info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tree.id,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                height: 24 / 16,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _TreeDetailChip(
                                  cs: cs,
                                  icon: Icons.my_location,
                                  label: '(${tree.x}, ${tree.y}) m',
                                ),
                                const SizedBox(width: 16),
                                _TreeDetailChip(
                                  cs: cs,
                                  icon: Icons.view_in_ar,
                                  label: zoneName,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            );
          }),
      ],
    );
  }
}

class _TreeDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _TreeDetailChip({
    required this.cs,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.outline),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: cs.outline,
          ),
        ),
      ],
    );
  }
}
