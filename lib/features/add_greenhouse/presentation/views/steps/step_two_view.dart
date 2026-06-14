import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/add_greenhouse_controller.dart';

/// Step 2 — Greenhouse Map: interactive canvas for placing zones and trees.
class StepTwoView extends GetView<AddGreenhouseController> {
  const StepTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content column
        Column(
          children: [
            const _MapProgressHeader(),
            const Expanded(child: _CanvasArea()),
          ],
        ),
        // Toolbar overlay (left side)
        const Positioned(
          left: 16,
          top: 80,
          child: _Toolbar(),
        ),
        // FAB — Next Step (bottom-right)
        const Positioned(
          right: 16,
          bottom: 16,
          child: _NextStepFab(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress header
// ---------------------------------------------------------------------------

/// Step label "STEP 02 / GREENHOUSE MAP" and a 3-segment progress bar.
class _MapProgressHeader extends GetView<AddGreenhouseController> {
  const _MapProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
          border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step label row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STEP 0${controller.currentStep.value + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.6,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  controller.currentStepLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: List.generate(3, (i) {
                    final isFilled = i <= controller.currentStep.value;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                        color: isFilled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Canvas
// ---------------------------------------------------------------------------

/// Interactive zoomable canvas showing the greenhouse floor with zones and trees.
class _CanvasArea extends GetView<AddGreenhouseController> {
  const _CanvasArea();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surfaceContainerHighest,
            cs.surface,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Virtual floor dimensions from Step 1 (in meters, converted to pixels)
          final floorW = controller.greenhouseFloorWidthPixels;
          final floorH = controller.greenhouseFloorHeightPixels;

          return InteractiveViewer(
            transformationController: controller.transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(250),
            child: GestureDetector(
              onTapUp: (details) =>
                  _handleCanvasTap(context, details.localPosition),
              child: SizedBox(
                width: floorW,
                height: floorH,
                child: Obx(
                  () => Stack(
                    children: [
                      // Grid background
                      Positioned.fill(
                        child: CustomPaint(painter: _GridPainter()),
                      ),
                      // Highlight the floor area with a faint border
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Floor dimension label (center bottom) — fixed-size
                      if (double.tryParse(controller.widthController.text) != null &&
                          double.tryParse(controller.heightController.text) != null &&
                          (double.tryParse(controller.widthController.text) ?? 0) > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: IgnorePointer(
                            child: _FixedScaleWidget(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${double.tryParse(controller.widthController.text) ?? 0} \u00d7 '
                                    '${double.tryParse(controller.heightController.text) ?? 0} m',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Zones (long-press + drag to move, tap for profile)
                      ...controller.zones
                          .map((z) => _DraggableZoneWidget(zone: z)),
                      // Tree markers with Micro-Tagging labels
                      ...controller.treePlacements
                          .map((t) => _TreeWidget(tree: t)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleCanvasTap(BuildContext context, Offset position) {
    switch (controller.selectedTool.value) {
      case MapTool.addZone:
        _showZoneDimensionsDialog(context, position);
      case MapTool.addTree:
        controller.addTree(position);
      case MapTool.select:
        _removeAt(position);
      case MapTool.addSensor:
        break;
    }
  }

  /// Show a dialog to enter zone dimensions (in meters), then add the zone.
  Future<void> _showZoneDimensionsDialog(
      BuildContext context, Offset center) async {
    final result = await showDialog<Size>(
      context: context,
      builder: (ctx) => _ZoneDimensionDialogContent(),
    );

    if (result != null) {
      final scale = AddGreenhouseController.metersToPixels;
      controller.addZone(
        Rect.fromCenter(
          center: center,
          width: result.width * scale,
          height: result.height * scale,
        ),
      );
    }
  }

  /// Remove the topmost zone or tree at the tapped position.
  void _removeAt(Offset position) {
    for (int i = controller.zones.length - 1; i >= 0; i--) {
      if (controller.zones[i].rect.contains(position)) {
        controller.removeZone(controller.zones[i].id);
        return;
      }
    }
    for (int i = controller.treePlacements.length - 1; i >= 0; i--) {
      if ((controller.treePlacements[i].position - position).distance < 20) {
        controller.removeTree(controller.treePlacements[i].id);
        return;
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Zone widget
// ---------------------------------------------------------------------------

/// A zone rectangle with dashed border, translucent fill, and name label.
/// Tap opens a zone profile; long-press + drag repositions.
class _DraggableZoneWidget extends StatefulWidget {
  final GreenhouseMapZone zone;

  const _DraggableZoneWidget({required this.zone});

  @override
  State<_DraggableZoneWidget> createState() => _DraggableZoneWidgetState();
}

class _DraggableZoneWidgetState extends State<_DraggableZoneWidget> {
  Offset? _initialRectOrigin;
  Offset? _initialPointerOffset;

  void _showRenameDialog(
      BuildContext context, GreenhouseMapZone zone,
      AddGreenhouseController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => _RenameZoneDialog(
        currentName: zone.name,
        onRename: (newName) => ctrl.renameZone(zone.id, newName),
      ),
    );
  }

  void _showZoneProfile(BuildContext context) {
    final controller = Get.find<AddGreenhouseController>();
    final cs = Theme.of(context).colorScheme;
    final scale = AddGreenhouseController.metersToPixels;
    final zone = widget.zone;

    // Dimensions in meters
    final w = (zone.rect.width / scale).toStringAsFixed(1);
    final h = (zone.rect.height / scale).toStringAsFixed(1);
    final left = (zone.rect.left / scale).toStringAsFixed(1);
    final top = (zone.rect.top / scale).toStringAsFixed(1);

    // Count trees in this zone
    final treeCount = controller.treePlacements.where(
      (t) => t.zoneId == zone.id,
    ).length;

    // Parse GH number from zone ID
    String ghNumber = '';
    if (zone.id.startsWith('G')) {
      final parts = zone.id.split('-');
      if (parts.isNotEmpty) {
        ghNumber = parts[0].substring(1);
      }
    }

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

              // Header with zone icon + name
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.view_in_ar, size: 24, color: cs.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: -0.3,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Zone Profile',
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
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.tag,
                label: 'Micro-Tag',
                value: zone.id,
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.qr_code,
                label: 'Greenhouse',
                value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '—',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.eco,
                label: 'Trees in Zone',
                value: '$treeCount',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.straighten,
                label: 'Dimensions',
                value: '${w}m \u00d7 ${h}m',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.my_location,
                label: 'Position',
                value: '($left, $top) m',
              ),
              const SizedBox(height: 24),

              // Actions row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          _showRenameDialog(context, zone, controller);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Rename'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          controller.removeZone(zone.id);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                          side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final zone = widget.zone;
    final controller = Get.find<AddGreenhouseController>();

    return Positioned(
      left: zone.rect.left,
      top: zone.rect.top,
      child: GestureDetector(
        onLongPressStart: (details) {
          HapticFeedback.selectionClick();
          _initialRectOrigin = Offset(zone.rect.left, zone.rect.top);
          _initialPointerOffset = details.localPosition;
        },
        onLongPressMoveUpdate: (details) {
          if (_initialRectOrigin == null || _initialPointerOffset == null) {
            return;
          }
          // Compute absolute position from the initial rect origin plus
          // the pointer's cumulative offset from its initial position.
          final newLeft = _initialRectOrigin!.dx +
              (details.localPosition.dx - _initialPointerOffset!.dx);
          final newTop = _initialRectOrigin!.dy +
              (details.localPosition.dy - _initialPointerOffset!.dy);
          controller.moveZone(zone.id, newLeft - zone.rect.left,
              newTop - zone.rect.top);
        },
        onLongPressEnd: (_) {
          _initialRectOrigin = null;
          _initialPointerOffset = null;
        },
        child: SizedBox(
          width: zone.rect.width,
          height: zone.rect.height,
          child: Stack(
            children: [
              // Dashed border + background (tap zone body for profile)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _showZoneProfile(context),
                  child: CustomPaint(
                    painter: _DashedRectPainter(
                      color: Theme.of(context).colorScheme.primary,
                      bgColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      strokeWidth: 2,
                      borderRadius: 8,
                    ),
                  ),
                ),
              ),
              // Zone name label — tap to rename, fixed screen size
              Positioned(
                top: 4,
                left: 4,
                child: _FixedScaleWidget(
                  child: GestureDetector(
                    onTap: () => _showRenameDialog(context, zone, controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            zone.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.6,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.drag_indicator,
                            size: 10,
                            color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Zone dimensions dialog
// ---------------------------------------------------------------------------

/// Dialog content for entering zone width and height.
/// Uses StatefulWidget so TextEditingControllers are created/disposed
/// in sync with the dialog's own lifecycle, avoiding the "used after
/// being disposed" error during the close animation.
class _ZoneDimensionDialogContent extends StatefulWidget {
  @override
  State<_ZoneDimensionDialogContent> createState() =>
      _ZoneDimensionDialogContentState();
}

class _ZoneDimensionDialogContentState
    extends State<_ZoneDimensionDialogContent> {
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: '5');
    _heightController = TextEditingController(text: '4');
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zone Dimensions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter the zone dimensions in meters:',
            style: TextStyle(fontSize: 14, color: Color(0xFF41493E)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Width (m)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (m)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final w = double.tryParse(_widthController.text) ?? 0;
            final h = double.tryParse(_heightController.text) ?? 0;
            if (w > 0 && h > 0) {
              Navigator.of(context).pop(Size(w, h));
            }
          },
          child: const Text('Add Zone'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rename zone dialog
// ---------------------------------------------------------------------------

/// Dialog for editing a zone's name.
class _RenameZoneDialog extends StatefulWidget {
  final String currentName;
  final ValueChanged<String> onRename;

  const _RenameZoneDialog({
    required this.currentName,
    required this.onRename,
  });

  @override
  State<_RenameZoneDialog> createState() => _RenameZoneDialogState();
}

class _RenameZoneDialogState extends State<_RenameZoneDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Zone'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Zone Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              widget.onRename(name);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tree widget
// ---------------------------------------------------------------------------

/// A tree marker dot on the greenhouse floor with a Micro-Tagging label.
/// Tapping opens a profile bottom sheet.
class _TreeWidget extends StatelessWidget {
  final TreePlacement tree;

  const _TreeWidget({required this.tree});

  void _showProfile(BuildContext context) {
    final controller = Get.find<AddGreenhouseController>();
    final cs = Theme.of(context).colorScheme;
    final scale = AddGreenhouseController.metersToPixels;

    // Find zone name from zoneId
    String zoneName = '\u2014';
    if (tree.zoneId != null) {
      final zone = controller.zones.firstWhereOrNull(
        (z) => z.id == tree.zoneId,
      );
      if (zone != null) zoneName = zone.name;
    }

    // Position in meters
    final posX = (tree.position.dx / scale).toStringAsFixed(2);
    final posY = (tree.position.dy / scale).toStringAsFixed(2);

    // Parse GH number from tree ID
    String ghNumber = '';
    if (tree.id.startsWith('G')) {
      final parts = tree.id.split('-');
      if (parts.isNotEmpty) {
        ghNumber = parts[0].substring(1);
      }
    }

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

              // Header with tree icon + ID
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.eco, size: 24, color: cs.primary),
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
                          'Tree Profile',
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
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.tag,
                label: 'Micro-Tag',
                value: tree.id,
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.qr_code,
                label: 'Greenhouse',
                value: ghNumber.isNotEmpty ? 'GH #$ghNumber' : '\u2014',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.view_in_ar,
                label: 'Zone',
                value: tree.zoneId != null ? '$zoneName (${tree.zoneId})' : 'Not assigned',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                cs: cs,
                icon: Icons.my_location,
                label: 'Position',
                value: '($posX, $posY) m',
              ),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.removeTree(tree.id);
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove Tree'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    // Extract a compact display label from the Micro-Tagging ID
    // e.g. "G001-ZoneA-01-T02" -> "ZoneA-01-T02"
    final tagParts = tree.id.split('-');
    final shortLabel = tagParts.length >= 3
        ? tagParts.sublist(tagParts.length - 3).join('-')
        : tree.id;

    return Positioned(
      left: tree.position.dx - 12,
      top: tree.position.dy - 12,
      child: _FixedScaleWidget(
        child: GestureDetector(
          onTap: () => _showProfile(context),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Tree dot (centered within the 24x24 box)
                Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.eco,
                      size: 11,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                // ID label floating above the dot
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        shortLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          height: 1.1,
                          letterSpacing: 0.3,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile info row (shared by tree and zone profiles)
// ---------------------------------------------------------------------------

/// A single info row in a profile bottom sheet.
class _ProfileInfoRow extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.cs,
    required this.icon,
    required this.label,
    required this.value,
  });

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
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 14),
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

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

/// Tool buttons (Add Zone, Add Trees, Remove) and zoom controls.
class _Toolbar extends GetView<AddGreenhouseController> {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tool = controller.selectedTool.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToolButton(
            icon: Icons.add_box_outlined,
            label: 'Add Zone',
            isActive: tool == MapTool.addZone,
            onTap: () => controller.selectedTool.value = MapTool.addZone,
          ),
          const SizedBox(height: 8),
          _ToolButton(
            icon: Icons.eco,
            label: 'Add Trees',
            isActive: tool == MapTool.addTree,
            onTap: () => controller.selectedTool.value = MapTool.addTree,
          ),
          const SizedBox(height: 8),
          _ToolButton(
            icon: Icons.remove_circle_outline,
            label: 'Remove',
            isActive: tool == MapTool.select,
            onTap: () => controller.selectedTool.value = MapTool.select,
          ),
          const SizedBox(height: 8),
          _ToolButton(
            icon: Icons.auto_fix_high,
            label: 'Generate',
            isActive: false,
            onTap: () {
              controller.generateLayout();
              // Reset zoom
              final matrix = Matrix4.diagonal3Values(1, 1, 1);
              controller.transformationController.value = matrix;
            },
          ),
          const SizedBox(height: 16),
          // Zoom controls
          Row(
            children: [
              _ZoomButton(
                icon: Icons.add,
                size: 18,
                onTap: controller.zoomIn,
              ),
              const SizedBox(width: 8),
              _ZoomButton(
                icon: Icons.remove,
                size: 18,
                onTap: controller.zoomOut,
              ),
            ],
          ),
        ],
      );
    });
  }
}

/// A toolbar button with icon + label.
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color:
                isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small square button for zoom in / zoom out.
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: size, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB
// ---------------------------------------------------------------------------

/// Floating circular "Next Step" button.
class _NextStepFab extends GetView<AddGreenhouseController> {
  const _NextStepFab();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.nextStep,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
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
        child: const Icon(
          Icons.arrow_forward,
          size: 21.33,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fixed-scale widget (inverse of zoom)
// ---------------------------------------------------------------------------

/// Wraps a child and applies an inverse scale transform so it stays
/// a fixed screen size regardless of the InteractiveViewer's zoom level.
///
/// Uses [ValueListenableBuilder]'s [child] parameter to avoid rebuilding
/// the label/marker widget tree on every zoom frame.
class _FixedScaleWidget extends StatelessWidget {
  final Widget child;

  const _FixedScaleWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddGreenhouseController>();
    return ValueListenableBuilder<Matrix4>(
      valueListenable: controller.transformationController,
      builder: (context, matrix, fixedChild) {
        final scale = matrix.getMaxScaleOnAxis();
        return Transform.scale(
          scale: 1.0 / scale,
          child: fixedChild,
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

/// Paints a dotted grid overlay.
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withValues(alpha: 0.08)
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

/// Paints a dashed rounded rectangle with a translucent background fill.
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final Color bgColor;
  final double strokeWidth;
  final double borderRadius;

  _DashedRectPainter({
    required this.color,
    required this.bgColor,
    this.strokeWidth = 2,
    this.borderRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Background fill
    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Dashed border
    const dashWidth = 6.0;
    const dashGap = 4.0;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, borderPaint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.bgColor != bgColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.borderRadius != borderRadius;
}
