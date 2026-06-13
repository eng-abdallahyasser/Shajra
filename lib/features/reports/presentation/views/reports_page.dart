import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController(), permanent: true);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Obx(
          () {
            // Loading state
            if (controller.isLoading.value &&
                controller.farmReport.value == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Empty state
            if (controller.farmReport.value == null ||
                (controller.farmReport.value!.totalGreenhouses == 0 &&
                    controller.farmReport.value!.totalTasks == 0)) {
              return _EmptyState(cs: cs);
            }

            return RefreshIndicator(
              onRefresh: controller.loadReports,
              child: CustomScrollView(
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(
                    child: _HeaderSection(
                      isLoading: controller.isLoading.value,
                      cs: cs,
                    ),
                  ),

                  // ── Summary Cards ──
                  if (controller.farmReport.value != null)
                    SliverToBoxAdapter(
                      child: _SummaryCards(
                        report: controller.farmReport.value!,
                        cs: cs,
                      ),
                    ),

                  // ── Period Filter ──
                  SliverToBoxAdapter(
                    child: _PeriodFilter(
                      controller: controller,
                      cs: cs,
                    ),
                  ),

                  // ── Content sections ──
                  if (controller.farmReport.value != null) ...[
                    // Environmental overview
                    SliverToBoxAdapter(
                      child: _EnvironmentalOverview(
                        controller: controller,
                        cs: cs,
                      ),
                    ),

                    // Task completion
                    SliverToBoxAdapter(
                      child: _TaskProgress(
                        report: controller.farmReport.value!,
                        cs: cs,
                      ),
                    ),

                    // Greenhouse breakdown
                    SliverToBoxAdapter(
                      child: _GreenhouseBreakdownHeader(cs: cs),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final gh =
                              controller.farmReport.value!.greenhouseReports[
                                  index];
                          return _GreenhouseReportCard(
                            report: gh,
                            cs: cs,
                          );
                        },
                        childCount: controller
                            .farmReport.value!.greenhouseReports.length,
                      ),
                    ),
                  ],

                  // ── Bottom padding ──
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Header Section
// ═══════════════════════════════════════════════

class _HeaderSection extends StatelessWidget {
  final bool isLoading;
  final ColorScheme cs;

  const _HeaderSection({required this.isLoading, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reports',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    height: 34 / 28,
                    color: cs.onSurface,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Farm analytics & performance overview',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Summary Cards
// ═══════════════════════════════════════════════

class _SummaryCards extends StatelessWidget {
  final FarmReport report;
  final ColorScheme cs;

  const _SummaryCards({required this.report, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Greenhouses',
                  value: '${report.totalGreenhouses}',
                  icon: Icons.home_work_outlined,
                  color: cs.primary,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Zones',
                  value: '${report.totalZones}',
                  icon: Icons.grid_view_outlined,
                  color: cs.tertiary,
                  cs: cs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Tasks',
                  value: '${report.totalTasks}',
                  icon: Icons.checklist_outlined,
                  color: cs.secondary,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Completed',
                  value: '${(report.completionRate * 100).round()}%',
                  icon: Icons.trending_up_rounded,
                  color: report.completionRate > 0.6
                      ? cs.primary
                      : cs.error,
                  cs: cs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme cs;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
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

// ═══════════════════════════════════════════════
//  Period Filter
// ═══════════════════════════════════════════════

class _PeriodFilter extends StatelessWidget {
  final ReportsController controller;
  final ColorScheme cs;

  const _PeriodFilter({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Obx(
        () => Row(
          children: [
            _PeriodChip(
              label: '7 days',
              isActive: controller.reportPeriod.value == ReportPeriod.week,
              cs: cs,
              onTap: () => controller.setPeriod(ReportPeriod.week),
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: '30 days',
              isActive: controller.reportPeriod.value == ReportPeriod.month,
              cs: cs,
              onTap: () => controller.setPeriod(ReportPeriod.month),
            ),
            const SizedBox(width: 8),
            _PeriodChip(
              label: '90 days',
              isActive: controller.reportPeriod.value == ReportPeriod.quarter,
              cs: cs,
              onTap: () => controller.setPeriod(ReportPeriod.quarter),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isActive,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Environmental Overview
// ═══════════════════════════════════════════════

class _EnvironmentalOverview extends StatelessWidget {
  final ReportsController controller;
  final ColorScheme cs;

  const _EnvironmentalOverview({
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final report = controller.farmReport.value!;

    // Aggregate environmental data across all greenhouses
    final avgTemp = report.greenhouseReports.isEmpty
        ? 0.0
        : report.greenhouseReports.fold(0.0, (s, g) => s + g.avgTemperature) /
            report.greenhouseReports.length;

    final avgHum = report.greenhouseReports.isEmpty
        ? 0.0
        : report.greenhouseReports.fold(0.0, (s, g) => s + g.avgHumidity) /
            report.greenhouseReports.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 18, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                'Environmental Overview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Environmental metrics row
          Row(
            children: [
              Expanded(
                child: _EnvMetricCard(
                  label: 'Avg Temperature',
                  value: '${avgTemp.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat,
                  color: avgTemp > 28 ? cs.error : cs.primary,
                  cs: cs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EnvMetricCard(
                  label: 'Avg Humidity',
                  value: '${avgHum.toStringAsFixed(0)}%',
                  icon: Icons.water_drop,
                  color: avgHum > 75 ? cs.error : cs.primary,
                  cs: cs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Area summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.straighten,
                    size: 22,
                    color: cs.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${report.totalArea.toStringAsFixed(0)} m²',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Total Cultivation Area',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${report.totalTrees} trees',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
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

class _EnvMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ColorScheme cs;

  const _EnvMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
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

// ═══════════════════════════════════════════════
//  Task Progress
// ═══════════════════════════════════════════════

class _TaskProgress extends StatelessWidget {
  final FarmReport report;
  final ColorScheme cs;

  const _TaskProgress({required this.report, required this.cs});

  @override
  Widget build(BuildContext context) {
    final completionPct = report.completionRate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 18, color: cs.onSurface),
              const SizedBox(width: 8),
              Text(
                'Task Completion',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TaskStat(
                      value: '${report.totalTasks}',
                      label: 'Total',
                      color: cs.onSurface,
                      cs: cs,
                    ),
                    _TaskStat(
                      value: '${report.completedTasks}',
                      label: 'Done',
                      color: cs.primary,
                      cs: cs,
                    ),
                    _TaskStat(
                      value: '${report.pendingTasks}',
                      label: 'Pending',
                      color: cs.error,
                      cs: cs,
                    ),
                    _TaskStat(
                      value: '${(completionPct * 100).round()}%',
                      label: 'Rate',
                      color: cs.secondary,
                      cs: cs,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: SizedBox(
                    width: double.infinity,
                    height: 10,
                    child: Stack(
                      children: [
                        // Background
                        Container(color: cs.surfaceContainerLow),
                        // Completed portion
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: completionPct.clamp(0, 1),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cs.primary.withValues(alpha: 0.7),
                                  cs.primary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Legend row
                Row(
                  children: [
                    _LegendDot(color: cs.primary, label: 'Completed', cs: cs),
                    const SizedBox(width: 16),
                    _LegendDot(
                      color: cs.surfaceContainerLow,
                      label: 'Pending',
                      cs: cs,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final ColorScheme cs;

  const _TaskStat({
    required this.value,
    required this.label,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final ColorScheme cs;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Greenhouse Breakdown
// ═══════════════════════════════════════════════

class _GreenhouseBreakdownHeader extends StatelessWidget {
  final ColorScheme cs;

  const _GreenhouseBreakdownHeader({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(Icons.home_work_outlined, size: 18, color: cs.onSurface),
          const SizedBox(width: 8),
          Text(
            'Greenhouse Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenhouseReportCard extends StatelessWidget {
  final GreenhouseReport report;
  final ColorScheme cs;

  const _GreenhouseReportCard({required this.report, required this.cs});

  @override
  Widget build(BuildContext context) {
    final completionPct = report.completionRate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.facilityType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics row
            Row(
              children: [
                _GhMetric(
                  icon: Icons.grid_view_outlined,
                  value: '${report.zoneCount}',
                  label: 'Zones',
                  cs: cs,
                ),
                const SizedBox(width: 16),
                _GhMetric(
                  icon: Icons.eco_outlined,
                  value: '${report.treeCount}',
                  label: 'Trees',
                  cs: cs,
                ),
                const SizedBox(width: 16),
                _GhMetric(
                  icon: Icons.straighten,
                  value: report.area.toStringAsFixed(0),
                  label: 'm²',
                  cs: cs,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Temperature + Humidity + Task progress
            Row(
              children: [
                // Temperature
                _EnvBadge(
                  icon: Icons.thermostat,
                  value: '${report.avgTemperature.toStringAsFixed(1)}°C',
                  color: report.avgTemperature > 28
                      ? cs.error
                      : cs.primary,
                  cs: cs,
                ),
                const SizedBox(width: 8),
                // Humidity
                _EnvBadge(
                  icon: Icons.water_drop,
                  value: '${report.avgHumidity.toStringAsFixed(0)}%',
                  color: report.avgHumidity > 75 ? cs.error : cs.primary,
                  cs: cs,
                ),
                const Spacer(),
                // Task completion dot
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: completionPct > 0.6
                        ? cs.primaryContainer
                        : cs.errorContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: completionPct > 0.6
                            ? cs.primary
                            : cs.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${report.completedTaskCount}/${report.taskCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: completionPct > 0.6
                              ? cs.primary
                              : cs.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GhMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme cs;

  const _GhMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EnvBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final ColorScheme cs;

  const _EnvBadge({
    required this.icon,
    required this.value,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Empty State
// ═══════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;

  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No data yet',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add greenhouses and tasks\nto see your farm reports',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
