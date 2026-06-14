import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 106),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero: Overall Status ──
                _OverallStatusCard(cs: cs),
                const SizedBox(height: 24),

                // ── Environmental Grid ──
                _EnvironmentalGrid(cs: cs),
                const SizedBox(height: 24),

                // ── System Controls ──
                _SystemControls(cs: cs),
                const SizedBox(height: 24),

                // ── Active Zones ──
                _ActiveZonesSection(cs: cs),
                const SizedBox(height: 24),

                // ── Saved Greenhouses ──
                _SavedGreenhousesSection(
                  greenhouses: controller.greenhouses,
                  isLoading: controller.isLoading.value,
                  cs: cs,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed(AppRoutes.addGreenhouse);
          controller.loadGreenhouses();
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Greenhouse',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  1. Hero Section: Overall Status
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
          // OVERALL STATUS label
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

          // Temperature display
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

          // Status chip
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
//  2. Environmental Grid (2×2)
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
          // Left column
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

          // Right column
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
          // SVG Icon + Badge row
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

          // Label
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: cs.onSurfaceVariant,
            ),
          ),

          // Value
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
//  3. System Controls
// ═══════════════════════════════════════════════

class _SystemControls extends StatelessWidget {
  final ColorScheme cs;

  const _SystemControls({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Controls',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 24 / 18,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ControlPill(
                cs: cs,
                label: 'Irrigation',
                svgPath: 'assets/icons/irrigation.svg',
                isActive: true,
              ),
              const SizedBox(width: 8),
              _ControlPill(
                cs: cs,
                label: 'Lighting',
                svgPath: 'assets/icons/lights.svg',
              ),
              const SizedBox(width: 8),
              _ControlPill(
                cs: cs,
                label: 'Ventilation',
                svgPath: 'assets/icons/wind.svg',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlPill extends StatelessWidget {
  final String label;
  final String svgPath;
  final bool isActive;
  final ColorScheme cs;

  const _ControlPill({
    required this.cs,
    required this.label,
    required this.svgPath,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? cs.primary : cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(
              isActive ? cs.onPrimary : cs.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  4. Active Zones
// ═══════════════════════════════════════════════

class _ActiveZonesSection extends StatelessWidget {
  final ColorScheme cs;

  const _ActiveZonesSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Zone cards - horizontal scroll
        SizedBox(
          height: 128,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ZoneCard(
                cs: cs,
                name: 'Zone A',
                status: 'Healthy',
                statusColor: cs.primary,
                humidity: '65%',
                temp: '24°C',
                progress: 0.88,
              ),
              const SizedBox(width: 16),
              _ZoneCard(
                cs: cs,
                name: 'Zone B',
                status: 'Critical',
                statusColor: cs.error,
                humidity: '42%',
                temp: '31°C',
                progress: 0.34,
              ),
              const SizedBox(width: 16),
              _ZoneCard(
                cs: cs,
                name: 'Zone C',
                status: 'Warning',
                statusColor: cs.error.withValues(alpha: 0.7),
                humidity: '51%',
                temp: '27°C',
                progress: 0.55,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String humidity;
  final String temp;
  final double progress;
  final ColorScheme cs;

  const _ZoneCard({
    required this.cs,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.humidity,
    required this.temp,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
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
          // Name + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 24 / 16,
                  color: cs.onSurface,
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

          // Metrics row
          Row(
            children: [
              _MetricLabel(label: 'Humidity', value: humidity),
              const SizedBox(width: 40),
              _MetricLabel(label: 'Temp', value: temp),
            ],
          ),
          const SizedBox(height: 4),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: SizedBox(
              width: double.infinity,
              height: 8,
              child: Stack(
                children: [
                  Container(color: cs.surfaceContainerLow),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(color: statusColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  final String label;
  final String value;

  const _MetricLabel({
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
            fontSize: 12,
            letterSpacing: 0.6,
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  5. Saved Greenhouses
// ═══════════════════════════════════════════════

class _SavedGreenhousesSection extends StatelessWidget {
  final List<GreenhouseEntity> greenhouses;
  final bool isLoading;
  final ColorScheme cs;

  const _SavedGreenhousesSection({
    required this.greenhouses,
    required this.isLoading,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Greenhouses',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: cs.onSurface,
              ),
            ),
            if (greenhouses.isNotEmpty)
              Text(
                '${greenhouses.length} total',
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

        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: cs.primary),
            ),
          )
        else if (greenhouses.isEmpty)
          const _EmptyGreenhouses()
        else
          ...greenhouses.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GreenhouseCard(greenhouse: g, cs: cs),
              )),
      ],
    );
  }
}

class _EmptyGreenhouses extends StatelessWidget {
  const _EmptyGreenhouses();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
            Icons.grass,
            size: 48,
            color: cs.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No greenhouses yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to create your first greenhouse',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenhouseCard extends StatelessWidget {
  final GreenhouseEntity greenhouse;
  final ColorScheme cs;

  const _GreenhouseCard({required this.greenhouse, required this.cs});

  @override
  Widget build(BuildContext context) {
    final zoneCount = greenhouse.zonesData.length;
    final treeCount = greenhouse.treesData.length;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.greenhouseDetails, arguments: greenhouse),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + facility type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    greenhouse.name.isNotEmpty ? greenhouse.name : 'Unnamed Greenhouse',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 24 / 16,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (greenhouse.facilityType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    greenhouse.facilityType.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Dimensions row
          Row(
            children: [
              _InfoChip(
                cs: cs,
                icon: Icons.straighten,
                label: '${greenhouse.width} × ${greenhouse.height} m',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                cs: cs,
                icon: Icons.view_in_ar,
                label: '$zoneCount zone${zoneCount == 1 ? '' : 's'}',
              ),
              if (treeCount > 0) ...[
                const SizedBox(width: 16),
                _InfoChip(
                  cs: cs,
                  icon: Icons.eco,
                  label: '$treeCount tree${treeCount == 1 ? '' : 's'}',
                ),
              ],
            ],
          ),

          // Bottom row: sensor info + view button
          if (greenhouse.sensorType != null || greenhouse.solarOrientation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (greenhouse.sensorType != null)
                  _InfoChip(
                    cs: cs,
                    icon: Icons.sensors,
                    label: '${greenhouse.sensorCount ?? 1} × ${greenhouse.sensorType}',
                  ),
                if (greenhouse.solarOrientation.isNotEmpty)
                  _InfoChip(
                    cs: cs,
                    icon: Icons.wb_sunny_outlined,
                    label: greenhouse.solarOrientation,
                  ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: cs.outline,
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _InfoChip({
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
