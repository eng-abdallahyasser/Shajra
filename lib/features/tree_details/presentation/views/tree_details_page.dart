import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajra/features/add_greenhouse/domain/entities/tree_data.dart';
import 'package:shajra/features/tasks/domain/entities/task_entity.dart';
import '../../domain/entities/scan_log_entity.dart';
import '../../domain/entities/tree_observation_data.dart';
import '../controllers/tree_details_controller.dart';

class TreeDetailsPage extends StatelessWidget {
  const TreeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TreeDetailsController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          controller.tree.id,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        actions: [
          Obx(
            () => controller.logs.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'tree_details_clear_logs'.tr,
                    onPressed: controller.clearAllLogs,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tree info card ──
              _TreeInfoCard(
                tree: controller.tree,
                zoneName: controller.zoneName,
                ghNumber: controller.ghNumber,
                cs: cs,
              ),
              const SizedBox(height: 24),

              // ── Latest scan result ──
              if (controller.latestScan != null)
                _LatestScanCard(
                  log: controller.latestScan!,
                  cs: cs,
                  onViewImage: () =>
                      controller.viewImage(controller.latestScan!.imagePath),
                ),
              if (controller.latestScan != null) const SizedBox(height: 24),

              // ── Model status ──
              _ModelStatusCard(
                isLoaded: controller.isModelLoaded.value,
                error: controller.modelError.value,
                cs: cs,
              ),
              const SizedBox(height: 24),

              // ── Scan History ──
              _ScanHistorySection(
                logs: controller.logs,
                cs: cs,
                onViewImage: controller.viewImage,
                onDelete: controller.deleteLog,
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════
              //  Tree Observations Section
              // ═══════════════════════════════════════════
              _ObservationsSection(controller: controller, cs: cs),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isScanning.value || !controller.isModelLoaded.value
              ? null
              : controller.scanLeaf,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          icon: controller.isScanning.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.camera_alt),
          label: Text(
            controller.isScanning.value
                ? 'tree_details_scanning'.tr
                : 'tree_details_scan_leaf'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  1. Tree Info Card
// ═══════════════════════════════════════════════

class _TreeInfoCard extends StatelessWidget {
  final TreeData tree;
  final String zoneName;
  final String ghNumber;
  final ColorScheme cs;

  const _TreeInfoCard({
    required this.tree,
    required this.zoneName,
    required this.ghNumber,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tree icon with Micro-Tag ID
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.eco, size: 28, color: cs.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tree.id,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.3,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'tree_details_micro_tagging'.tr,
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
          const SizedBox(height: 20),

          // Info grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  cs: cs,
                  icon: Icons.qr_code,
                  label: 'add_gh_greenhouse'.tr,
                  value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  cs: cs,
                  icon: Icons.view_in_ar,
                  label: 'add_gh_zone'.tr,
                  value: zoneName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  cs: cs,
                  icon: Icons.my_location,
                  label: 'add_gh_position'.tr,
                  value: '(${tree.x}, ${tree.y}) m',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  cs: cs,
                  icon: Icons.straighten,
                  label: 'tree_details_coordinates'.tr,
                  value: '(${tree.x}, ${tree.y}) m',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _InfoTile({
    required this.cs,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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

// ═══════════════════════════════════════════════
//  2. Latest Scan Result
// ═══════════════════════════════════════════════

class _LatestScanCard extends StatelessWidget {
  final ScanLogEntity log;
  final ColorScheme cs;
  final VoidCallback onViewImage;

  const _LatestScanCard({
    required this.log,
    required this.cs,
    required this.onViewImage,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = !log.isDiseased;
    final statusColor = isHealthy ? cs.primary : cs.error;
    final statusIcon =
        isHealthy ? Icons.check_circle : Icons.warning_amber_rounded;
    final statusLabel =
        isHealthy ? 'home_status_healthy'.tr : 'tree_details_disease_detected'.tr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tree_details_latest_scan'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Confidence badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${(log.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Severity bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: SizedBox(
              width: double.infinity,
              height: 8,
              child: Stack(
                children: [
                  Container(color: cs.surfaceContainerHighest),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        isHealthy ? 1.0 - log.confidence : log.confidence,
                    child: Container(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'home_status_healthy'.tr,
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
              Text(
                'tree_details_diseased'.tr,
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scan timestamp + view image
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: cs.outline),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(log.scannedAt),
                    style: TextStyle(fontSize: 12, color: cs.outline),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onViewImage,
                icon: const Icon(Icons.image_outlined, size: 16),
                label: Text('tree_details_view_image'.tr,
                    style: const TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'tree_details_just_now'.tr;
    if (diff.inMinutes < 60) {
      return 'tree_details_min_ago'.trParams({'count': diff.inMinutes.toString()});
    }
    if (diff.inHours < 24) {
      return 'tree_details_hour_ago'.trParams({'count': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'tree_details_day_ago'.trParams({'count': diff.inDays.toString()});
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ═══════════════════════════════════════════════
//  3. Model Status
// ═══════════════════════════════════════════════

class _ModelStatusCard extends StatelessWidget {
  final bool isLoaded;
  final String? error;
  final ColorScheme cs;

  const _ModelStatusCard({
    required this.isLoaded,
    required this.error,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isLoaded
        ? Icons.check_circle_outline
        : (error != null ? Icons.error_outline : Icons.hourglass_empty);
    final color =
        isLoaded ? cs.primary : (error != null ? cs.error : cs.outline);
    final label = isLoaded
        ? 'tree_details_model_ready'.tr
        : (error != null ? 'tree_details_model_error'.tr : 'tree_details_loading'.tr);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      error!,
                      style:
                          TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
//  4. Scan History
// ═══════════════════════════════════════════════

class _ScanHistorySection extends StatelessWidget {
  final List<ScanLogEntity> logs;
  final ColorScheme cs;
  final void Function(String) onViewImage;
  final void Function(ScanLogEntity) onDelete;

  const _ScanHistorySection({
    required this.logs,
    required this.cs,
    required this.onViewImage,
    required this.onDelete,
  });

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
              'tree_details_scan_history'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: cs.onSurface,
              ),
            ),
            if (logs.isNotEmpty)
              Text(
                logs.length == 1
                    ? 'tree_details_scan_count'.trParams(
                        {'count': logs.length.toString()})
                    : 'tree_details_scan_count_plural'.trParams(
                        {'count': logs.length.toString()}),
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

        if (logs.isEmpty)
          // Empty state
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
                Icon(Icons.search,
                    size: 48, color: cs.primary.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  'tree_details_no_scans'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'tree_details_no_scans_desc'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: cs.outline,
                  ),
                ),
              ],
            ),
          )
        else
          ...logs.map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScanLogCard(
                  log: log,
                  cs: cs,
                  onViewImage: () => onViewImage(log.imagePath),
                  onDelete: () => onDelete(log),
                ),
              )),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Scan Log Card
// ═══════════════════════════════════════════════

class _ScanLogCard extends StatelessWidget {
  final ScanLogEntity log;
  final ColorScheme cs;
  final VoidCallback onViewImage;
  final VoidCallback onDelete;

  const _ScanLogCard({
    required this.log,
    required this.cs,
    required this.onViewImage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isHealthy = !log.isDiseased;
    final statusColor = isHealthy ? cs.primary : cs.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
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
          // Status indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHealthy
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Log details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity label + confidence
                Row(
                  children: [
                    Text(
                      log.severityLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(log.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: cs.outline),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(log.scannedAt),
                      style: TextStyle(fontSize: 11, color: cs.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            onPressed: onViewImage,
            icon: Icon(Icons.image_outlined, size: 18, color: cs.primary),
            tooltip: 'tree_details_view_image_tooltip'.tr,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                size: 18, color: cs.error.withValues(alpha: 0.7)),
            tooltip: 'tree_details_delete_scan'.tr,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'tree_details_just_now'.tr;
    if (diff.inMinutes < 60) {
      return 'tree_details_min_ago'.trParams({'count': diff.inMinutes.toString()});
    }
    if (diff.inHours < 24) {
      return 'tree_details_hour_ago'.trParams({'count': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'tree_details_day_ago'.trParams({'count': diff.inDays.toString()});
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════
//  5. Observations Section — 5 expandable category cards
// ═══════════════════════════════════════════════════════════════

class _ObservationsSection extends StatelessWidget {
  final TreeDetailsController controller;
  final ColorScheme cs;

  const _ObservationsSection({
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.assignment, size: 20, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Tree Observations',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 24 / 18,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Record problems and corrective actions for this tree',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // 5 category cards
        ...TreeObservationData.all.map(
          (category) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ObservationCategoryCard(
              category: category,
              controller: controller,
              cs: cs,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Observation Category Card (expandable)
// ═══════════════════════════════════════════════════════════════

class _ObservationCategoryCard extends StatelessWidget {
  final ObservationCategory category;
  final TreeDetailsController controller;
  final ColorScheme cs;

  const _ObservationCategoryCard({
    required this.category,
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final count = controller.observationCountForCategory(category.key);
    final latest = controller.latestObservationForCategory(category.key);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card header (always visible, tappable to expand) ──
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => controller.toggleCategory(category.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(category.icon, size: 22, color: cs.primary),
                  ),
                  const SizedBox(width: 14),
                  // Category label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.labelAr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                        ),
                        if (latest != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${latest.selectedProblems.length} problems · '
                              '${latest.selectedActions.length} actions',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count badge
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Expand/collapse icon
                  Obx(() => AnimatedRotation(
                        turns: controller.expandedCategory.value ==
                                category.key
                            ? 0.5
                            : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Expanded content (checkboxes + save) ──
          Obx(() {
            if (controller.expandedCategory.value != category.key) {
              return const SizedBox.shrink();
            }
            return _CategoryExpandedContent(
              category: category,
              controller: controller,
              cs: cs,
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Expanded content with small selectable cards, image, and tasks
// ═══════════════════════════════════════════════════════════════

class _CategoryExpandedContent extends StatelessWidget {
  final ObservationCategory category;
  final TreeDetailsController controller;
  final ColorScheme cs;

  const _CategoryExpandedContent({
    required this.category,
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Section: Problems ──
          _SectionHeader(
            title: 'Problems (مش تمام)',
            count: controller.pendingProblems.length,
            color: cs.error,
            cs: cs,
          ),
          const SizedBox(height: 8),
          _SelectableCardGrid(
            items: category.problems,
            selectedItems: controller.pendingProblems,
            onToggle: (item) => controller.togglePendingProblem(item),
            selectedColor: cs.error,
            selectedBg: cs.errorContainer,
            defaultBg: cs.surfaceContainerLow,
            cs: cs,
          ),

          const SizedBox(height: 20),

          // ── Section: Corrective Actions ──
          _SectionHeader(
            title: 'Corrective Actions (الإجراءات التصحيحية)',
            count: controller.pendingActions.length,
            color: cs.primary,
            cs: cs,
          ),
          const SizedBox(height: 8),
          _SelectableCardGrid(
            items: category.correctiveActions,
            selectedItems: controller.pendingActions,
            onToggle: (item) => controller.togglePendingAction(item),
            selectedColor: cs.primary,
            selectedBg: cs.primaryContainer,
            defaultBg: cs.surfaceContainerLow,
            cs: cs,
          ),

          const SizedBox(height: 20),

          // ── Photo capture section ──
          _PhotoCaptureSection(
            controller: controller,
            cs: cs,
            requiresPhoto: category.requiresPhoto,
          ),
          const SizedBox(height: 16),

          // ── Notes field ──
          TextField(
            controller: controller.notesController,
            decoration: InputDecoration(
              hintText: 'Add notes (optional)',
              hintStyle: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              isDense: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.edit_note, size: 18, color: cs.outline),
              ),
            ),
            maxLines: 2,
            minLines: 1,
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),

          const SizedBox(height: 16),

          // ── Schedule Task section ──
          _ScheduleTaskSection(
            controller: controller,
            cs: cs,
          ),
          const SizedBox(height: 16),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => FilledButton.icon(
                onPressed: (controller.pendingProblems.isEmpty &&
                            controller.pendingActions.isEmpty) ||
                        controller.isSavingObs.value
                    ? null
                    : controller.saveObservation,
                icon: controller.isSavingObs.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  controller.isSavingObs.value
                      ? 'Saving...'
                      : 'Save Observation',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Section Header with count badge
// ═══════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final ColorScheme cs;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: color,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Selectable small cards in a wrapping grid
// ═══════════════════════════════════════════════

class _SelectableCardGrid extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final void Function(String) onToggle;
  final Color selectedColor;
  final Color selectedBg;
  final Color defaultBg;
  final ColorScheme cs;

  const _SelectableCardGrid({
    required this.items,
    required this.selectedItems,
    required this.onToggle,
    required this.selectedColor,
    required this.selectedBg,
    required this.defaultBg,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final isSelected = selectedItems.contains(item);
          return GestureDetector(
            onTap: () => onToggle(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : defaultBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? selectedColor.withValues(alpha: 0.5)
                      : cs.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? selectedColor : cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Photo Capture Section
// ═══════════════════════════════════════════════

class _PhotoCaptureSection extends StatelessWidget {
  final TreeDetailsController controller;
  final ColorScheme cs;
  final bool requiresPhoto;

  const _PhotoCaptureSection({
    required this.controller,
    required this.cs,
    required this.requiresPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final imagePath = controller.obsImagePath.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt_outlined,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: cs.onSurface,
                  ),
                ),
                if (requiresPhoto)
                  Text(
                    ' *',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: cs.error,
                    ),
                  ),
                const Spacer(),
                if (imagePath != null)
                  GestureDetector(
                    onTap: () => controller.clearObsImage(),
                    child: Icon(Icons.close, size: 16, color: cs.error),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (imagePath != null)
              // Show captured image thumbnail
              GestureDetector(
                onTap: () => controller.viewObsImage(imagePath),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: GestureDetector(
                        onTap: () => controller.clearObsImage(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              // Photo capture buttons
              Row(
                children: [
                  _PhotoButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () =>
                        controller.pickObservationImage(ImageSource.camera),
                    cs: cs,
                  ),
                  const SizedBox(width: 12),
                  _PhotoButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () =>
                        controller.pickObservationImage(ImageSource.gallery),
                    cs: cs,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Schedule Task Section
// ═══════════════════════════════════════════════

class _ScheduleTaskSection extends StatelessWidget {
  final TreeDetailsController controller;
  final ColorScheme cs;

  const _ScheduleTaskSection({
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isEnabled = controller.shouldScheduleTask.value;

        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              // Toggle header
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.toggleScheduleTask(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.checklist_outlined,
                        size: 18,
                        color: isEnabled ? cs.primary : cs.outline,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Schedule as Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isEnabled
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        onChanged: (_) => controller.toggleScheduleTask(),
                        activeTrackColor: cs.primary.withValues(alpha: 0.4),
                        activeThumbColor: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded details
              if (isEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      // Task title
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Task title (auto: ${controller.expandedCategory.value != null ? TreeObservationData.byKey(controller.expandedCategory.value!)?.labelAr ?? '' : ''})',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: cs.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: cs.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: cs.primary, width: 1.5),
                          ),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            controller.scheduleTaskTitle.value = v,
                        style:
                            TextStyle(fontSize: 13, color: cs.onSurface),
                      ),
                      const SizedBox(height: 12),
                      // Priority + Due date row
                      Row(
                        children: [
                          // Priority chips
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _PriorityChip(
                                      label: 'Low',
                                      isSelected: controller
                                              .scheduleTaskPriority
                                              .value ==
                                          TaskPriority.low,
                                      color: cs.onSurfaceVariant,
                                      onTap: () => controller
                                              .scheduleTaskPriority
                                              .value = TaskPriority.low,
                                    ),
                                    const SizedBox(width: 4),
                                    _PriorityChip(
                                      label: 'Med',
                                      isSelected: controller
                                              .scheduleTaskPriority
                                              .value ==
                                          TaskPriority.medium,
                                      color: cs.primary,
                                      onTap: () => controller
                                              .scheduleTaskPriority
                                              .value = TaskPriority.medium,
                                    ),
                                    const SizedBox(width: 4),
                                    _PriorityChip(
                                      label: 'High',
                                      isSelected: controller
                                              .scheduleTaskPriority
                                              .value ==
                                          TaskPriority.high,
                                      color: cs.error,
                                      onTap: () => controller
                                              .scheduleTaskPriority
                                              .value = TaskPriority.high,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Due date picker
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Due Date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () async {
                                    final date =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                          const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      controller.scheduleTaskDueDate
                                          .value = date;
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: cs.surface,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                          color: cs.outlineVariant),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 14,
                                            color: cs.primary),
                                        const SizedBox(width: 6),
                                        Text(
                                          controller.scheduleTaskDueDate
                                                      .value !=
                                                  null
                                              ? '${controller.scheduleTaskDueDate.value!.day}/${controller.scheduleTaskDueDate.value!.month}'
                                              : 'Set',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: controller
                                                    .scheduleTaskDueDate
                                                    .value !=
                                                null
                                                ? cs.onSurface
                                                : cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
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
            ],
          ),
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : color.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
