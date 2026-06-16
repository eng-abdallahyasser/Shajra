import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/tasks_controller.dart';

/// Map [TaskPriority] to its translation key.
const _priorityKeys = {
  TaskPriority.low: 'tasks_priority_low',
  TaskPriority.medium: 'tasks_priority_medium',
  TaskPriority.high: 'tasks_priority_high',
  TaskPriority.critical: 'tasks_priority_critical',
};

/// Return the translated label for a task priority.
String _priorityLabel(TaskPriority p) => _priorityKeys[p]!.tr;

/// Zone data value to translated label lookup.
const _zoneKeys = {
  'All': 'tasks_zone_all',
  'Zone A': 'tasks_zone_a',
  'Zone B': 'tasks_zone_b',
  'Zone C': 'tasks_zone_c',
};

/// Return the translated label for a zone value.
String _zoneLabel(String zone) => _zoneKeys[zone]?.tr ?? zone;

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController(), permanent: true);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Obx(
          () {
            if (!controller.isLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(child: _HeaderSection(cs: cs)),
                SliverToBoxAdapter(child: _StatsRow(controller: controller, cs: cs)),
                SliverToBoxAdapter(child: _FilterChips(controller: controller, cs: cs)),
                SliverToBoxAdapter(child: const SizedBox(height: 8)),

                // ── Task List ──
                if (controller.filteredTasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(cs: cs),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = controller.filteredTasks[index];
                        return _TaskCard(
                          task: task,
                          controller: controller,
                          cs: cs,
                        );
                      },
                      childCount: controller.filteredTasks.length,
                    ),
                  ),

                // ── Bottom padding ──
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context, controller),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Show the bottom sheet to add a new task.
  void _showAddTaskSheet(BuildContext context, TasksController controller) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedZone = RxString('All');
    final selectedPriority = Rx<TaskPriority>(TaskPriority.medium);
    final selectedDate = Rx<DateTime?>(null);
    final cs = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
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

              // Title
              Text(
                'tasks_new_task_title'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Task title field
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'tasks_title_hint'.tr,
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Description field
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'tasks_desc_hint'.tr,
                  filled: true,
                  fillColor: cs.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // Zone + Priority row
              Row(
                children: [
                  // Zone dropdown
                  Expanded(
                    child: _SheetDropdown(
                      label: 'tasks_zone_label'.tr,
                      value: selectedZone.value,
                      items: _zoneKeys.keys.toList(),
                      onChanged: (v) => selectedZone.value = v ?? 'All',
                      cs: cs,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Priority dropdown
                  Expanded(
                    child: Obx(
                      () => _SheetDropdown(
                        label: 'tasks_priority_label'.tr,
                        value: selectedPriority.value.label,
                        items: TaskPriority.values.map((p) => p.label).toList(),
                        onChanged: (v) {
                          selectedPriority.value = TaskPriority.values.firstWhere(
                            (p) => p.label == v,
                          );
                        },
                        cs: cs,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Due date picker
              Obx(
                () => GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      selectedDate.value = date;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate.value != null
                              ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
                              : 'tasks_due_hint'.tr,
                          style: TextStyle(
                            color: selectedDate.value != null
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        if (selectedDate.value != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => selectedDate.value = null,
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    controller.addTask(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      zone: selectedZone.value,
                      priority: selectedPriority.value,
                      dueDate: selectedDate.value,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'tasks_add_btn'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
}

// ═══════════════════════════════════════════════
//  1. Header Section
// ═══════════════════════════════════════════════

class _HeaderSection extends StatelessWidget {
  final ColorScheme cs;

  const _HeaderSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'tasks_title'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 28,
              height: 34 / 28,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'tasks_subtitle'.tr,
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
//  2. Stats Row
// ═══════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final TasksController controller;
  final ColorScheme cs;

  const _StatsRow({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _StatTile(
            label: 'tasks_stat_total'.tr,
            value: '${controller.totalCount}',
            color: cs.onSurface,
            cs: cs,
          ),
          const SizedBox(width: 12),
          _StatTile(
            label: 'tasks_stat_pending'.tr,
            value: '${controller.pendingCount}',
            color: cs.error,
            cs: cs,
          ),
          const SizedBox(width: 12),
          _StatTile(
            label: 'tasks_stat_completed'.tr,
            value: '${controller.completedCount}',
            color: cs.primary,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ColorScheme cs;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  3. Filter Chips
// ═══════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  final TasksController controller;
  final ColorScheme cs;

  const _FilterChips({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Obx(
        () => Row(
          children: [
            _FilterChip(
              label: 'tasks_filter_all'.tr,
              isActive: controller.activeFilter.value == TaskFilter.all,
              count: controller.totalCount,
              cs: cs,
              onTap: () => controller.setFilter(TaskFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'tasks_stat_pending'.tr,
              isActive: controller.activeFilter.value == TaskFilter.pending,
              count: controller.pendingCount,
              cs: cs,
              onTap: () => controller.setFilter(TaskFilter.pending),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'tasks_stat_completed'.tr,
              isActive: controller.activeFilter.value == TaskFilter.completed,
              count: controller.completedCount,
              cs: cs,
              onTap: () => controller.setFilter(TaskFilter.completed),
            ),
            const Spacer(),
            if (controller.completedCount > 0)
              GestureDetector(
                onTap: () => controller.clearCompleted(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(
                    Icons.delete_sweep_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int count;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.count,
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
          color: isActive ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? cs.onPrimary.withValues(alpha: 0.2)
                    : cs.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  4. Task Card
// ═══════════════════════════════════════════════

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final TasksController controller;
  final ColorScheme cs;

  const _TaskCard({
    required this.task,
    required this.controller,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: cs.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => controller.deleteTask(task.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isCompleted
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => controller.toggleTask(task.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => controller.toggleTask(task.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: task.isCompleted ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: task.isCompleted ? cs.primary : cs.outline,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: task.isCompleted
                              ? cs.onSurface.withValues(alpha: 0.4)
                              : cs.onSurface,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Tags row
                      Row(
                        children: [
                          // Zone badge
                          if (task.zone != 'All')
                            _TagChip(
                              label: _zoneLabel(task.zone),
                              color: cs.tertiary,
                              bgColor: cs.tertiaryContainer,
                              cs: cs,
                            ),
                          if (task.zone != 'All' && task.dueDate != null)
                            const SizedBox(width: 6),

                          // Due date
                          if (task.dueDate != null)
                            _TagChip(
                              label: _formatDate(task.dueDate!),
                              color: _isOverdue(task.dueDate!)
                                  ? cs.error
                                  : cs.onSurfaceVariant,
                              bgColor: _isOverdue(task.dueDate!)
                                  ? cs.errorContainer
                                  : cs.surfaceContainerLow,
                              icon: Icons.schedule_outlined,
                              cs: cs,
                            ),
                          const Spacer(),

                          // Priority badge
                          _PriorityBadge(priority: task.priority, cs: cs),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    if (diff < 0) return 'tasks_overdue'.tr;
    if (diff == 0) return 'tasks_today'.tr;
    if (diff == 1) return 'tasks_tomorrow'.tr;
    return '${date.day}/${date.month}';
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now()) && !task.isCompleted;
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;
  final ColorScheme cs;

  const _TagChip({
    required this.label,
    required this.color,
    required this.bgColor,
    this.icon,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final ColorScheme cs;

  const _PriorityBadge({required this.priority, required this.cs});

  @override
  Widget build(BuildContext context) {
    final (Color color, Color bg) = switch (priority) {
      TaskPriority.low => (cs.onSurfaceVariant, cs.surfaceContainerLow),
      TaskPriority.medium => (cs.primary, cs.primaryContainer),
      TaskPriority.high => (cs.tertiary, cs.tertiaryContainer),
      TaskPriority.critical => (cs.error, cs.errorContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _priorityLabel(priority),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  5. Empty State
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
                Icons.checklist_rounded,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'tasks_empty_title'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'tasks_empty_subtitle'.tr,
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

// ═══════════════════════════════════════════════
//  6. Bottom Sheet Helpers
// ═══════════════════════════════════════════════

class _SheetDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final ColorScheme cs;

  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                final label = _zoneKeys[item];
                return DropdownMenuItem(
                  value: item,
                  child: Text(label != null ? label.tr : item),
                );
              }).toList(),
              onChanged: onChanged,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
