import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/greenhouse_entity.dart';
import 'package:shajra/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 106),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero: Overall Status ──
                const _OverallStatusCard(),
                const SizedBox(height: 24),

                // ── Environmental Grid ──
                const _EnvironmentalGrid(),
                const SizedBox(height: 24),

                // ── System Controls ──
                const _SystemControls(),
                const SizedBox(height: 24),

                // ── Active Zones ──
                const _ActiveZonesSection(),
                const SizedBox(height: 24),

                // ── Saved Greenhouses ──
                _SavedGreenhousesSection(
                  greenhouses: controller.greenhouses,
                  isLoading: controller.isLoading.value,
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
        backgroundColor: const Color(0xFF00450D),
        foregroundColor: Colors.white,
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
  const _OverallStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(27, 94, 32, 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // OVERALL STATUS label
          const Text(
            'OVERALL STATUS',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
              color: Color.fromRGBO(144, 214, 137, 0.8),
            ),
          ),
          const SizedBox(height: 8),

          // Temperature display
          const SizedBox(
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
                    color: Color(0xFF90D689),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 39),
                  child: Text(
                    '°C',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 32 / 24,
                      letterSpacing: -0.24,
                      color: Color(0xFF90D689),
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
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Text(
              'Normal',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF90D689),
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
  const _EnvironmentalGrid();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 228,
      child: Row(
        children: [
          // Left column
          const Expanded(
            child: Column(
              children: [
                Expanded(child: _EnvTile(label: 'HUMIDITY', value: '65%', badgeLabel: 'Good', badgeColor: Color(0xFF00450D), badgeBg: Color.fromRGBO(172, 244, 164, 0.3), statusColor: Color(0xFF00450D), iconColor: Color(0xFF00450D))),
                SizedBox(height: 0),
                Expanded(child: _EnvTile(label: 'LIGHT LEVEL', value: '8k lux', badgeLabel: 'Good', badgeColor: Color(0xFF00450D), badgeBg: Color.fromRGBO(172, 244, 164, 0.3), statusColor: Color(0xFF171D14), iconColor: Color(0xFF00450D))),
              ],
            ),
          ),
          const SizedBox(width: 0),

          // Right column
          Expanded(
            child: Column(
              children: [
                const Expanded(
                  child: _EnvTile(label: 'SOIL MOISTURE', value: '42%', badgeLabel: 'Low', badgeColor: Color(0xFFBA1A1A), badgeBg: Color.fromRGBO(255, 218, 214, 0.5), statusColor: Color(0xFF171D14), iconColor: Color(0xFFBA1A1A)),
                ),
                const SizedBox(height: 0),
                Expanded(
                  child: _EnvTile(
                    label: 'CO2 LEVEL',
                    value: '400 ppm',
                    badgeLabel: 'Good',
                    badgeColor: const Color(0xFF00450D),
                    badgeBg: const Color.fromRGBO(172, 244, 164, 0.3),
                    statusColor: const Color(0xFF171D14),
                    iconColor: const Color(0xFF00450D),
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
  final String label;
  final String value;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final Color statusColor;
  final Color iconColor;
  final bool valueTop;

  const _EnvTile({
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
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFFE0E8D9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(27, 94, 32, 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: valueTop ? 22 : 16,
                height: valueTop ? 22 : 20,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: Color(0xFF41493E),
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
  const _SystemControls();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Controls',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            height: 24 / 18,
            color: Color(0xFF171D14),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _ControlPill(label: 'Irrigation', icon: Icons.water_drop, isActive: true),
              SizedBox(width: 8),
              _ControlPill(label: 'Lighting', icon: Icons.light_mode_outlined),
              SizedBox(width: 8),
              _ControlPill(label: 'Ventilation', icon: Icons.air_outlined),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;

  const _ControlPill({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00450D) : const Color(0xFFE3EBDC),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isActive ? Colors.white : const Color(0xFF41493E),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: isActive ? Colors.white : const Color(0xFF41493E),
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
  const _ActiveZonesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Zones',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: Color(0xFF171D14),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF00450D),
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
                name: 'Zone A',
                status: 'Healthy',
                statusColor: const Color(0xFF1B5E20),
                humidity: '65%',
                temp: '24°C',
                progress: 0.88,
              ),
              const SizedBox(width: 16),
              _ZoneCard(
                name: 'Zone B',
                status: 'Critical',
                statusColor: const Color(0xFFBA1A1A),
                humidity: '42%',
                temp: '31°C',
                progress: 0.34,
              ),
              const SizedBox(width: 16),
              _ZoneCard(
                name: 'Zone C',
                status: 'Warning',
                statusColor: const Color(0xFFF97316),
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

  const _ZoneCard({
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
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFFE0E8D9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(27, 94, 32, 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 24 / 16,
                  color: Color(0xFF171D14),
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
                  Container(color: const Color(0xFFE9F0E1)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
            color: Color(0xFF41493E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.6,
            color: Color(0xFF41493E),
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

  const _SavedGreenhousesSection({
    required this.greenhouses,
    required this.isLoading,
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: Color(0xFF171D14),
              ),
            ),
            if (greenhouses.isNotEmpty)
              Text(
                '${greenhouses.length} total',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Color(0xFF717A6D),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (greenhouses.isEmpty)
          _EmptyGreenhouses()
        else
          ...greenhouses.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GreenhouseCard(greenhouse: g),
              )),
      ],
    );
  }
}

class _EmptyGreenhouses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFFE0E8D9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.grass,
            size: 48,
            color: const Color(0xFF90D689),
          ),
          const SizedBox(height: 12),
          const Text(
            'No greenhouses yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF41493E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap + to create your first greenhouse',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF717A6D),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenhouseCard extends StatelessWidget {
  final GreenhouseEntity greenhouse;

  const _GreenhouseCard({required this.greenhouse});

  @override
  Widget build(BuildContext context) {
    final zoneCount = greenhouse.zonesData.length;
    final treeCount = greenhouse.treesData.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFFE0E8D9)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(27, 94, 32, 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 24 / 16,
                    color: Color(0xFF171D14),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (greenhouse.facilityType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F0E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    greenhouse.facilityType.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: Color(0xFF41493E),
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
                icon: Icons.straighten,
                label: '${greenhouse.width} × ${greenhouse.length} m',
              ),
              const SizedBox(width: 16),
              _InfoChip(
                icon: Icons.view_in_ar,
                label: '$zoneCount zone${zoneCount == 1 ? '' : 's'}',
              ),
              if (treeCount > 0) ...[
                const SizedBox(width: 16),
                _InfoChip(
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
                    icon: Icons.sensors,
                    label: '${greenhouse.sensorCount ?? 1} × ${greenhouse.sensorType}',
                  ),
                if (greenhouse.solarOrientation.isNotEmpty)
                  _InfoChip(
                    icon: Icons.wb_sunny_outlined,
                    label: greenhouse.solarOrientation,
                  ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF717A6D),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF717A6D)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Color(0xFF717A6D),
          ),
        ),
      ],
    );
  }
}


