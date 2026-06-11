import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/sensor_options.dart';
import '../../controllers/add_greenhouse_controller.dart';

/// Step 3 — Final review & confirm. Displays all the data gathered across
/// all three steps before sending the greenhouse to persistent storage.
class StepThreeView extends GetView<AddGreenhouseController> {
  const StepThreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Progress header
              _ProgressHeader(),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Review & Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: -0.64,
                  color: Color(0xFF171D14),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check all information before creating the greenhouse.',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  height: 22 / 15,
                  color: Color(0xFF41493E),
                ),
              ),
              const SizedBox(height: 24),

              // ---- Greenhouse info card ----
              _SectionCard(
                title: 'Greenhouse Info',
                children: [
                  _InfoRow(
                      label: 'Name',
                      value: controller.nameController.text.isNotEmpty
                          ? controller.nameController.text
                          : '—'),
                  _InfoRow(
                      label: 'Facility Type',
                      value: controller.selectedFacilityType.value.isNotEmpty
                          ? controller.selectedFacilityType.value
                          : '—'),
                  _InfoRow(
                      label: 'Orientation',
                      value: controller.selectedSolarOrientation.value.isNotEmpty
                          ? controller.selectedSolarOrientation.value
                          : '—'),
                  _InfoRow(
                    label: 'Dimensions',
                    value:
                        '${_metersText(controller.widthController.text)} × ${_metersText(controller.lengthController.text)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---- Zones card ----
              _SectionCard(
                title: 'Zones (${controller.zones.length})',
                children: controller.zones.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No zones added.',
                            style: TextStyle(
                                color: Color(0xFF717A6D), fontSize: 13),
                          ),
                        )
                      ]
                    : controller.zones
                        .map((z) => _ZoneRow(
                              name: z.name,
                              sizePixels: Size(z.rect.width, z.rect.height),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 16),

              // ---- Trees card ----
              _SectionCard(
                title: 'Trees (${controller.treePlacements.length})',
                children: [
                  _InfoRow(
                    label: 'Total placed',
                    value: '${controller.treePlacements.length}',
                  ),
                  if (controller.zones.isNotEmpty)
                    _InfoRow(
                      label: 'Avg per zone',
                      value: (controller.treePlacements.length /
                              controller.zones.length)
                          .toStringAsFixed(1),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ---- Sensor card ----
              _SectionCard(
                title: 'Sensor Setup',
                children: [
                  _InfoRow(
                    label: 'Type',
                    value: sensorLabel(controller.selectedSensorType.value),
                  ),
                  _InfoRow(
                    label: 'Count',
                    value: controller.sensorCountController.text.isNotEmpty
                        ? controller.sensorCountController.text
                        : '—',
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ));
  }

  String _metersText(String raw) {
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return '—';
    return '${v.toStringAsFixed(1)} m';
  }
}

// ---------------------------------------------------------------------------
// Progress header matching Steps 1 & 2
// ---------------------------------------------------------------------------

class _ProgressHeader extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP 0${controller.currentStep.value + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: Color(0xFF00450D),
              ),
            ),
            Text(
              controller.currentStepLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: Color(0xFF41493E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: SizedBox(
            height: 6,
            child: Row(
              children: List.generate(
                controller.totalSteps,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                    color: i <= controller.currentStep.value
                        ? const Color(0xFF00450D)
                        : const Color(0xFFE3EBDC),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC0C9BB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.6,
              color: Color(0xFF717A6D),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF717A6D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF171D14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Zone row showing name and pixel size (converted to meters)
// ---------------------------------------------------------------------------

class _ZoneRow extends StatelessWidget {
  final String name;
  final Size sizePixels;

  const _ZoneRow({required this.name, required this.sizePixels});

  @override
  Widget build(BuildContext context) {
    final scale = AddGreenhouseController.metersToPixels;
    final w = (sizePixels.width / scale).toStringAsFixed(1);
    final h = (sizePixels.height / scale).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF171D14),
            ),
          ),
          const Spacer(),
          Text(
            '$w × $h m',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF717A6D),
            ),
          ),
        ],
      ),
    );
  }
}
