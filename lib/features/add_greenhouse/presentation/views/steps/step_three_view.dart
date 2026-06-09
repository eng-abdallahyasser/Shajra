import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/sensor_options.dart';
import '../../widgets/step_indicator.dart';
import '../../controllers/add_greenhouse_controller.dart';

/// Step 3 — Review and confirm the greenhouse details before submission.
class StepThreeView extends GetView<AddGreenhouseController> {
  const StepThreeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const StepIndicator(current: 3, total: 3),
          const SizedBox(height: 24),
          Text(
            'Review & Confirm',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check the information below before creating the greenhouse.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    label: 'Name',
                    value: controller.nameController.text.isNotEmpty
                        ? controller.nameController.text
                        : '—',
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Facility Type',
                    value: controller.selectedFacilityType.value.isNotEmpty
                        ? controller.selectedFacilityType.value
                        : '—',
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Dimensions',
                    value:
                        '${controller.widthController.text.isNotEmpty ? '${controller.widthController.text}m' : '—'} × '
                        '${controller.lengthController.text.isNotEmpty ? '${controller.lengthController.text}m' : '—'}',
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Sensor Type',
                    value: sensorLabel(
                      controller.selectedSensorType.value,
                    ),
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    label: 'Sensor Count',
                    value: controller.sensorCountController.text.isNotEmpty
                        ? controller.sensorCountController.text
                        : '—',
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
