import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/add_greenhouse_controller.dart';

/// Step 1 — Define the greenhouse: name, facility type, orientation, dimensions.
class StepOneView extends GetView<AddGreenhouseController> {
  const StepOneView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // ---- Wizard Progress Bar ----
          _ProgressHeader(),
          const SizedBox(height: 32),
          // ---- Header Section ----
          _HeaderSection(),
          const SizedBox(height: 24),
          // ---- Facility Visualization Card ----
          _FacilityCard(),
          const SizedBox(height: 32),
          // ---- Form Fields ----
          _GreenhouseForm(),
          const SizedBox(height: 24),
          // ---- Descriptive Note Card ----
          _InfoNoteCard(),
        ],
      ),
    );
  }
}

/// Progress bar showing step labels and a 3-segment bar.
class _ProgressHeader extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step labels row
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
          // 3-segment progress bar
          SizedBox(
            height: 8,
            child: Row(
              children: List.generate(3, (i) {
                final isFilled = i <= controller.currentStep.value;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: i > 0 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// "New Greenhouse Setup" heading + subtitle.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Greenhouse Setup',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.64,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure the core physical parameters of your growing environment to enable high-precision climate monitoring.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 24 / 16,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Facility visualization card with greenhouse image placeholder.
class _FacilityCard extends StatelessWidget {
  const _FacilityCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 192,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image placeholder with gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surfaceContainerHigh,
                    cs.surfaceContainerHighest,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.warehouse_rounded,
                  size: 64,
                  color: cs.primary.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          // Gradient overlay at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.primary.withValues(alpha: 0),
                    cs.primary.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),
          // Badge at bottom-left
          Positioned(
            left: 17,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'MODERN GREENHOUSE',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form fields: name, facility type, orientation, dimensions.
class _GreenhouseForm extends GetView<AddGreenhouseController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greenhouse Name
        const _FieldLabel('Greenhouse Name'),
        const SizedBox(height: 8),
        const _NameField(),
        const SizedBox(height: 24),
        // Facility Type
        const _FieldLabel('Facility Type'),
        const SizedBox(height: 8),
        const _FacilityTypeDropdown(),
        const SizedBox(height: 24),
        // Solar Orientation
        const _FieldLabel('Solar Orientation'),
        const SizedBox(height: 8),
        const _SolarOrientationDropdown(),
        const SizedBox(height: 24),
        // Dimensions
        const _FieldLabel('Dimensions (Meters)'),
        const SizedBox(height: 8),
        const _DimensionFields(),
      ],
    );
  }
}

/// Bold uppercase label for a form field.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.6,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

/// Greenhouse name text input.
class _NameField extends GetView<AddGreenhouseController> {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller.nameController,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'e.g. North Sector Glasshouse A',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}

/// Facility type dropdown.
class _FacilityTypeDropdown extends GetView<AddGreenhouseController> {
  const _FacilityTypeDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField(
        value: controller.selectedFacilityType.value.isEmpty
            ? null
            : controller.selectedFacilityType.value,
        hint: 'Glasshouse',
        items: AddGreenhouseController.facilityTypes,
        onChanged: (v) => controller.selectedFacilityType.value = v,
      ),
    );
  }
}

/// Solar orientation dropdown.
class _SolarOrientationDropdown extends GetView<AddGreenhouseController> {
  const _SolarOrientationDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _DropdownField(
        value: controller.selectedSolarOrientation.value.isEmpty
            ? null
            : controller.selectedSolarOrientation.value,
        hint: 'North-South Alignment',
        items: AddGreenhouseController.solarOrientations,
        onChanged: (v) => controller.selectedSolarOrientation.value = v,
      ),
    );
  }
}

/// A styled dropdown button matching the Figma design.
class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              hint,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              size: 24,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: cs.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Width (W) and Length (L) input fields side by side.
class _DimensionFields extends GetView<AddGreenhouseController> {
  const _DimensionFields();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          // Width
          Expanded(
            child: _DimensionInput(
              prefix: 'W',
              controller: controller.widthController,
            ),
          ),
          const SizedBox(width: 12),
          // Length
          Expanded(
            child: _DimensionInput(
              prefix: 'L',
              controller: controller.lengthController,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single dimension input with a prefix label (W or L).
class _DimensionInput extends StatelessWidget {
  final String prefix;
  final TextEditingController controller;

  const _DimensionInput({
    required this.prefix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Prefix label with divider
          Container(
            width: 40,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: cs.outlineVariant),
              ),
            ),
            child: Text(
              prefix,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.6,
                color: cs.outline,
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Color(0xFF6B7280),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Informational note card with icon and text.
class _InfoNoteCard extends StatelessWidget {
  const _InfoNoteCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(color: cs.primaryContainer),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline,
              size: 20,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'The facility profile you provide will be used to calibrate the climate model for your specific greenhouse geometry and orientation, ensuring accurate microclimate predictions.',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 20 / 14,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
